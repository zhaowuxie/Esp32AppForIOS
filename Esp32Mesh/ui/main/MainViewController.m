//
//  ViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/1/3.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "MainViewController.h"
#import "EspUser.h"
#import "EspDevice.h"
#import "EspActionDeviceStation.h"
#import "EspConstants.h"
#import "EspDeviceUtil.h"
#import "EspCommonUtils.h"
#import "EspActionDeviceInfo.h"
#import "EspHttpUtils.h"
#import "EspRandomUtils.h"
#import "EspDeviceCommonViewController.h"
#import "EspBleListViewController.h"
#import "EspOTAViewController.h"
#import "UIView+Toast.h"
#import "EspWebViewController.h"

@interface MainViewController () {
    @private
        NSOperationQueue *operationQueue;
    @private
        EspUser *user;
}

@property(nonatomic, strong) NSMutableArray<EspDevice *> *deviceArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
    
    user = [EspUser sharedInstance];
    operationQueue = [[NSOperationQueue alloc] init];
    
    self.title = @"Mesh";
    
    self.deviceArray = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    [rc addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    [self setRefreshingTitle:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRefresh {
    if (self.refreshControl.refreshing) {
        NSLog(@"refreshing");
        [self scan];
    } else {
        NSLog(@"not refreshing");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"DeviceIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    EspDevice *device = self.deviceArray[indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.mac;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)setRefreshingTitle:(NSString *)title {
    NSAttributedString *newTitle = [[NSAttributedString alloc] initWithString:title];
    self.refreshControl.attributedTitle = newTitle;
}

- (void)scan {
    [operationQueue addOperationWithBlock:^{
        NSLog(@"op start");
        [self->user scanStations];
        NSArray<EspDevice *> *stations = [self->user getAllDevices];
        [[EspActionDeviceInfo new] doActionGetDevicesInfoLocal:stations];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.deviceArray removeAllObjects];
            [self.deviceArray addObjectsFromArray:[self->user getAllDevices]];
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
        }];
        NSLog(@"op end");
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSelectedDevice"]) {
        EspDeviceCommonViewController *deviceVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger selectedIndex = indexPath.row;
        EspDevice *device = self.deviceArray[selectedIndex];
        deviceVC.device = device;
        deviceVC.title = device.name;
    } else if ([segue.identifier isEqualToString:@"ShowAddDevice"]) {
        EspBleListViewController *bleListVC = segue.destinationViewController;
        NSLog(@"Segue ble list view controller");
    }
}

- (IBAction)onActionSheetClick:(id)sender {
    BOOL otaSupport = YES;
    if (!otaSupport) {
        EspWebViewController *web = [self.storyboard instantiateViewControllerWithIdentifier:@"EspWebViewController"];
        [self presentViewController:web animated:YES completion:nil];
        return;
    }
    
    UIAlertController *menuVC = [[UIAlertController alloc] init];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    [menuVC addAction:cancelAction];
    
    UIAlertAction *otaAction = [UIAlertAction actionWithTitle:@"OTA" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.deviceArray.count == 0) {
            [self.navigationController.view makeToast:@"No devices"];
            return;
        }
        
        EspOTAViewController *otaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EspOTAViewController"];
        otaVC.title = @"OTA";
        otaVC.devices = [NSArray arrayWithArray:self.deviceArray];
        [self.navigationController pushViewController:otaVC animated:YES];
    }];
    [menuVC addAction:otaAction];
    
    menuVC.popoverPresentationController.sourceView = sender;
    [self presentViewController:menuVC animated:YES completion:nil];
}

@end
