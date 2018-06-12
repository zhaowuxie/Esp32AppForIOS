//
//  UserDB+CoreDataProperties.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "UserDB+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserDB (CoreDataProperties)

+ (NSFetchRequest<UserDB *> *)fetchRequest;

@property (nonatomic) int64_t uid;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *key;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *password;

@end

NS_ASSUME_NONNULL_END
