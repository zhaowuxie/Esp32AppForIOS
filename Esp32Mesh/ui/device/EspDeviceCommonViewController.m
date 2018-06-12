//
//  EspDeviceCommonViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/3/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspDeviceCommonViewController.h"
#import "EspCharacteristicViewHolder.h"
#import "EspCommonUtils.h"
#import "EspActionDeviceInfo.h"
#import "EspTextUtil.h"

@interface EspDeviceCommonViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) NSMutableArray<EspCharacteristicViewHolder *> *viewHolderArray;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation EspDeviceCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewHolderArray = [NSMutableArray array];
    self.operationQueue = [[NSOperationQueue alloc] init];
    
    NSLog(@"Deice mac = %@" , self.device.mac);
    [self.scrollview layoutIfNeeded];
    [self initScrollViewSubViews];
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

- (void)initScrollViewSubViews {
    CGRect scrollFrame = self.scrollview.frame;
    CGFloat frameY = 5;
    
    NSArray *characteristics = [[self.device getCharacteristics] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *cid1 =[NSNumber numberWithInt:((EspDeviceCharacteristic *)obj1).cid];
        NSNumber *cid2 =[NSNumber numberWithInt:((EspDeviceCharacteristic *)obj2).cid];
        return [cid1 compare:cid2];
    }];
    for (EspDeviceCharacteristic *c in characteristics) {
        NSString *cname = c.name;
        
        CGRect labelFrame = CGRectMake(0, frameY, scrollFrame.size.width, 20);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = cname;
        frameY += 25;
        
        CGRect textViewFrame = CGRectMake(0, frameY, scrollFrame.size.width - 65, 25);
        UITextView *textView = [[UITextView alloc] initWithFrame:textViewFrame];
        textView.layer.borderColor = [UIColor grayColor].CGColor;
        textView.layer.borderWidth =1.0;
        textView.layer.cornerRadius = 3.0;
        textView.layer.masksToBounds = YES;
        textView.text = [NSString stringWithFormat:@"%@", c.value];
        textView.editable = c.isWritable;
        textView.tag = c.cid;
        
        CGRect buttonFrame = CGRectMake(scrollFrame.size.width - 60, frameY, 60, 25);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitle:@"Post" forState:UIControlStateNormal];
        frameY += 30;
        
        frameY += 10;
        
        EspCharacteristicViewHolder *holder = [[EspCharacteristicViewHolder alloc] init];
        holder.device = self.device;
        holder.characteristic = c;
        holder.textView = textView;
        holder.button = button;
        [self.viewHolderArray addObject:holder];
        
        [button addTarget:holder action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollview addSubview:label];
        [self.scrollview addSubview:textView];
        [self.scrollview addSubview:button];
    }
}

- (IBAction)onPostAllItemClick:(id)sender {
    self.postAllItem.enabled = false;
    NSMutableArray *carray = [NSMutableArray array];
    for (EspCharacteristicViewHolder *holder in self.viewHolderArray) {
        EspDeviceCharacteristic *c = holder.characteristic;
        NSString *valueStr = holder.textView.text;
        if (c.isWritable && ![EspTextUtil isEmpty:valueStr]) {
            EspDeviceCharacteristic *postC = [EspDeviceCharacteristic newInstance:c.format];
            postC.cid = c.cid;
            [postC setValueObjectWithString:valueStr];
            
            [carray addObject:postC];
        }
    }
    [self.operationQueue addOperationWithBlock:^{
        EspActionDeviceInfo *action = [[EspActionDeviceInfo alloc] init];
        [action doActionSetDeviceStatusLocal:self.device forCharacteristics:carray];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.postAllItem.enabled = YES;
        }];
    }];
    
}

- (IBAction)onRefreshItemClick:(id)sender {
    self.refreshItem.enabled = false;
    [self.operationQueue addOperationWithBlock:^{
        EspActionDeviceInfo *action = [[EspActionDeviceInfo alloc] init];
        BOOL suc;
        if ([self.viewHolderArray count] == 0) {
            suc = [action doActionGetDeviceInfoLocal:self.device];
        } else {
            NSMutableArray *cids = [NSMutableArray array];
            for (EspCharacteristicViewHolder *holder in self.viewHolderArray) {
                [cids addObject:[NSNumber numberWithInt:holder.characteristic.cid]];
            }
            suc = [action doActionGetDeviceStatusLocal:self.device forCids:cids];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (suc) {
                if ([self.viewHolderArray count] == 0) {
                    [self initScrollViewSubViews];
                } else {
                    for (EspCharacteristicViewHolder *holder in self.viewHolderArray) {
                        holder.textView.text = [NSString stringWithFormat:@"%@", holder.characteristic.value];
                    }
                }
            }
            self.refreshItem.enabled = YES;
        }];
    }];
}
- (IBAction)onAddClick:(id)sender {
}
@end
