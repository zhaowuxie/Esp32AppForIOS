//
//  AppDelegate.h
//  Esp32Mesh
//
//  Created by AE on 2018/1/3.
//  Copyright © 2018年 AE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

