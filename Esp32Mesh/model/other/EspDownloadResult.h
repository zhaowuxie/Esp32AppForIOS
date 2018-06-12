//
//  EspDownloadResult.h
//  Esp32Mesh
//
//  Created by AE on 2018/4/24.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EspDownloadResult : NSObject

@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSString *fileName;

@property(nonatomic, strong) NSString *file;

@end
