//
//  EspCharacteristicViewHolder.h
//  Esp32Mesh
//
//  Created by AE on 2018/3/23.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EspDeviceCharacteristic.h"
#import "EspDevice.h"

@interface EspCharacteristicViewHolder : NSObject

@property(nonatomic, strong) EspDevice *device;
@property(nonatomic, strong) EspDeviceCharacteristic *characteristic;

@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) UIButton *button;

- (void)onButtonClick;

@end
