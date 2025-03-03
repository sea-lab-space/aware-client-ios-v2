//
//  EntityHealthKitClinical+CoreDataProperties.h
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/3/25.
//
//

#import "EntityHealthKitClinical+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EntityHealthKitClinical (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitClinical *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *device;
@property (nullable, nonatomic, copy) NSString *device_id;
@property (nullable, nonatomic, copy) NSString *fhirResource;
@property (nullable, nonatomic, copy) NSString *source;
@property (nonatomic) double timestamp;
@property (nullable, nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
