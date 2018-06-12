//
//  ApDB+CoreDataProperties.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/14.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "ApDB+CoreDataProperties.h"

@implementation ApDB (CoreDataProperties)

+ (NSFetchRequest<ApDB *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Ap"];
}

@dynamic ssid;
@dynamic password;

@end
