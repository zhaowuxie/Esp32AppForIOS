//
//  DeviceDB+CoreDataProperties.h
//  Esp32Mesh
//
//  Created by AE on 2018/5/14.
//  Copyright © 2018年 AE. All rights reserved.
//
//

#import "DeviceDB+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DeviceDB (CoreDataProperties)

+ (NSFetchRequest<DeviceDB *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *mac;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *protocol;
@property (nonatomic) int16_t protocol_port;
@property (nonatomic) int32_t tid;
@property (nullable, nonatomic, copy) NSString *version;

@end

NS_ASSUME_NONNULL_END
