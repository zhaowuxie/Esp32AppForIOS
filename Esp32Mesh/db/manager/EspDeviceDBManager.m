//
//  EspDeviceDBManager.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspDeviceDBManager.h"

static NSString * const EspEntityDevice = @"Device";

@implementation EspDeviceDBManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _context = _app.persistentContainer.viewContext;
    }
    return self;
}

- (NSArray<DeviceDB *> *)loadDeviceArray {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityDevice];
    return [self.context executeFetchRequest:request error:nil];
}

- (DeviceDB *)loadDeviceForMac:(NSString *)mac {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityDevice];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mac = %@", mac];
    request.predicate = predicate;
    request.fetchLimit = 1;
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    if (array.count > 0) {
        return array[0];
    } else {
        return nil;
    }
}

- (void)saveDevice:(EspDevice *)device {
    DeviceDB *db = [self loadDeviceForMac:device.mac];
    if (!db) {
        db = [NSEntityDescription insertNewObjectForEntityForName:EspEntityDevice inManagedObjectContext:self.context];
        db.mac = device.mac;
    }
    db.name = device.name;
    db.protocol = device.protocol;
    db.protocol_port = device.protocolPort;
    db.tid = device.typeId;
    db.version = device.currentRomVersion;
    
    [self.app saveContext];
}

- (void)deleteDeviceForMac:(NSString *)mac {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EspEntityDevice];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mac = %@", mac];
    request.predicate = predicate;
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    for (DeviceDB *db in array) {
        [self.context deleteObject:db];
    }
    
    [self.app saveContext];
}

@end
