//
//  EspApDBManager.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/15.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ApDB+CoreDataClass.h"

@interface EspApDBManager : NSObject

@property (nonatomic, weak, readonly) AppDelegate *app;
@property (nonatomic, weak, readonly) NSManagedObjectContext *context;

- (ApDB *)loadApForSsid:(NSString *)ssid;
- (NSArray<ApDB *> *)loadApArray;
- (void)saveApSsid:(NSString *)ssid password:(NSString *)password;
- (void)deleteApForSsid:(NSString *)ssid;

@end
