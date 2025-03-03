//
//  AWAREHealthKitClinical.m
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/3/25.
//

#import "AWAREHealthKitClinical.h"
#import "AWAREUtils.h"
#import "TCQMaker.h"
#import "AWAREHealthKit.h"

@import CoreData;

@implementation AWAREHealthKitClinical {
    NSString *KEY_DEVICE_ID;
    NSString *KEY_TIMESTAMP;
    NSString *KEY_DATA_TYPE;
    NSString *KEY_FHIR_RESOURCE;
    NSString *KEY_SOURCE;
    NSString *KEY_DEVICE;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType {
    NSString *sensorName = [NSString stringWithFormat:@"%@_clinical", SENSOR_HEALTH_KIT];
    NSString *entityName = @"EntityHealthKitClinical";
    return [self initWithAwareStudy:study dbType:dbType sensorName:sensorName entityName:entityName];
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                            dbType:(AwareDBType)dbType
                        sensorName:(NSString *)sensorName
                        entityName:(NSString *)entityName {
    AWAREStorage *storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study sensorName:sensorName];
    } else {
        storage = [[SQLiteStorage alloc] initWithStudy:study
                                            sensorName:sensorName
                                            entityName:entityName
                                        insertCallBack:^(NSDictionary *data,
                                                         NSManagedObjectContext *childContext,
                                                         NSString *entityName) {
            NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                    inManagedObjectContext:childContext];
            [entity setValuesForKeysWithDictionary:data];
        }];
    }
    self = [super initWithAwareStudy:study sensorName:sensorName storage:storage];
    
    if (self) {
        KEY_DEVICE_ID = @"device_id";
        KEY_TIMESTAMP = @"timestamp";
        KEY_DATA_TYPE = @"type";
        KEY_FHIR_RESOURCE = @"fhirResource";
        KEY_SOURCE = @"source";
        KEY_DEVICE = @"device";
    }
    return self;
}

- (void)createTable {
    if (self.isDebug) NSLog(@"[%@] create table!", [self getSensorName]);
    TCQMaker *tcqMaker = [[TCQMaker alloc] init];
    [tcqMaker addColumn:KEY_DATA_TYPE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_FHIR_RESOURCE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_SOURCE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_DEVICE type:TCQTypeText default:@"''"];
    NSString *query = [tcqMaker getDefaudltTableCreateQuery];
    [self.storage createDBTableOnServerWithQuery:query];
}

- (void)saveClinicalData:(NSArray<HKClinicalRecord *> *)data  API_AVAILABLE(ios(12.0)){
    if (data.count == 0) {
        return;
    } else {
        NSMutableArray *buffer = [[NSMutableArray alloc] init];
        
        for (HKClinicalRecord *record in data) {
            HKSampleType *type = record.sampleType;
            if ([self isDebug]) NSLog(@"%@", type);
            
            NSString *fhirResourceString = @"";
            if (record.FHIRResource) {
                NSError *error;
                NSDictionary *fhirDict = [NSJSONSerialization JSONObjectWithData:record.FHIRResource.data options:0 error:&error];
                if (!error) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fhirDict options:0 error:&error];
                    if (!error) {
                        fhirResourceString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    }
                }
            }
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[AWAREUtils getUnixTimestamp:[NSDate new]] forKey:KEY_TIMESTAMP];
            [dict setObject:[self getDeviceId] forKey:KEY_DEVICE_ID];
            [dict setObject:type.identifier forKey:KEY_DATA_TYPE];
            [dict setObject:fhirResourceString forKey:KEY_FHIR_RESOURCE];
            [dict setObject:record.sourceRevision.source.bundleIdentifier forKey:KEY_SOURCE];
            if (record.device == nil) {
                [dict setObject:@"unknown" forKey:KEY_DEVICE];
            } else {
                [dict setObject:record.device.description forKey:KEY_DEVICE];
            }
            [buffer addObject:dict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storage saveDataWithArray:buffer buffer:NO saveInMainThread:NO];
            if (buffer.count > 0) {
                NSDictionary *lastObj = buffer.lastObject;
                [self setLatestData:lastObj];
                NSString *message = [NSString stringWithFormat:@"[date:%@][type:%@]",
                                     lastObj[self->KEY_TIMESTAMP],
                                     lastObj[self->KEY_DATA_TYPE]];
                [self setLatestValue:message];
            }
        });
    }
}

@end
