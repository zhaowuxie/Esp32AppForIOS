//
//  ESPUDPUtils.h
//  Esp32Mesh
//
//  Created by zhaobing on 2018/6/12.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface ESPUDPUtils : NSObject<GCDAsyncUdpSocketDelegate>{
    //udp对象
    GCDAsyncUdpSocket *udpCLientSoket;
}

@end
