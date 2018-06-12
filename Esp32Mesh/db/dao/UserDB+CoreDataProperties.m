//
//  UserDB+CoreDataProperties.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "UserDB+CoreDataProperties.h"

@implementation UserDB (CoreDataProperties)

+ (NSFetchRequest<UserDB *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic uid;
@dynamic name;
@dynamic key;
@dynamic email;
@dynamic password;

@end
