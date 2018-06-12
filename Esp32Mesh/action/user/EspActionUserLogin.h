//
//  EspActionUserLogin.h
//  Esp32MeshH5
//
//  Created by AE on 2018/3/21.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionUser.h"

static NSString * const EspUrlUserLogin = @"https://iot.espressif.cn/v1/user/login/";

static NSString * const EspKeyUser = @"user";
static NSString * const EspKeyRemember = @"remember";

@interface EspActionUserLogin : EspActionUser

typedef enum {
    EspLoginResultSuc,
    EspLoginResultPwdErr,
    EspLoginResultNotRegister,
    EspLoginResultFailed,
}EspLoginResult;

- (EspLoginResult)doActionLoginForEmail:(NSString *)email password:(NSString *)password savePassword:(BOOL)save;

@end
