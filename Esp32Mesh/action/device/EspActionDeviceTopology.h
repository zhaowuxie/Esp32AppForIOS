//
//  EspActionDeviceTopology.h
//  Esp32Mesh
//
//  Created by AE on 2018/2/28.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionDevice.h"
#import "EspDevice.h"

@interface EspActionDeviceTopology : EspActionDevice

- (NSSet<EspDevice *> *)doActionGetMeshNodeForProtocol:(NSString *)protocol host:(NSString *)host port: (int)port;

@end
