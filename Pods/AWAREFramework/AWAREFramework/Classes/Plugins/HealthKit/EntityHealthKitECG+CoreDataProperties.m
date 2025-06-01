//
//  EntityHealthKitECG+CoreDataProperties.m
//  AWAREFramework
//
//  Created by Xiaowen Lin on 3/5/25.
//
//

#import "EntityHealthKitECG+CoreDataProperties.h"

@implementation EntityHealthKitECG (CoreDataProperties)

+ (NSFetchRequest<EntityHealthKitECG *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EntityHealthKitECG"];
}

@dynamic device;
@dynamic device_id;
@dynamic label;
@dynamic metadata;
@dynamic source;
@dynamic timestamp_start;
@dynamic timestamp_end;
@dynamic sampling_frequency;
@dynamic classification;
@dynamic average_heart_rate;
@dynamic unit;
@dynamic voltages;
@dynamic timestamp;

@end
