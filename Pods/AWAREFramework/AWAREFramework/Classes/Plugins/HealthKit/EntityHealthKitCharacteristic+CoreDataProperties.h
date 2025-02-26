//
//  EntityHealthKitCharacteristic+CoreDataProperties.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 2/25/25.
//
//

#import "EntityHealthKitCharacteristic+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EntityHealthKitCharacteristic (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitCharacteristic *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *device_id;
@property (nonatomic) double timestamp;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *value;
@property (nullable, nonatomic, copy) NSString *source;
@property (nullable, nonatomic, copy) NSString *metadata;
@property (nullable, nonatomic, copy) NSString *unit;
@property (nullable, nonatomic, copy) NSString *label;

@end

NS_ASSUME_NONNULL_END
