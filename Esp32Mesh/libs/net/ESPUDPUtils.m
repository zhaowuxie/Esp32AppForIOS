//
//  ESPUDPUtils.m
//  Esp32Mesh
//
//  Created by zhaobing on 2018/6/12.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "ESPUDPUtils.h"
#import "EspNetUtils.h"

@interface ESPUDPUtils()<GCDAsyncUdpSocketDelegate>
@property (strong, nonatomic)GCDAsyncUdpSocket * udpCLientSoket;
@end
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _udpCLientSoket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:queue];
    NSError * error = nil;
    [_udpCLientSoket bindToPort:udpPort error:&error];
    [_udpCLientSoket enableBroadcast:true error:nil];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
        [_udpCLientSoket beginReceiving:&error];
    }
  
    
    //开启定时发送请求设备信息
    timer =  [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendMsg) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void) sendMsg {

    NSString *s = @"Are You Espressif IOT Smart Device?";
    NSData *data = [s dataUsingEncoding:NSUTF8StringEncoding];
    [_udpCLientSoket sendData:data toHost:udpHost port:udpPort withTimeout:-1 tag:0];
}
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
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
            NSLog(@"[%@:%u]",deviceAddress, port);
            NSLog(@"%@",s);
            //回掉或者获取根节点下的其它所有设备信息http
            
        }
        
    }
    
    
}

-(void)dealloc{
    NSLog(@"%s",__func__ );
    [_udpCLientSoket close];
    _udpCLientSoket = nil;
    
    //取消定时器
    [timer invalidate];
    timer = nil;
}
@end
