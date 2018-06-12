//
//  EspBleListViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/4/17.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "EspBleListViewController.h"
#import "EspConstants.h"
#import "UIView+Toast.h"
#import "EspCommonUtils.h"
#import "EspBlufiSettingsViewController.h"
#import "BLEDevice.h"
#import "BLEdataFunc.h"

static NSString * const EspBlePrefix = @"MESH";
static const int EspBleScanTimeout = 5;

@interface EspBleListViewController () <CBCentralManagerDelegate> {
    @private
    CBCentralManager *bleManager;
    @private
    BOOL bleEnable;
    @private
    NSOperationQueue *operationQueue;
    @private
    NSMutableArray<BLEDevice *> *deviceArray;
    @private
    NSMutableDictionary<CBPeripheral *, BLEDevice *> *bleDeviceDict;
}

@end

@implementation EspBleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    operationQueue = [[NSOperationQueue alloc] init];
    
    bleDeviceDict = [NSMutableDictionary dictionary];
    deviceArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    
    bleManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [operationQueue cancelAllOperations];
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

- (void)onRefresh {
    if (self.refreshControl.refreshing) {
        NSLog(@"onRefresh refreshing");
        [self scan];
    } else {
        NSLog(@"onRefresh not refreshing");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"BLEIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    BLEDevice *device = deviceArray[indexPath.row];
    cell.textLabel.text = device.name;
    NSString *mac = [[NSString alloc] initWithData:device.MACAddress encoding:NSUTF8StringEncoding];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", mac, device.RSSI];
    
    return cell;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"CBManagerStatePoweredOn");
            bleEnable = YES;
            if (!self.refreshControl.refreshing) {
                [self.refreshControl beginRefreshing];
                [self scan];
            }
            break;
        case CBManagerStateUnknown:
        case CBManagerStatePoweredOff:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
            NSLog(@"CBManagerStatePoweredOff");
            bleEnable = NO;
            break;
        default:
            bleEnable = NO;
            break;
    }
}

-(void)scan {
    NSLog(@"BLE scan");
    if (!bleEnable) {
        NSLog(@"BLE Disable");
        [self.navigationController.view makeToast:@"BLE is disable"];
        [self.refreshControl endRefreshing];
        return;
    }
    
    [bleDeviceDict removeAllObjects];
    [deviceArray removeAllObjects];
    [self.tableView reloadData];
    
    [bleManager scanForPeripheralsWithServices:nil options:nil];
    [operationQueue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:EspBleScanTimeout];
        
        [self->bleManager stopScan];
        
        NSArray *sortedArray = [[self->bleDeviceDict allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            int rssi1 = [((BLEDevice *)obj1).RSSI intValue];
            int rssi2 = [((BLEDevice *)obj2).RSSI intValue];
            if (rssi1 < rssi2) {
                return 1;
            } else if (rssi1 == rssi2) {
                return 0;
            } else {
                return -1;
            }
        }];
        [self->deviceArray addObjectsFromArray:sortedArray];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
            NSLog(@"BLE scan over");
        }];
    }];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([EspCommonUtils isNull:peripheral.name]) {
        return;
    }
    if (![peripheral.name hasPrefix:EspBlePrefix]) {
        return;
    }
    
    BLEDevice *device = bleDeviceDict[peripheral];
    if (!device) {
        device = [[BLEDevice alloc] init];
        NSData *macaddress = [BLEdataFunc GetSerialNumber:advertisementData];
        device.MACAddress = macaddress;
        device.name = peripheral.name;
        device.Peripheral = peripheral;
        device.select = NO;
        [bleDeviceDict setObject:device forKey:peripheral];
    }
    device.RSSI = RSSI;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowBlufiSettings"]) {
        EspBlufiSettingsViewController *settingsVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger selectedIndex = indexPath.row;
        BLEDevice *device = deviceArray[selectedIndex];
        settingsVC.device = device;
        settingsVC.bleManager = bleManager;
    }
}

@end
