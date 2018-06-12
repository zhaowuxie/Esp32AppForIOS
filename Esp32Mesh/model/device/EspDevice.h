//
//  EspDevice.h
//  Esp32Mesh
//
//  Created by AE on 2018/1/3.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EspDeviceCharacteristic.h"

static const int EspMeshLayerRoot = 1;
static const int EspMeshLayerUnknow = -1;

@interface EspDevice : NSObject {
    @private
    NSMutableDictionary<NSNumber*, EspDeviceCharacteristic*> const *characters;
    @private
    int stateValue;
}

@property(nonatomic, strong) NSString *key;
@property(nonatomic, strong) NSString *mac;
@property(nonatomic, strong) NSString *currentRomVersion;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) int typeId;
@property(nonatomic, strong) NSString *typeName;
@property(nonatomic, strong) NSString *hostAddress;
@property(nonatomic, strong) NSString *parentDeviceMac;
@property(nonatomic, strong) NSString *rootDeviceMac;
@property(nonatomic, assign) int meshLayerLevel;
@property(nonatomic, strong) NSString *meshID;
@property(nonatomic, strong) NSString *protocol;
@property(nonatomic, assign) int protocolPort;

typedef enum {
    EspDeviceStateIDLE,
    EspDeviceStateOfflice,
    EspDeviceStateLocal,
    EspDeviceStateCloud,
    EspDeviceStateUpgradeLocal,
    EspDeviceStateUpgradeCloud,
    EspDeviceStateDeleted,
}EspDeviceState;

- (void)addState:(EspDeviceState)state;
- (void)removeState:(EspDeviceState)state;
- (void)clearState;
- (BOOL)isState:(EspDeviceState)state;
- (EspDeviceCharacteristic *)getCharacteristicForCid:(int)cid;
- (NSArray<EspDeviceCharacteristic *> *)getCharacteristics;
- (void)addOrReplaceCharacteristic:(EspDeviceCharacteristic *)characteristic;
- (void)addOrReplaceCharacteristics:(NSArray<EspDeviceCharacteristic *> *)characteristics;
- (void)removeCharacteristicForCid:(int)cid;
- (void)clearCharacteristics;
- (void)notifyStatusChanged;

@end
