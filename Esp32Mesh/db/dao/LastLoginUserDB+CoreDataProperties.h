//
//  LastLoginUserDB+CoreDataProperties.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "LastLoginUserDB+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface LastLoginUserDB (CoreDataProperties)

+ (NSFetchRequest<LastLoginUserDB *> *)fetchRequest;

@property (nonatomic) int64_t user_id;

@end

NS_ASSUME_NONNULL_END
