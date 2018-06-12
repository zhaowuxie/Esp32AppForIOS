//
//  EspApDBManager.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspApDBManager.h"

static NSString * const EspEntityAp = @"Ap";

@implementation EspApDBManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = _app.persistentContainer.viewContext;
    }
    return self;
}

- (ApDB *)loadApForSsid:(NSString *)ssid {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityAp];
    NSPredicate *pedicate = [NSPredicate predicateWithFormat:@"ssid = %@", ssid];
    request.predicate = pedicate;
    request.fetchLimit = 1;
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    if (array.count > 0) {
        return array[0];
    } else {
        return nil;
    }
}

- (NSArray<ApDB *> *)loadApArray {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityAp];
    return [self.context executeFetchRequest:request error:nil];
}

- (void)saveApSsid:(NSString *)ssid password:(NSString *)password {
    ApDB *db = [self loadApForSsid:ssid];
    if (!db) {
        db = [NSEntityDescription insertNewObjectForEntityForName:EspEntityAp  inManagedObjectContext:self.context];
        db.ssid = ssid;
    }
    db.password = password;
    
    [self.app saveContext];
}

- (void)deleteApForSsid:(NSString *)ssid {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityAp];
    NSPredicate *pedicate = [NSPredicate predicateWithFormat:@"ssid = %@", ssid];
    request.predicate = pedicate;
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    for (ApDB *db in array) {
        [self.context deleteObject:db];
    }
    
    [self.app saveContext];
}

@end
