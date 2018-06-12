//
//  EspUser.h
//  Esp32Mesh
//
//  Created by AE on 2018/1/3.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EspDevice.h"

@interface EspUser : NSObject {
    @private
    NSMutableDictionary<NSString *, EspDevice *> const *deviceDict;
    @private
    NSMutableDictionary<NSString *, id> const *cacheDict;
}

+ (instancetype)sharedInstance;

@property(nonatomic, assign) long uid;
@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *name;

- (void)clear;
- (BOOL)isLogged;
- (void)scanStations;
- (EspDevice *)getDeviceForMac:(NSString *)mac;
- (NSArray *)getAllDevices;

- (NSString *)putCache:(id)object;
- (id)takeCackeForKey:(NSString *)key;

@end
