//
//  EspBlufiSettingsViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/4/18.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspBlufiSettingsViewController.h"
#import "EspNetUtils.h"
#import "EspTextUtil.h"
#import "EspBlufiConfigureViewController.h"

@interface EspBlufiSettingsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation EspBlufiSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *ssid = [EspNetUtils getCurrentWiFiSsid];
    BOOL connected = ![EspTextUtil isEmpty:ssid];
    self.ssidLabel.text = ssid;
    self.confirmBtn.enabled = connected;
    self.passwordText.text = @"mistyskates807";
    self.passwordText.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordText) {
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowBlufiConfigure"]) {
        NSString *ssid = self.ssidLabel.text;
        NSString *password = self.passwordText.text;
        
        EspBlufiConfigureViewController *configureVC = segue.destinationViewController;
        configureVC.bleManager = self.bleManager;
        configureVC.device = self.device;
        configureVC.ssid = ssid;
        configureVC.password = password;
        
        self.confirmBtn.enabled = false;
    }
}

@end
