//
//  EspDeviceDBManager.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "DeviceDB+CoreDataClass.h"
#import "EspDevice.h"

@interface EspDeviceDBManager : NSObject

@property (nonatomic, weak, readonly) AppDelegate *app;
@property (nonatomic, weak, readonly) NSManagedObjectContext *context;

- (NSArray<DeviceDB *> *)loadDeviceArray;
- (void)saveDevice:(EspDevice *)device;
- (void)deleteDeviceForMac:(NSString *)mac;

@end
