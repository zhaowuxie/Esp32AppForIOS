//
//  EspBlufiSettingsViewController.h
//  Esp32Mesh
//
//  Created by AE on 2018/4/18.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"

@interface EspBlufiSettingsViewController : UIViewController

@property(nonatomic, strong) CBCentralManager *bleManager;
@property(nonatomic, strong) BLEDevice *device;

@end
