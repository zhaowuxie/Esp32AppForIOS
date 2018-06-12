//
//  EspActionDeviceTopology.m
//  Esp32Mesh
//
//  Created by AE on 2018/2/28.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionDeviceTopology.h"
#import "EspDeviceUtil.h"
#import "EspHttpUtils.h"
#import "EspConstants.h"
#import "EspCommonUtils.h"

@implementation EspActionDeviceTopology

- (NSString *)getMeshInfoUrlForProtocol:(NSString *)protocol host:(NSString *)host port:(int)port {
    return [EspDeviceUtil getLocalUrlForProtocol:protocol host:host port:port file:@"/mesh_info"];
}

- (NSSet<EspDevice *> *)doActionGetMeshNodeForProtocol:(NSString *)protocol host:(NSString *)host port:(int)port {
    NSString *url = [self getMeshInfoUrlForProtocol:protocol host:host port:port];
    EspHttpParams *params = [[EspHttpParams alloc] init];
    params.tryCount = 3;
    
    NSMutableSet<EspDevice *> *result = [NSMutableSet set];
    
    while (YES) {
        EspHttpResponse *response = [EspHttpUtils getForUrl:url params:params headers:nil];
        if ([EspCommonUtils isNull:response]) {
            break;
        }
        
        if (response.code != 200) {
            break;
        }
        
        NSString *meshID;
        int nodeCount;
        NSArray<NSString *> *nodeMacs;
        @try {
            meshID = [response getHeaderValueForKey:EspHeaderMeshId];
            nodeCount = [[response getHeaderValueForKey:EspHeaderNodeNum] intValue];
            nodeMacs = [[response getHeaderValueForKey:EspHeaderNodeMac] componentsSeparatedByString:@","];
        } @catch (NSException *e) {
            NSLog(@"%@", e);
            break;
        }
        
        for(NSString *mac in nodeMacs) {
            EspDevice *node = [[EspDevice alloc] init];
            node.mac = mac;
            node.meshID = meshID;
            node.hostAddress = host;
            node.protocol = protocol;
            node.protocolPort = port;
            [node addState:EspDeviceStateLocal];
            
            [result addObject:node];
        }
        
        if (nodeCount == [nodeMacs count]) {
            break;
        }
    }
    
    return result;
}

@end
