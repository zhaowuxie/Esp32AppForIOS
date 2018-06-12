//
//  EspBlufiConfigureViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/4/19.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspBlufiConfigureViewController.h"
#import "EspConstants.h"
#import "EspCommonUtils.h"
#import "BLEDevice.h"
#import "UUID.h"
#import "PacketCommand.h"
#import "DH_AES.h"
#import "WifiInforObject.h"

@interface EspBlufiConfigureViewController () <CBCentralManagerDelegate, CBPeripheralDelegate> {
@private
    CBCharacteristic *writeChar;
@private
    CBCharacteristic *notifyChar;
@private
    NSMutableArray<NSString *> *msgArray;
@private
    BOOL requireWifiState;
}

@property(nonatomic,strong) RSAObject *rsaobject;
@property(nonatomic,assign) uint8_t channel;

@property(nonatomic, strong) UIButton *retryButton;

@end

@implementation EspBlufiConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    requireWifiState = YES;
    
    msgArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = 20;
    self.retryButton.frame = CGRectMake(0, 10, buttonWidth, buttonHeight);
    [self.retryButton addTarget:self action:@selector(onRetryClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = self.retryButton;
    
    self.bleManager.delegate = self;
    
    [self connectBLE];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self disconnectBLE];
    [self.navigationController popToRootViewControllerAnimated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [msgArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"MessageIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *message = msgArray[indexPath.row];
    cell.textLabel.text = message;
    
    return cell;
}

- (void)updateMessage:(NSString *)message {
    [msgArray addObject:message];
    [self.tableView reloadData];
}

- (void)disconnectBLE {
    NSLog(@"dsiconnectBLE");
    [self.bleManager cancelPeripheralConnection:self.device.Peripheral];
}

- (void)connectBLE {
    self.retryButton.enabled = NO;
    [self updateMessage:@"Try connect device"];
    [self.bleManager connectPeripheral:self.device.Peripheral options:nil];
}

- (IBAction)onRetryClick:(id)sender {
    [self connectBLE];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [self updateMessage:@"BLE enable"];
            break;
        case CBManagerStateUnknown:
        case CBManagerStatePoweredOff:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
        default:
            [self updateMessage:@"BLE disable"];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"BLE connected %@", peripheral.name);
    self.device.Peripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    [self updateMessage:[NSString stringWithFormat:@"Connect %@", peripheral.name]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"BLE fail connect %@", peripheral.name);
    [self updateMessage:[NSString stringWithFormat:@"Connect %@ failed", peripheral.name]];
    self.retryButton.enabled = YES;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"BLE disconnect %@", peripheral.name);
    peripheral.delegate = nil;
    writeChar = nil;
    notifyChar = nil;
    
    [self updateMessage:[NSString stringWithFormat:@"Disconnect %@", peripheral.name]];
    self.retryButton.enabled = YES;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        NSLog(@"BLE didDiscoverServices");
        [self updateMessage:@"Discover services"];
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqualToString:EspBlufiUUIDService]) {
                [self updateMessage:@"Discover blufi service"];
                [peripheral discoverCharacteristics:nil forService:service];
                break;
            }
        }
    } else {
        NSLog(@"BLE service error %@", error);
        [self updateMessage:@"Discover services error"];
        [self disconnectBLE];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"BLE didDiscoverCharacteristicsForService");
        [self updateMessage:@"Discover characteristics"];
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:EspBlufiUUIDWrite]) {
                NSLog(@"BLE get write char");
                writeChar = characteristic;
                [self updateMessage:@"Discover write characteristic"];
                self.device.WriteCharacteristic = characteristic;
            } else if ([characteristic.UUID.UUIDString isEqualToString:EspBlufiUUIDNotify]) {
                NSLog(@"BLE get notify char");
                notifyChar = characteristic;
                [self updateMessage:@"Discover notify characteristic"];
                self.device.NotifyCharacteristic = characteristic;
                // Subscribe notification
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    } else {
        NSLog(@"BLE characteristic error %@", error);
        [self updateMessage:@"Discover characteristics error"];
        [self disconnectBLE];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if (characteristic.isNotifying) {
            NSLog(@"BLE set notify success");
            [self updateMessage:@"Set notification success"];
            
            [self SendNegotiateDataWithDevice:self.device];
        } else {
            NSLog(@"BLE set notify failed");
            [self updateMessage:@"Set notification failed"];
            [self disconnectBLE];
        }
    } else {
        NSLog(@"BLE update notification error %@", error);
        [self updateMessage:@"Notification state error"];
        [self disconnectBLE];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        [self analyseData:[NSMutableData dataWithData:characteristic.value] device:self.device];
    } else {
        NSLog(@"BLE notification error %@", error);
        [self updateMessage:@"Notification error"];
        [self disconnectBLE];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"BLE write error %@", error);
        [self updateMessage:@"Write value error"];
        [self disconnectBLE];
    }
}

