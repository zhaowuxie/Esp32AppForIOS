//
//  EspBlufiConfigureViewController.h
//  Esp32Mesh
//
//  Created by AE on 2018/4/19.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"

@interface EspBlufiConfigureViewController : UITableViewController

@property(nonatomic, strong) CBCentralManager *bleManager;
@property(nonatomic, strong) BLEDevice *device;
@property(nonatomic, strong) NSString *ssid;
@property(nonatomic, strong) NSString *password;

@end
