//
//  ApDB+CoreDataProperties.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/14.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "ApDB+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ApDB (CoreDataProperties)

+ (NSFetchRequest<ApDB *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *ssid;
@property (nullable, nonatomic, copy) NSString *password;

@end

NS_ASSUME_NONNULL_END
