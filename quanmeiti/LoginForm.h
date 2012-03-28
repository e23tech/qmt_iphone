//
//  LoginForm.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginForm : NSObject {
}


@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (BOOL) userIsLogined;
+ (NSUInteger)cacheUserid;
+ (NSString *)cacheUserName;
+ (NSDictionary *)cacheUserInfo;
+ (void) removeCacheUserInfo;
@end
