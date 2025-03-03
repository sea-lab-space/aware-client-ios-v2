//
//  AWAREHealthKitClinical.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/3/25.
//

#import "AWARESensor.h"
#import <HealthKit/HealthKit.h>

@interface AWAREHealthKitClinical : AWARESensor

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithAwareStudy:(AWAREStudy * _Nullable)study
                            dbType:(AwareDBType)dbType
                        sensorName:(NSString * _Nullable)sensorName
                        entityName:(NSString * _Nullable)entityName;

- (void)saveClinicalData:(NSArray<HKClinicalRecord *> * _Nonnull)data;

NS_ASSUME_NONNULL_END

@end
