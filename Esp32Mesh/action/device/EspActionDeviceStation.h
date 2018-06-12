//
//  EspActionDeviceStation.h
//  Esp32Mesh
//
//  Created by AE on 2018/1/4.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EspConstants.h"
#import "EspActionDevice.h"
#import "EspDevice.h"

static NSString * const EspMDNSTypeHttp = @"_mesh-http._tcp.";
static NSString * const EspMDNSTypeHttps = @"_mesh-https._tcp.";
static NSString * const EspMDNSDomain = @"local.";

static NSString * const EspProtocolHttp = @"http";
static NSString * const EspProtocolHttps = @"https";

@interface EspActionDeviceStation : EspActionDevice

- (NSSet<EspDevice *> *) doActionScanStation;

@end
