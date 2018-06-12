//
//  BLEDevice.h
//  益家人
//
//  Created by zhi weijian on 16/6/1.
//  Copyright © 2016年 zhi weijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//蓝牙设备模型,包括蓝牙名称和蓝牙信息
@interface BLEDevice : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,strong)CBPeripheral *Peripheral;
@property(nonatomic,copy)NSNumber *RSSI;
@property(nonatomic,assign)BOOL select;
@property(nonatomic,assign)BOOL firstbool;
@property(nonatomic,copy)NSData *MACAddress;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)CBCharacteristic *WriteCharacteristic;
@property(nonatomic,strong)CBCharacteristic *NotifyCharacteristic;
@property(nonatomic,assign)NSInteger sequence;
@property(nonatomic,strong)NSData *Securtkey;
@property(nonatomic,strong)NSData *senddata;
@property(nonatomic,assign)BOOL blufisuccess;
@property(nonatomic,strong)NSTimer *connecttimer;
@property(nonatomic,strong)NSTimer *blufitimer;
@end
