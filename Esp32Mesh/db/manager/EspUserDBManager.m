//
//  EspUserDBManager.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspUserDBManager.h"

static NSString * const EspEntityUser = @"User";
static NSString * const EspEntityLastLoginUser = @"LastLoginUser";

@implementation EspUserDBManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = _app.persistentContainer.viewContext;
    }
    return self;
}

- (void)saveUserId:(long)uid key:(NSString *)key name:(NSString *)name email:(NSString *)email password:(NSString *)password {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %ld", uid];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    UserDB *db = array.count > 0 ? array[0] : [NSEntityDescription insertNewObjectForEntityForName:EspEntityUser inManagedObjectContext:self.context];
    db.uid = uid;
    db.key = key;
    db.name = name;
    db.email = email;
    db.password = password;
    
    [self.app saveContext];
}

- (void)saveLastLoginUserId:(long)uid {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityLastLoginUser];
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    LastLoginUserDB *db = array.count > 0 ? array[0] : [NSEntityDescription insertNewObjectForEntityForName:EspEntityLastLoginUser inManagedObjectContext:self.context];
    db.user_id = uid;
    
    [self.app saveContext];
}

- (UserDB *)loadLastLoginUser {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityLastLoginUser];
    NSArray<LastLoginUserDB *> *lastLogins = [self.context executeFetchRequest:request error:nil];
    if (lastLogins.count == 0) {
        return nil;
    }
    
    request = [NSFetchRequest fetchRequestWithEntityName:EspEntityUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %ld", lastLogins[0].user_id];
    request.predicate = predicate;
    request.fetchLimit = 1;
    NSArray *userDBs = [self.context executeFetchRequest:request error:nil];
    return userDBs.count > 0 ? userDBs[0] : nil;
}

- (void)deleteLastLoginUser {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityLastLoginUser];
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    for (LastLoginUserDB *db in array) {
        [self.context deleteObject:db];
    }
    
    [self.app saveContext];
}

@end
