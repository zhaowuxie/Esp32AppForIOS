//
//  DeviceDB+CoreDataProperties.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/14.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "DeviceDB+CoreDataProperties.h"

@implementation DeviceDB (CoreDataProperties)

+ (NSFetchRequest<DeviceDB *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Device"];
}

@dynamic mac;
@dynamic name;
@dynamic protocol;
@dynamic protocol_port;
@dynamic tid;
@dynamic version;

@end
