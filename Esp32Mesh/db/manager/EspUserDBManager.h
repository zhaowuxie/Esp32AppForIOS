//
//  EspUserDBManager.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UserDB+CoreDataClass.h"
#import "LastLoginUserDB+CoreDataClass.h"

@interface EspUserDBManager : NSObject

@property (nonatomic, weak, readonly) AppDelegate *app;
@property (nonatomic, weak, readonly) NSManagedObjectContext *context;

- (void)saveUserId:(long)uid key:(NSString *)key name:(NSString *)name email:(NSString *)email password:(NSString *)password;

- (void)saveLastLoginUserId:(long)uid;
- (UserDB *)loadLastLoginUser;
- (void)deleteLastLoginUser;

@end
