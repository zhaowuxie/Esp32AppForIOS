 //
//  EspOTAViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/4/24.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspOTAViewController.h"
#import "EspActionDeviceOTA.h"
#import "UIView+Toast.h"
#import "EspActionDeviceOTA.h"

@interface EspOTAViewHolder : NSObject

@property (weak, nonatomic) EspOTAViewController *controller;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *delBtn;
@property (strong, nonatomic) NSString *binName;
@property (strong, nonatomic) NSString *binPath;

- (instancetype)initWithViewController:(EspOTAViewController *)controller cell:(UITableViewCell *)cell;

@end

@interface EspOTAViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (strong, nonatomic) NSMutableDictionary *cellHolderDict;

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableArray *binArray;

- (void)onCellDeleteClick:(NSString *)bin;

@end

@implementation EspOTAViewHolder

- (instancetype)initWithViewController:(EspOTAViewController *)controller cell:(UITableViewCell *)cell {
    self = [super init];
    if (self) {
        self.controller = controller;
        
        NSArray *cellviews = cell.subviews;
        for (UIView *view in cellviews) {
            if (view.tag != 1) {
                continue;
            }
            
            NSArray *subviews = view.subviews;
            for (UIView *subview in subviews) {
                switch (subview.tag) {
                    case 11:
                        self.label = (UILabel *)subview;
                        break;
                    case 12:
                        self.delBtn = (UIButton *)subview;
                        [self.delBtn addTarget:self action:@selector(onDeleteClick) forControlEvents:UIControlEventTouchUpInside];
                        break;
                }
            }
            break;
        }
    }
    return self;
}

- (void)onDeleteClick {
    [self.controller onCellDeleteClick:self.binPath];
}

@end

@implementation EspOTAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    self.cellHolderDict = [NSMutableDictionary dictionary];
    
    self.binArray = [NSMutableArray array];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self loadBins];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.operationQueue cancelAllOperations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSString *)getOTADirPath {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dirPath = [cachePath stringByAppendingPathComponent:@"ota"];
    return dirPath;
}

- (void)loadBins {
    [self.binArray removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager contentsOfDirectoryAtPath:[self getOTADirPath] error:nil];
    if (array) {
        [self.binArray addObjectsFromArray:array];
    }
    [self.tableView reloadData];
}

- (IBAction)onDownloadClick:(id)sender {
    self.downloadBtn.enabled = NO;
    [self.operationQueue addOperationWithBlock:^{
        EspActionDeviceOTA *action = [[EspActionDeviceOTA alloc] init];
        const BOOL download = [action doActionDownloadLastestRomVersionCloud];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (download) {
                [self loadBins];
            }
            
            self.downloadBtn.enabled = YES;
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"Download %@", download ? @"success" : @"failed"]];
        }];
    }];
}

- (void)onCellDeleteClick:(NSString *)binPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL delete = [fileManager removeItemAtPath:binPath error:nil];
    if (delete) {
        [self loadBins];
    }
    [self.navigationController.view makeToast:[NSString stringWithFormat:@"Delete %@", delete ? @"success" : @"failed"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.binArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"BinIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSNumber *holderKey = [NSNumber numberWithUnsignedLong:cell.hash];
    EspOTAViewHolder *holder = self.cellHolderDict[holderKey];
    if (!holder) {
        holder = [[EspOTAViewHolder alloc] initWithViewController:self cell:cell];
        [self.cellHolderDict setObject:holder forKey:holderKey];
    }
    
    NSString *bin = self.binArray[indexPath.row];
    NSString *binPath = [[self getOTADirPath] stringByAppendingPathComponent:bin];
    holder.binName = bin;
    holder.binPath = binPath;
    holder.label.text = bin;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *bin = self.binArray[indexPath.row];
    __block NSString *binPath = [[self getOTADirPath] stringByAppendingPathComponent:bin];
    NSLog(@"Seleted bin %@", binPath);
    self.coverView.hidden = NO;
    [self.operationQueue addOperationWithBlock:^{
        EspActionDeviceOTA *action = [[EspActionDeviceOTA alloc] init];
        [action doActionOTALocalDevices:self.devices binPath:binPath];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.coverView.hidden = YES;
        }];
    }];
}

@end
