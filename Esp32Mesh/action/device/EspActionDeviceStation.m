//
//  EspActionDeviceStation.m
//  Esp32Mesh
//
//  Created by AE on 2018/1/4.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionDeviceStation.h"
#import <arpa/inet.h>
#import "EspTextUtil.h"
#import "EspActionDeviceTopology.h"

@interface EspMdnsDelegate : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSMutableSet *devices;
}

@end

@implementation EspMdnsDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        devices = [NSMutableSet set];
    }
    return self;
}

- (NSSet<EspDevice *> *)getDevices {
    return devices;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"didNotSearch");
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    NSLog(@"didFindService: %@, %@", [netService name], [netService type]);
    netService.delegate = self;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [netService scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
    [netService resolveWithTimeout:1.0f];
    [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
    netService.delegate = nil;
    NSLog(@"didFindService over");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"didNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSString *name = sender.name;
    NSString *type = sender.type;
    NSString *hostName = sender.hostName;
    int port = (int)sender.port;
    NSString *hostAddr;
    
    NSData *addrData = [sender.addresses firstObject];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [addrData bytes];
    char *cAddrStr = inet_ntoa(socketAddress->sin_addr);
    hostAddr = [NSString stringWithUTF8String:cAddrStr];
    
    NSLog(@"netServiceDidResolveAddress name=%@, type=%@, host=%@, address=%@", name, type, hostName, hostAddr);
    
    NSDictionary *attrs = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]];
    NSData *macData = attrs[EspKeyMac];
    if (macData == nil) {
        return;
    }
    
    NSString *mac = [[NSString alloc] initWithData:macData encoding:NSUTF8StringEncoding];
    
    EspDevice *device = [[EspDevice alloc] init];
    device.mac = mac;
    device.protocolPort = port;
    device.hostAddress = hostAddr;
    if ([type isEqualToString:EspMDNSTypeHttp]) {
        device.protocol = EspProtocolHttp;
    } else if ([type isEqualToString:EspMDNSTypeHttps]) {
        device.protocol = EspProtocolHttps;
    } else {
        // Unsupport protocol
        return;
    }
    
    [devices addObject:device];
}

@end

@implementation EspActionDeviceStation

- (NSSet<EspDevice *> *) doActionScanStation {
    NSSet<EspDevice *> *rootDevices = [self scanMDNS];
    NSSet<EspDevice *> *result = [self scanTopoForRootNode:rootDevices];
    return result;
}

- (NSSet<EspDevice *> *) scanMDNS {
    NSLog(@"Scan MDNS start");
    NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
    EspMdnsDelegate *mdnsDelegate = [[EspMdnsDelegate alloc] init];
    browser.delegate = mdnsDelegate;
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [browser scheduleInRunLoop:runLoop forMode:NSRunLoopCommonModes];
    [browser searchForServicesOfType:EspMDNSTypeHttp inDomain:EspMDNSDomain];
    [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
    [browser stop];
    browser.delegate = nil;
    NSLog(@"Scan MDNS end");
    
    NSMutableSet *result = [NSMutableSet set];
    [result setSet:[mdnsDelegate getDevices]];
    return result;
}

- (NSSet<EspDevice *> *) scanTopoForRootNode:(NSSet<EspDevice *> *)rootNodes {
    NSMutableSet<EspDevice *> *result = [NSMutableSet set];
    
    EspActionDeviceTopology *topoAction = [[EspActionDeviceTopology alloc] init];
    for (EspDevice *device in rootNodes) {
        NSSet<EspDevice *> *topoDevices = [topoAction doActionGetMeshNodeForProtocol:device.protocol host:device.hostAddress port:device.protocolPort];
        for (EspDevice *node in topoDevices) {
            node.rootDeviceMac = device.mac;
        }
        
        for (EspDevice *topoDev in topoDevices) {
            [result addObject:topoDev];
        }
    }
    
    return result;
}

@end
