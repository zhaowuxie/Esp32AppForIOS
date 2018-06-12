//
//  EspOTAViewController.h
//  Esp32Mesh
//
//  Created by AE on 2018/4/24.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EspDevice.h"

@interface EspOTAViewController : UIViewController

@property (strong, nonatomic) NSArray<EspDevice *> *devices;

@end
