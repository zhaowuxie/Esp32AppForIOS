//
//  EspWebViewController.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/4.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspWebViewController.h"
#import "EspApiForJS.h"

static NSString * const EspWebResourcePathPhone = @"web/test.html";
static NSString * const EspWebResourcePathPad = @"web/test.html";

@interface EspWebViewController () <WKNavigationDelegate>

@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) EspApiForJS *jsHandler;

@end

@implementation EspWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect statusBar = [[UIApplication sharedApplication] statusBarFrame];
    CGRect webFrame = CGRectMake(0, statusBar.size.height, screen.size.width, screen.size.height - statusBar.size.height);
    self.webView = [[WKWebView alloc] initWithFrame:webFrame];
    self.webView.navigationDelegate = self;
    self.jsHandler = [[EspApiForJS alloc] initWithWebViewController:self];
    [self.view addSubview:self.webView];
    // load local html
    NSString *webResPath;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        webResPath = EspWebResourcePathPhone;
    } else {
        webResPath = EspWebResourcePathPad;
    }
    NSString *webPath = [[NSBundle mainBundle] pathForResource:webResPath ofType:@""];
    NSURL *webURL = [NSURL fileURLWithPath:webPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"did finish load");
}

@end
