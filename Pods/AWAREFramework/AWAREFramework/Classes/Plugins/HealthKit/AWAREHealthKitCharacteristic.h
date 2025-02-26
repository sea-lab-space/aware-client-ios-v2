//
//  AWAREHealthKitCharacteristic.h
//  AWARE
//
//  Created by Xiaowen Lin on 2025/02/25.
//

#import "AWARESensor.h"
#import "AWAREStorage.h"
#import <HealthKit/HealthKit.h>

@interface AWAREHealthKitCharacteristic : AWARESensor <AWARESensorDelegate>

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSSet<HKCharacteristicType *> *characteristicTypes;

- (instancetype)initWithAwareStudy:(AWAREStudy *)study
                            dbType:(AwareDBType)dbType
               characteristicTypes:(NSSet<HKCharacteristicType *> *)characteristicTypes;

- (void)fetchAndSaveCharacteristicData;
@end
