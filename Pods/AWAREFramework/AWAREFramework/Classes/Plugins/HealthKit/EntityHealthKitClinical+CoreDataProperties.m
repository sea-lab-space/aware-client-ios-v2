//
//  EntityHealthKitClinical+CoreDataProperties.m
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/3/25.
//
//

#import "EntityHealthKitClinical+CoreDataProperties.h"

@implementation EntityHealthKitClinical (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitClinical *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EntityHealthKitClinical"];
}

@dynamic device;
@dynamic device_id;
@dynamic fhirResource;
@dynamic source;
@dynamic timestamp;
@dynamic type;

@end
