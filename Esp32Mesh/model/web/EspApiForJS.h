//
//  EspApiForJS.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/8.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "EspWebViewController.h"

static NSString * const EspApiLog = @"log";

@interface EspApiForJS : NSObject <WKScriptMessageHandler>

- (instancetype)initWithWebViewController:(EspWebViewController *)vc;

@end
