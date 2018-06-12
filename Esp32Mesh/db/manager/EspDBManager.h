//
//  EspDBManager.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EspApDBManager.h"
#import "EspDeviceDBManager.h"
#import "EspUserDBManager.h"

@interface EspDBManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) EspApDBManager *ap;
@property (nonatomic, strong, readonly) EspDeviceDBManager *device;
@property (nonatomic, strong, readonly) EspUserDBManager *user;

@end


