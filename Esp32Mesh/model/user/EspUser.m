//
//  EspUser.m
//  Esp32Mesh
//
//  Created by AE on 2018/1/3.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspUser.h"
#import "EspActionDeviceStation.h"
#import "EspTextUtil.h"

static EspUser *_instance;

@implementation EspUser

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    
    return _instance;
}

+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.uid = -1l;
        self.key = nil;
        self.email = nil;
        self.name = nil;
        
        deviceDict = [NSMutableDictionary dictionary];
        cacheDict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)clear {
    self.uid = -1l;
    self.key = nil;
    self.email = nil;
    self.name = nil;
    @synchronized(deviceDict) {
        [deviceDict removeAllObjects];
    }
}

- (BOOL)isLogged {
    return [EspTextUtil isEmpty:self.key];
}

- (void)scanStations {
    EspActionDeviceStation *action = [[EspActionDeviceStation alloc] init];
    NSSet<EspDevice *> *stations = [action doActionScanStation];
    [self updateDevices:stations];
}

- (EspDevice *)getDeviceForMac:(NSString *)mac {
    @synchronized(deviceDict) {
        return [deviceDict valueForKey:mac];
    }
}

- (NSArray *)getAllDevices {
    @synchronized(deviceDict) {
        return [deviceDict allValues];
    }
}

- (void)updateDevices:(NSSet<EspDevice *> *)devices {
    @synchronized(deviceDict) {
        [deviceDict removeAllObjects];
        for (EspDevice *device in devices) {
            [deviceDict setObject:device forKey:device.mac];
        }
    }
}

- (NSString *)putCache:(id)object {
    return nil;
}

- (id)takeCackeForKey:(NSString *)key {
    return nil;
}
@end
