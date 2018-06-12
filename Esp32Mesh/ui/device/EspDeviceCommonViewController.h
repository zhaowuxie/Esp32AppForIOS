//
//  EspDeviceCommonViewController.h
//  Esp32Mesh
//
//  Created by AE on 2018/3/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EspDevice.h"

@interface EspDeviceCommonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postAllItem;

@property(nonatomic, strong) EspDevice *device;

- (IBAction)onRefreshItemClick:(id)sender;
- (IBAction)onPostAllItemClick:(id)sender;


@end
