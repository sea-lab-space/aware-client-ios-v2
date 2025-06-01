//
//  AWAREHealthKitECG.m
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/1/25.
//

#import <HealthKit/HealthKit.h>

#import "AWAREHealthKitECG.h"
#import "AWAREUtils.h"
#import "TCQMaker.h"
#import "AWAREHealthKit.h"

@import CoreData;

@implementation AWAREHealthKitECG {
    NSString * KEY_DEVICE_ID;
    NSString * KEY_TIMESTAMP_START;
    NSString * KEY_TIMESTAMP_END;
    NSString * KEY_SAMPLING_FREQUENCY;
    NSString * KEY_CLASSIFICATION;
    NSString * KEY_AVG_HEART_RATE;
    NSString * KEY_DEVICE;
    NSString * KEY_SOURCE;
    NSString * KEY_METADATA;
    NSString * KEY_VOLTAGES;
    NSString * KEY_TIMESTAMP;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType {
    NSString * sensorName = [NSString stringWithFormat:@"%@_ecg", SENSOR_HEALTH_KIT];
    NSString * entityName = @"EntityHealthKitECG";
    return [self initWithAwareStudy:study dbType:dbType
                         sensorName:sensorName
                         entityName:entityName];
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                             dbType:(AwareDBType)dbType
                         sensorName:(NSString *)sensorName
                         entityName:(NSString *)entityName {
    AWAREStorage * storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study
                                          sensorName:sensorName];
    } else {
        storage = [[SQLiteStorage alloc] initWithStudy:study
                                            sensorName:sensorName
                                            entityName:entityName
                                        insertCallBack:^(NSDictionary *data,
                                                         NSManagedObjectContext *childContext,
                                                         NSString *entityName) {
                                            NSManagedObject * entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                                                     inManagedObjectContext:childContext];
                                            [entity setValuesForKeysWithDictionary:data];
                                        }];
    }
    self = [super initWithAwareStudy:study sensorName:sensorName storage:storage];
    
    if (self) {
        _healthStore = [[HKHealthStore alloc] init];
        
        KEY_DEVICE_ID = @"device_id";
        KEY_TIMESTAMP_START = @"timestamp_start";
        KEY_TIMESTAMP_END = @"timestamp_end";
        KEY_SAMPLING_FREQUENCY = @"sampling_frequency";
        KEY_CLASSIFICATION = @"classification";
        KEY_AVG_HEART_RATE = @"average_heart_rate";
        KEY_DEVICE = @"device";
        KEY_SOURCE = @"source";
        KEY_METADATA = @"metadata";
        KEY_VOLTAGES = @"voltages";
        KEY_TIMESTAMP = @"timestamp";
    }
    return self;
}

- (void)createTable {
    if (self.isDebug) NSLog(@"[%@] create table!", [self getSensorName]);
    TCQMaker * tcqMaker = [[TCQMaker alloc] init];
    [tcqMaker addColumn:KEY_TIMESTAMP_START type:TCQTypeReal default:@"0"];
    [tcqMaker addColumn:KEY_TIMESTAMP_END type:TCQTypeReal default:@"0"];
    [tcqMaker addColumn:KEY_SAMPLING_FREQUENCY type:TCQTypeReal default:@"0"];
    [tcqMaker addColumn:KEY_CLASSIFICATION type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_AVG_HEART_RATE type:TCQTypeReal default:@"0"];
    [tcqMaker addColumn:KEY_DEVICE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_SOURCE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_METADATA type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_VOLTAGES type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_TIMESTAMP type:TCQTypeReal default:@"0"];
    
    NSString * query = [tcqMaker getDefaudltTableCreateQuery];
    [self.storage createDBTableOnServerWithQuery:query];
}

- (void)saveECGData:(NSArray <HKElectrocardiogram *> * _Nonnull)data  API_AVAILABLE(ios(14.0)){
    if (data.count == 0) {
        return;
    } else {
        NSMutableArray * buffer = [[NSMutableArray alloc] init];

        for (HKElectrocardiogram * ecg in data) {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[AWAREUtils getUnixTimestamp:ecg.startDate] forKey:KEY_TIMESTAMP_START];
            [dict setObject:[AWAREUtils getUnixTimestamp:ecg.endDate] forKey:KEY_TIMESTAMP_END];
            [dict setObject:@([ecg.samplingFrequency doubleValueForUnit:[HKUnit hertzUnit]])
                     forKey:KEY_SAMPLING_FREQUENCY];
            [dict setObject:@(ecg.classification) forKey:KEY_CLASSIFICATION];
            [dict setObject:@([ecg.averageHeartRate doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]])
                     forKey:KEY_AVG_HEART_RATE];
            [dict setObject:[self getDeviceId] forKey:KEY_DEVICE_ID];
            [dict setObject:@"HealthKit" forKey:KEY_SOURCE];
            [dict setObject:[AWAREUtils getUnixTimestamp:[NSDate date]] forKey:KEY_TIMESTAMP];

            if (ecg.device == nil) {
                [dict setObject:@"unknown" forKey:KEY_DEVICE];
            } else {
                [dict setObject:ecg.device.description forKey:KEY_DEVICE];
            }
            
            [self fetchECGVoltageFor:ecg completion:^(NSString * _Nonnull voltageData) {
                [dict setObject:voltageData forKey:self->KEY_VOLTAGES];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.storage saveDataWithDictionary:dict buffer:NO saveInMainThread:NO];
                    if (buffer.count > 0) {
                        NSDictionary * lastObj = buffer.lastObject;
                        [self setLatestData:lastObj];
                        NSString * message = [NSString stringWithFormat:@"[Start:%@][Class:%@][HeartRate:%@]",
                                              lastObj[self->KEY_TIMESTAMP_START],
                                              lastObj[self->KEY_CLASSIFICATION],
                                              lastObj[self->KEY_AVG_HEART_RATE]];
                        [self setLatestValue:message];
                    }
                });
            }];
        }
    }
}

- (void)fetchECGVoltageFor:(HKElectrocardiogram *)ecg completion:(void (^)(NSString * _Nonnull))completion  API_AVAILABLE(ios(14.0)){
    NSMutableArray *voltageArray = [[NSMutableArray alloc] init];

      HKElectrocardiogramQuery *query = [[HKElectrocardiogramQuery alloc] initWithElectrocardiogram:ecg
                                                                                        dataHandler:^(HKElectrocardiogramQuery * _Nonnull query,
                                                                                                      HKElectrocardiogramVoltageMeasurement * _Nullable result,
                                                                                                      BOOL done,
                                                                                                      NSError * _Nullable error) {
          if (error) {
              NSLog(@"ECG Voltage Query Error: %@", error.localizedDescription);
              completion(@"[]");
              return;
          }

          if (result) {
              HKQuantity *voltageQuantity = [result quantityForLead:HKElectrocardiogramLeadAppleWatchSimilarToLeadI];
              double voltage = 0.0;
              if (voltageQuantity) {
                  voltage = [voltageQuantity doubleValueForUnit:[HKUnit voltUnit]] * 1000; // convert to mV
              }
              double time = result.timeSinceSampleStart + [ecg.startDate timeIntervalSince1970];

              NSDictionary *voltageData = @{@"time": @(time), @"voltage": @(voltage)};
              [voltageArray addObject:voltageData];
          }

          if (done) {
              NSData *jsonData = [NSJSONSerialization dataWithJSONObject:voltageArray options:0 error:nil];
              NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
              completion(jsonString);
          }
      }];
    
    [self.healthStore executeQuery:query];
}

@end