- (void)writeStructDataWithDevice:(BLEDevice *)device WithData:(NSData *)data {
    if (device.Peripheral && device.WriteCharacteristic) {
        [device.Peripheral writeValue:data forCharacteristic:device.WriteCharacteristic type:CBCharacteristicWriteWithResponse];
        device.sequence = device.sequence + 1;
    } else {
        [self updateMessage:@"peripheral write characteristic nil"];
        [self disconnectBLE];
    }
}

- (void)analyseData:(NSMutableData *)data device:(BLEDevice *)device {
    Byte *dataByte = (Byte *)[data bytes];
    Byte Type = dataByte[0] & 0x03;
    Byte sequence = dataByte[2];
    Byte frameControl = dataByte[1];
    Byte length = dataByte[3];
    BOOL hash = frameControl & Packet_Hash_FrameCtrlType;
    BOOL checksum = frameControl & Data_End_Checksum_FrameCtrlType;
    //BOOL Drection=frameControl & Data_Direction_FrameCtrlType;
    BOOL Ack=frameControl & ACK_FrameCtrlType;
    BOOL AppendPacket=frameControl & Append_Data_FrameCtrlType;
    if (hash) {
        //zwjLog(@"加密");
        //解密
        NSRange range = NSMakeRange(4, length);
        NSData *Decryptdata = [data subdataWithRange:range];
        Byte *byte = (Byte *)[Decryptdata bytes];
        Decryptdata = [DH_AES blufi_aes_DecryptWithSequence:sequence data:byte len:length KeyData:device.Securtkey];
        [data replaceBytesInRange:range withBytes:[Decryptdata bytes]];
    } else {
        //zwjLog(@"无加密");
    }
    if (checksum) {
        //zwjLog(@"有校验");
        //计算校验
        if ([PacketCommand VerifyCRCWithData:data]) {
            //zwjLog(@"校验成功");
        } else {
            NSLog(@"校验失败,返回");
            [self updateMessage:@"CRC error"];
            [self disconnectBLE];
            return;
        }
    } else {
        //zwjLog(@"无校验");
    }
    if (Ack) {
        //zwjLog(@"回复ACK");
        [self writeStructDataWithDevice:device WithData:[PacketCommand ReturnAckWithSequence:device.sequence BackSequence:sequence] ];
    } else {
        //zwjLog(@"不回复ACK");
    }
    if (AppendPacket) {
        //zwjLog(@"有后续包");
    } else {
        //zwjLog(@"没有后续包");
    }
    
    if (Type == ContolType) {
        //zwjLog(@"接收到控制包===========");
        [self GetControlPacketWithData:data device:device];
    } else if (Type==DataType) {
        //zwjLog(@"接收到数据包===========");
        [self GetDataPackectWithData:data device:device];
    } else if (Type == UserType){
        //自定义用户包
        [self GetUserPacketWithData:data device:device];
    } else {
        NSLog(@"异常数据包");
        [self updateMessage:@"Data error"];
        [self disconnectBLE];
    }
}

