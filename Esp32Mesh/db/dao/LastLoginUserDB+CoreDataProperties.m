//
//  LastLoginUserDB+CoreDataProperties.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "LastLoginUserDB+CoreDataProperties.h"

@implementation LastLoginUserDB (CoreDataProperties)

+ (NSFetchRequest<LastLoginUserDB *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"LastLoginUser"];
}

@dynamic user_id;

@end
