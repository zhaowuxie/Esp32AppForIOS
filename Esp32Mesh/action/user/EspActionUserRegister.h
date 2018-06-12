//
//  EspActionUserRegister.h
//  Esp32MeshH5
//
//  Created by AE on 2018/3/22.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionUser.h"

static NSString * const EspUrlUserRegister = @"https://iot.espressif.cn/v1/user/join/";

@interface EspActionUserRegister : EspActionUser

typedef enum {
    EspRegisterResultSuc,
    EpsRegisterResultUsrOrEmailExist,
    EspRegisterResultContentFormatError,
    EspRegisterResultFailed,
}EspRegisterResult;

- (EspRegisterResult)doActionRegisterForEmail:(NSString *)email username:(NSString *)username password:(NSString *)password;

@end