//用户包解析
-(void)GetUserPacketWithData:(NSData *)data device:(BLEDevice *)device {
    Byte *dataByte = (Byte *)[data bytes];
    Byte SubType=dataByte[0]>>2;
    switch (SubType) {
        case 0x00:
            self.channel=dataByte[4];
            if (device.index == 1) {
                //连接wifi
                [self writeStructDataWithDevice:device WithData:[PacketCommand ConnectToAPWithSequence:device.sequence]];
            }
        default:
            break;
    }
}

//控制包解析
-(void)GetControlPacketWithData:(NSData *)data device:(BLEDevice *)device {
    Byte *dataByte = (Byte *)[data bytes];
    Byte SubType=dataByte[0]>>2;
    switch (SubType) {
        case ACK_Esp32_Phone_ControlSubType:
            NSLog(@"Receive ACK ,%@", device.name);
            device.blufisuccess = YES;
            [self updateMessage:@"Post configure data complete"];
            if (!requireWifiState) {
                [self disconnectBLE];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
        case ESP32_Phone_Security_ControlSubType:
        case Wifi_Op_ControlSubType:
        case Connect_AP_ControlSubType:
        case Disconnect_AP_ControlSubType:
        case Get_Wifi_Status_ControlSubType:
        case Deauthenticate_STA_Device_SoftAP_ControlSubType:
        case Get_Version_ControlSubType:
        case Negotiate_Data_ControlSubType:
            break;
        default:
            break;
    }
}

//数据包解析
-(void)GetDataPackectWithData:(NSData *)data device:(BLEDevice *)device {
    Byte *dataByte = (Byte *)[data bytes];
    Byte SubType = dataByte[0] >> 2;
    Byte length = dataByte[3];
    
    switch (SubType) {
        case Negotiate_Data_DataSubType: //协商数据
        {
            NSLog(@"Receive negoriate data");
            if (data.length < length + 4) {
                NSLog(@"Negotiate data error");
                [self updateMessage:@"Negotiate data error"];
                [self disconnectBLE];
                return;
            }
            NSData *NegotiateData = [data subdataWithRange:NSMakeRange(4, length)];
            device.Securtkey = [DH_AES GetSecurtKey:NegotiateData RsaObject:self.rsaobject];
            [self updateMessage:@"Negotiate security complete"];
            
            NSMutableData *data = [[NSMutableData alloc]init];
            uint8_t type[1] = {0x01};
            
            [data appendData:[[NSData alloc]initWithBytes:type length:sizeof(type)]];
            
            uint8_t length[1];
            length[0] = self.ssid.length;
            [data appendData:[[NSData alloc]initWithBytes:length length:sizeof(length)]];
            [data appendData:[self.ssid dataUsingEncoding:NSUTF8StringEncoding]];
            
            type[0] = 0x02;
            [data appendData:[[NSData alloc]initWithBytes:type length:sizeof(type)]];
            length[0] = self.password.length;
            [data appendData:[[NSData alloc]initWithBytes:length length:sizeof(length)]];
            [data appendData:[self.password dataUsingEncoding:NSUTF8StringEncoding]];
            
            type[0] = 0x03;
            NSData *meshID = [@"123456" dataUsingEncoding:NSUTF8StringEncoding];
            length[0] = meshID.length;
            [data appendData:[[NSData alloc]initWithBytes:type length:sizeof(type)]];
            [data appendData:[[NSData alloc]initWithBytes:length length:sizeof(length)]];
            [data appendData:meshID];
            
            if (device.Securtkey) {
                if (meshID) {
                    NSLog(@"%@",data);
                    //设置meshID
                    [self writeStructDataWithDevice:device WithData:[PacketCommand SetMeshID:data Sequence:device.sequence Encrypt:YES WithKeyData:device.Securtkey]];
                }
            } else {
                if (meshID) {
                    //设置meshID
                    NSLog(@"%@",data);
                    [self writeStructDataWithDevice:device WithData:[PacketCommand SetMeshID:data Sequence:device.sequence Encrypt:NO WithKeyData:device.Securtkey]];
                }
            }
        }
            break;
        case Wifi_Connection_state_Report_DataSubType: //连接状态报告
            NSLog(@"Notify wifi state");
            if (length < 3) {
                [self updateMessage:@"Wifi state data error"];
                [self disconnectBLE];
                return;
            }
            Byte opMode = dataByte[4];
            NSLog(@"OP Mode %d", opMode);
            if (opMode != STAOpmode) {
                [self updateMessage:[NSString stringWithFormat:@"Wifi opmode %d", opMode]];
                [self disconnectBLE];
                return;
            }
            Byte stationConn = dataByte[5];
            NSLog(@"Wifi state %d", stationConn);
            BOOL connectWifi = stationConn == 0;
            if (!connectWifi) {
                [self updateMessage:@"Device connect wifi failed"];
                [self disconnectBLE];
                return;
            }
            [self updateMessage:@"Device connected wifi"];
            [self disconnectBLE];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case Error_DataSubType:
            NSLog(@"Notify error code");
            if (data.length < 5) {
                NSLog(@"Error notify data error");
                [self updateMessage:@"Error notify data error"];
            } else  {
                [self updateMessage:[NSString stringWithFormat:@"Error notify code = %d", dataByte[4]]];
            }
            [self disconnectBLE];
            break;
        case BSSID_STA_DataSubType:
        case SSID_STA_DataSubType:
        case Password_STA_DataSubType:
        case SSID_SoftaAP_DataSubType:
        case Password_SoftAP_DataSubType:
        case Max_Connect_Number_SoftAP_DataSubType:
        case Authentication_SoftAP_DataSubType:
        case Channel_SoftAP_DataSubType:
        case Username_DataSubType:
        case CA_Certification_DataSubType:
        case Client_Certification_DataSubType:
        case Server_Certification_DataSubType:
        case Client_PrivateKey_DataSubType:
        case Server_PrivateKey_DataSubType:
        case Version_DataSubType:
            break;
        default:
            break;
    }
}

-(void)SendNegotiateDataWithDevice:(BLEDevice *)device {
    if (!self.rsaobject) {
        self.rsaobject = [DH_AES DHGenerateKey];
    }
    NSInteger datacount = 139;
    //发送数据长度
    uint16_t length = self.rsaobject.P.length + self.rsaobject.g.length + self.rsaobject.PublickKey.length+6;
    [self writeStructDataWithDevice:device WithData:[PacketCommand SetNegotiatelength:length Sequence:device.sequence]];
    
    //发送数据,需要分包
    device.senddata = [PacketCommand GenerateNegotiateData:self.rsaobject];
    NSInteger number = device.senddata.length / datacount;
    if (number > 0) {
        for(NSInteger i = 0; i < number + 1; i++){
            if (i == number){
                NSData *data=[PacketCommand SendNegotiateData:device.senddata Sequence:device.sequence Frag:NO TotalLength:device.senddata.length];
                [self writeStructDataWithDevice:device WithData:data];
            } else {
                NSData *data = [PacketCommand SendNegotiateData:[device.senddata subdataWithRange:NSMakeRange(0, datacount)] Sequence:device.sequence Frag:YES TotalLength:device.senddata.length];
                [self writeStructDataWithDevice:device WithData:data];
                device.senddata = [device.senddata subdataWithRange:NSMakeRange(datacount, device.senddata.length-datacount)];
            }
        }
    } else {
        NSData *data=[PacketCommand SendNegotiateData:device.senddata Sequence:device.sequence Frag:NO TotalLength:device.senddata.length];
        [self writeStructDataWithDevice:device WithData:data];
    }
}

@end
