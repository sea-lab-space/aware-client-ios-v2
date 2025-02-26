//
//  EntityHealthKitCharacteristic+CoreDataProperties.m
//  AWAREFramework
//
//  Created by Xiaowen Lin on 2/25/25.
//
//

#import "EntityHealthKitCharacteristic+CoreDataProperties.h"

@implementation EntityHealthKitCharacteristic (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitCharacteristic *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EntityHealthKitCharacteristic"];
}

@dynamic device_id;
@dynamic timestamp;
@dynamic type;
@dynamic value;
@dynamic source;
@dynamic metadata;
@dynamic unit;
@dynamic label;

@end
