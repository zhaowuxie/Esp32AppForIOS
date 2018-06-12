//
//  EspApiForJS.m
//  Esp32Mesh
//
//  Created by AE on 2018/5/8.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspApiForJS.h"

@interface EspApiForJS () {
    @private
    EspWebViewController *viewController;
}

@end

@implementation EspApiForJS

- (instancetype)initWithWebViewController:(EspWebViewController *)vc {
    self = [super init];
    if (self) {
        viewController = vc;
        [self initApiForWebView:vc.webView];
    }
    return self;
}

- (void)initApiForWebView:(WKWebView *)webView {
    [webView.configuration.userContentController addScriptMessageHandler:self name:EspApiLog];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:EspApiLog]) {
        [self log:message.body];
    }
}

- (void)log:(id)message {
    NSLog(@"%@", message);
}

@end
