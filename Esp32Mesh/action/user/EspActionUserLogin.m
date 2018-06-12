//
//  EspActionUserLogin.m
//  Esp32MeshH5
//
//  Created by AE on 2018/3/21.
//  Copyright © 2018年 AE. All rights reserved.
//

#import "EspActionUserLogin.h"
#import "EspJsonUtils.h"
#import "EspHttpUtils.h"
#import "EspCommonUtils.h"
#import "EspUser.h"
#import "EspDBManager.h"

@implementation EspActionUserLogin

- (EspLoginResult)doActionLoginForEmail:(NSString *)email password :(NSString *)password savePassword:(BOOL)save {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:email forKey:EspKeyEmail];
    [dict setObject:password forKey:EspKeyPassword];
    [dict setObject:[NSNumber numberWithInt:1] forKey:EspKeyRemember];
    
    NSData *data = [EspJsonUtils getDataWithDictionary:dict];
    if (data == nil) {
        return EspLoginResultFailed;
    }
    
    @try {
        EspHttpResponse *response = [EspHttpUtils postForUrl:EspUrlUserLogin content:data params:nil headers:nil];
        id respJSON = [response getContentJSON];
        NSNumber *status = [respJSON valueForKey:EspKeyStatus];
        int statusValue = [status intValue];
        if (statusValue == EspHttpCodeOK) {
            id userJSON = [respJSON valueForKey:EspKeyUser];
            NSNumber *userId = [userJSON valueForKey:EspKeyID];
            NSString *username = [userJSON valueForKey:EspKeyUserName];
            id keyJSON = [respJSON valueForKey:EspKeyKey];
            NSString *userkey = [keyJSON valueForKey:EspKeyToken];
            
            EspUser *user = [EspUser sharedInstance];
            user.uid = [userId longValue];
            user.name = username;
            user.key = userkey;
            
            NSString *savePwd = save ? password : nil;
            EspDBManager *dbManager = [EspDBManager sharedInstance];
            [dbManager.user saveUserId:user.uid key:userkey name:username email:email password:savePwd];
            [dbManager.user saveLastLoginUserId:user.uid];
        }
        return [self getLoginResultForStatus:statusValue];
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
        return EspLoginResultFailed;
    }
}

- (EspLoginResult)getLoginResultForStatus:(int)status {
    switch (status) {
        case EspHttpCodeOK:
            return EspLoginResultSuc;
        case EspHttpCodeForbidden:
            return EspLoginResultPwdErr;
        case EspHttpCodeNotFound:
            return EspLoginResultNotRegister;
        default:
            return EspLoginResultFailed;
    }
}

@end
