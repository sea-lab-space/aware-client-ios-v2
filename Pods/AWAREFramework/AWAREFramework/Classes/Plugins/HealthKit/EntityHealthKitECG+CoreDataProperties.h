//
//  EntityHealthKitECG+CoreDataProperties.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/5/25.
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
@property (nonatomic) int16_t classification;
@property (nonatomic) double average_heart_rate;
@property (nullable, nonatomic, copy) NSString *unit;
@property (nullable, nonatomic, copy) NSString *voltages;
@property (nonatomic) double timestamp;

@end

NS_ASSUME_NONNULL_END
