//
//  EntityHealthKitECG+CoreDataProperties.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/1/25.
//
//

#import "EntityHealthKitECG+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EntityHealthKitECG (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitECG *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *device;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSString *metadata;
@property (nullable, nonatomic, copy) NSString *source;
@property (nonatomic) double timestamp_start;
@property (nonatomic) double timestamp_end;
@property (nonatomic) double sampling_frequency;
@property (nullable, nonatomic, copy) NSString *classification;
@property (nonatomic) double average_heart_rate;
@property (nullable, nonatomic, copy) NSString *unit;
@property (nullable, nonatomic, copy) NSString *voltages;

@end

NS_ASSUME_NONNULL_END
