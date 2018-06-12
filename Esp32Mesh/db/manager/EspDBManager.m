//
//  EspDBManager.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspDBManager.h"
#import "AppDelegate.h"

static EspDBManager *_instance;

@interface EspDBManager ()

@end

@implementation EspDBManager

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
        _ap = [[EspApDBManager alloc] init];
        _device = [[EspDeviceDBManager alloc] init];
        _user = [[EspUserDBManager alloc] init];
    }
    
    return self;
}

@end
