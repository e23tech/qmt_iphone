//
//  LoginForm.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginForm.h"

@implementation LoginForm

@synthesize username = _username;
@synthesize password = _password;

+ (BOOL) userIsLogined
{
    BOOL userIsLogined = [[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logined"];
    
    return userIsLogined;
}

+ (NSUInteger)cacheUserid
{
    NSUInteger userid = 0;
    NSDictionary *userinfo = [self cacheUserInfo];
    if (userinfo != nil) {
        userid = [[userinfo objectForKey:@"id"] integerValue];
    }
    return userid;
}


+ (NSString *)cacheUserName
{
    NSString *userName;
    NSDictionary *userinfo = [self cacheUserInfo];
    if (userinfo != nil) {
        userName = (NSString *)[userinfo objectForKey:@"name"];
    }
    else 
        userName = nil;
    return userName;
}

+ (NSDictionary *)cacheUserInfo
{
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"cache_user_info"];
    return userinfo;
}

+ (void) removeCacheUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cache_user_info"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_is_logined"];
}

@end
