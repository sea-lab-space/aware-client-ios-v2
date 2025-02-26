//
//  AWAREHealthKitCharacteristic.m
//  AWARE
//
//  Created by Xiaowen Lin on 2025/02/25.
//

#import "AWAREHealthKitCharacteristic.h"
#import "AWAREUtils.h"
#import "TCQMaker.h"
#import "EntityHealthKitCharacteristic+CoreDataClass.h"

@implementation AWAREHealthKitCharacteristic {
    NSString *KEY_DEVICE_ID;
    NSString *KEY_TIMESTAMP;
    NSString *KEY_DATA_TYPE;
    NSString *KEY_VALUE;
    NSString *KEY_SOURCE;
    NSString *KEY_METADATA;
    NSString *KEY_UNIT;
    NSString *KEY_LABEL;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                            dbType:(AwareDBType)dbType
               characteristicTypes:(NSSet<HKCharacteristicType *> *)characteristicTypes {
    
    NSString *sensorName = [NSString stringWithFormat:@"%@_characteristic", SENSOR_HEALTH_KIT];
    NSString *entityName = @"EntityHealthKitCharacteristic";
    
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
            EntityHealthKitCharacteristic *entity = (EntityHealthKitCharacteristic *)
            [NSEntityDescription insertNewObjectForEntityForName:entityName
                                          inManagedObjectContext:childContext];
            [entity setValuesForKeysWithDictionary:data];
        }];
    }
    
    self = [super initWithAwareStudy:study sensorName:sensorName storage:storage];
    
    if (self) {
        _healthStore = [[HKHealthStore alloc] init];
        _characteristicTypes = characteristicTypes;
        
        KEY_DEVICE_ID = @"device_id";
        KEY_TIMESTAMP = @"timestamp";
        KEY_DATA_TYPE = @"type";
        KEY_VALUE = @"value";
        KEY_SOURCE = @"source";
        KEY_METADATA = @"metadata";
        KEY_UNIT = @"unit";
        KEY_LABEL = @"label";
    }
    return self;
}

- (void)createTable {
    if (self.isDebug) {
        NSLog(@"[%@] create table!", self.getSensorName);
    }
    
    TCQMaker *tcqMaker = [[TCQMaker alloc] init];
    [tcqMaker addColumn:KEY_TIMESTAMP type:TCQTypeReal default:@"0"];
    [tcqMaker addColumn:KEY_DATA_TYPE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_VALUE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_DEVICE_ID type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_SOURCE type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_METADATA type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_UNIT type:TCQTypeText default:@"''"];
    [tcqMaker addColumn:KEY_LABEL type:TCQTypeText default:@"''"];
    
    [self.storage createDBTableOnServerWithQuery:[tcqMaker getDefaudltTableCreateQuery]];
}

- (void)fetchAndSaveCharacteristicData {
    for (HKCharacteristicType *type in _characteristicTypes) {
        NSError *error = nil;
        id characteristicValue = nil;

        if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierBiologicalSex]) {
            characteristicValue = @([_healthStore biologicalSexWithError:&error].biologicalSex);
        } else if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierBloodType]) {
            characteristicValue = @([_healthStore bloodTypeWithError:&error].bloodType);
        } else if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierDateOfBirth]) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dobComponents = [_healthStore dateOfBirthComponentsWithError:&error];
            NSDate *dob = [calendar dateFromComponents:dobComponents]; // 转换为 NSDate
            characteristicValue = dob ? @([dob timeIntervalSince1970]) : nil; // 存储为时间戳
        } else if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierFitzpatrickSkinType]) {
            characteristicValue = @([_healthStore fitzpatrickSkinTypeWithError:&error].skinType);
        } else if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierWheelchairUse]) {
            characteristicValue = @([_healthStore wheelchairUseWithError:&error].wheelchairUse);
        } else if (@available(iOS 14.0, *)) {
            if ([type.identifier isEqualToString:HKCharacteristicTypeIdentifierActivityMoveMode]) {
                HKActivityMoveModeObject *moveModeObject = [_healthStore activityMoveModeWithError:&error];
                if (moveModeObject) {
                    characteristicValue = @(moveModeObject.activityMoveMode);
                }
            }
        }

        if (error) {
            NSLog(@"Error fetching characteristic data for %@: %@", type.identifier, error.localizedDescription);
            continue;
        }

        // 确保 characteristicValue 不为空
        if (!characteristicValue) {
            if (self.isDebug) NSLog(@"No value available for characteristic %@", type.identifier);
            continue;
        }

        // 组装数据字典
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:[AWAREUtils getUnixTimestamp:[NSDate new]] forKey:KEY_TIMESTAMP];
        [data setObject:type.identifier forKey:KEY_DATA_TYPE];
        [data setObject:[NSString stringWithFormat:@"%@", characteristicValue] forKey:KEY_VALUE];
        [data setObject:[self getDeviceId] forKey:KEY_DEVICE_ID];
        [data setObject:@"" forKey:KEY_SOURCE];
        [data setObject:@"" forKey:KEY_METADATA];
        [data setObject:@"" forKey:KEY_UNIT];
        [data setObject:@"" forKey:KEY_LABEL];

        // 存储数据
        [self.storage saveDataWithDictionary:data buffer:NO saveInMainThread:YES];

        // 记录最新数据
        NSString *message = [NSString stringWithFormat:@"[type: %@] [value: %@]", type.identifier, characteristicValue];
        [self setLatestValue:message];
        [self setLatestData:data];

        if (self.isDebug) NSLog(@"Saved characteristic data: %@", message);
    }
}


@end
