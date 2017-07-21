//
//  GDMapService.m
//  CTNetworking
//
//  Created by casa on 16/4/12.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "GDMapService.h"
#import "CTNetworkingConfigurationManager.h"
#import "NSString+JXCExt.h"
#define SCAPI_APP_SECRET  @"APP_SECRET"


@implementation GDMapService

#pragma mark - CTServiceProtocal
- (BOOL)isOnline
{
    return [CTNetworkingConfigurationManager sharedInstance].serviceIsOnline;
}

- (NSString *)offlineApiBaseUrl
{
    //return @"http://restapi.amap.com";
    return @"http://s2.d.jx-cloud.cc:10000";
}

- (NSString *)onlineApiBaseUrl
{
    return @"http://s2.d.jx-cloud.cc:10000";
    //return @"http://restapi.amap.com";
}

- (NSString *)offlineApiVersion
{
    return nil;
    //return @"v3";
}

- (NSString *)onlineApiVersion
{
    return nil;
    //return @"v3";
}

- (NSString *)onlinePublicKey
{
    return @"384ecc4559ffc3b9ed1f81076c5f8424";
}

- (NSString *)offlinePublicKey
{
    return @"384ecc4559ffc3b9ed1f81076c5f8424";
}

- (NSString *)onlinePrivateKey
{
    return @"";
}

- (NSString *)offlinePrivateKey
{
    return @"";
}

//为某些Service需要拼凑额外字段到URL处
- (NSDictionary *)extraParmas {
    //return @{@"key": @"374910422"};
    return nil;
}

//为某些Service需要拼凑额外的HTTPToken，如accessToken
- (NSDictionary *)extraHttpHeadParmasWithMethodName:(NSDictionary *)parmas {
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    mutableDictionary[@"X-JXC-APPID"] = @"APP_ID";
    NSString *nostr = [NSString randomString];
    mutableDictionary[@"X-JXC-NOSTR"] = nostr;
    
    NSDictionary *parameters = parmas;
    NSArray *dataKeys = [[parameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableString *signStr = [[NSMutableString alloc] initWithCapacity:10];
    for(NSString *key in dataKeys){
        NSString *str = parameters[key];
        if(str != nil){
            NSLog(@"---- params key:%@, str: %@",key,str);
            [signStr appendFormat:@"%@", str];
        }
    }
    [signStr appendFormat:@"%@%@", SCAPI_APP_SECRET, nostr];
    mutableDictionary[@"X-JXC-SIGN"] = [signStr stringToMD5];
    NSLog(@"----- header : %@",mutableDictionary);
    return [mutableDictionary mutableCopy];
//    return @{@"sessionID": [[NSUUID UUID]UUIDString],
//             @"token":[[NSUUID UUID]UUIDString]};
}

//- (NSString *)urlGeneratingRuleByMethodName:(NSString *)methodName {
//    return [NSString stringWithFormat:@"%@/%@/%@", self.apiBaseUrl, self.apiVersion, methodName];
//}


- (BOOL)shouldCallBackByFailedOnCallingAPI:(CTURLResponse *)response {
    BOOL result = YES;
    if ([response.content[@"id"] isEqualToString:@"expired_access_token"]) {
        // token 失效
        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenInvalidNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
                                                                     }];
        result = YES;
    } else if ([response.content[@"id"] isEqualToString:@"illegal_access_token"]) {
        // token 无效，重新登录
        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenIllegalNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
                                                                     }];
        result = YES;
    } else if ([response.content[@"id"] isEqualToString:@"no_permission_for_this_api"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenIllegalNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
                                                                     }];
        result = NO;
    }
    return result;
}



@end
