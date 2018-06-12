//
//  EspCharacteristicViewHolder.m
//  Esp32Mesh
//
//  Created by AE on 2018/3/23.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspCharacteristicViewHolder.h"
#import "EspTextUtil.h"
#import "EspActionDeviceInfo.h"

@implementation EspCharacteristicViewHolder

- (void)onButtonClick {
    NSLog(@"Holder OnClick %@", self.textView.text);
    NSString *valueStr = self.textView.text;
    if ([EspTextUtil isEmpty:valueStr]) {
        return;
    }
    
    NSString *format = self.characteristic.format;
    EspDeviceCharacteristic *newC = [EspDeviceCharacteristic newInstance:format];
    newC.cid = self.characteristic.cid;
    if ([format isEqualToString:EspFormatInt]) {
        int valueInt = [valueStr intValue];
        newC.value = [NSNumber numberWithInt:valueInt];
    } else if ([format isEqualToString:EspFormatDouble]) {
        double valueDouble = [valueStr doubleValue];
        newC.value = [NSNumber numberWithDouble:valueDouble];
    } else if ([format isEqualToString:EspFormatString] ||
               [format isEqualToString:EspFormatJson]) {
        newC.value = [NSString stringWithString:valueStr];
    }
    
    self.button.enabled = NO;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        EspActionDeviceInfo *action = [[EspActionDeviceInfo alloc] init];
        NSArray *array = [NSArray arrayWithObject:newC];
        [action doActionSetDeviceStatusLocal:self.device forCharacteristics:array];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.button.enabled = YES;
        }];
    }];
}

@end
