//
//  AWAREHealthKitECG.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/1/25.
//

#import "AWARESensor.h"
#import <HealthKit/HealthKit.h>

@interface AWAREHealthKitECG : AWARESensor
@property (nonatomic, strong, nonnull) HKHealthStore *healthStore;


NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithAwareStudy:(AWAREStudy * _Nullable)study
                            dbType:(AwareDBType)dbType
                        sensorName:(NSString * _Nullable)sensorName
                        entityName:(NSString * _Nullable)entityName;

- (void)saveECGData:(NSArray <HKElectrocardiogram *> * _Nonnull)data API_AVAILABLE(ios(14.0));

NS_ASSUME_NONNULL_END

@end
