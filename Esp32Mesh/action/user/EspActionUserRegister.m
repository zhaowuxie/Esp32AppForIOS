//
//  EspActionUserRegister.m
//  Esp32MeshH5
//
//  Created by AE on 2018/3/22.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionUserRegister.h"
#import "EspJsonUtils.h"
#import "EspCommonUtils.h"
#import "EspHttpUtils.h"

@implementation EspActionUserRegister

- (EspRegisterResult)doActionRegisterForEmail:(NSString *)email username:(NSString *)username password:(NSString *)password {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:email forKey:EspKeyEmail];
    [dict setObject:username forKey:EspKeyUserName];
    [dict setObject:password forKey:EspKeyPassword];
    
    NSData *data = [EspJsonUtils getDataWithDictionary:dict];
    if (data == nil) {
        return EspRegisterResultFailed;
    }
    
    @try {
        EspHttpResponse *response = [EspHttpUtils postForUrl:EspUrlUserRegister content:data params:nil headers:nil];
        id respJSON = [response getContentJSON];
        NSNumber *status = [respJSON valueForKey:EspKeyStatus];
        int statusValue = [status intValue];
        if (statusValue == EspHttpCodeOK) {
            // TODO
        }
        
        return [self getRegisterResultForStatus:statusValue];
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
        return EspRegisterResultFailed;
    }
}

- (EspRegisterResult)getRegisterResultForStatus:(int)status {
    switch (status) {
        case EspHttpCodeOK:
            return EspRegisterResultSuc;
        case EspHttpCodeConflict:
            return EpsRegisterResultUsrOrEmailExist;
        case EspHttpCodeBadRequest:
            return EspRegisterResultContentFormatError;
        default:
            return EspRegisterResultFailed;
    }
}

@end
