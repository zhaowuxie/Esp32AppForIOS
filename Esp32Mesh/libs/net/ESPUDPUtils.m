//
//  ESPUDPUtils.m
//  Esp32Mesh
//
//  Created by zhaobing on 2018/6/12.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "ESPUDPUtils.h"
#import "EspNetUtils.h"


#define udpPort 1025
#define udpHost @"255.255.255.255"

@implementation ESPUDPUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUdpSocket];
    }
    return self;
}
-(void) createUdpSocket{
    udpCLientSoket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    [udpCLientSoket bindToPort:udpPort error:&error];
    [udpCLientSoket enableBroadcast:true error:nil];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
        [udpCLientSoket beginReceiving:&error];
    }
}
- (void) sendMsg {
    NSString *s = @"Are You Espressif IOT Smart Device?";
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    //开始发送
    //改函数只是启动一次发送 它本身不进行数据的发送, 而是让后台的线程慢慢的发送 也就是说这个函数调用完成后,数据并没有立刻发送,异步发送
    [udpCLientSoket sendData:data toHost:udpHost port:udpPort withTimeout:-1 tag:100];
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContex
{
    //取得发送发的ip和端口

    NSString *ip = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSString *deviceAddress=[ip componentsSeparatedByString:@":"].lastObject;
    NSString *curDevice=[EspNetUtils.getIPAddresses objectForKey:@"en0/ipv4"];
    //data就是接收的数据
    if ([deviceAddress isEqualToString:curDevice]==false) {//不是当前设备发的消息
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([s containsString:@"ESP32 Mesh"]) {
            NSLog(@"[%@:%u]%@",deviceAddress, port,s);
            //回掉或者获取根节点下的其它所有设备信息http
            
        }
        
    }
    
    
}

-(void)dealloc{
    NSLog(@"%s",__func__ );
    [udpCLientSoket close];
    udpCLientSoket = nil;
}
@end
