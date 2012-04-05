//
//  CDAppUserData.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CDQDRootElementBuilder.h"
#import "LoginForm.h"

@implementation CDQDRootElementBuilder

+ (QRootElement *) createMoreSettingRoot
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    QRootElement *root = [[[QRootElement alloc] init] autorelease];
    root.controllerName = @"MoreViewController";
    root.grouped = YES;
    root.title = @"更多";
    
    QSection *section1 = [[QSection alloc] initWithTitle:@"应用相关"];
    QLabelElement *aboutmeLabel = [[QLabelElement alloc] initWithTitle:@"关于我们" Value:nil];
    [section1 addElement:aboutmeLabel];
    [aboutmeLabel release];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    QBadgeElement *versionLabel = [[QBadgeElement alloc] initWithTitle:@"当前最新版本" Value:version];
    [section1 addElement:versionLabel];
    [versionLabel release];
    
    [root addSection:section1];
    [section1 release];
    
    
    /* 
     * section 3
     */
    QSection *section3 = [[QSection alloc] initWithTitle:@"其它"];
    // appStoreRatingButton
    QLabelElement *appStoreRatingButton = [[QLabelElement alloc] initWithTitle:[NSString stringWithFormat:@"为%@打分", appName] Value:nil];
    appStoreRatingButton.controllerAction = @"gotoAppStoreRating:";
    [section3 addElement:appStoreRatingButton];
    [appStoreRatingButton release];

    // shareToFriendButton
    QLabelElement *shareToFriendButton = [[QLabelElement alloc] initWithTitle:@"马上分享给好友" Value:nil];
    shareToFriendButton.controllerAction = @"shareToFriend:";
    [section3 addElement:shareToFriendButton];
    [shareToFriendButton release];
    
//    QButtonElement *test = [[QButtonElement alloc] initWithTitle:@"Test"];
//    test.image = [UIImage imageNamed:@"duanzi.png"];
//    test.controllerAction = @"test:";
//    [section2 addElement:test];
//    [test release];
    
    [root addSection:section3];
    [section3 release];
    
    return root;
}

+ (QRootElement *) createLoginRoot
{
    QRootElement *root = [[[QRootElement alloc] init] autorelease];
    root.controllerName = @"LoginViewController";
    root.grouped = YES;
    root.title = @"登录";
    
    QSection *section1 = [[QSection alloc] init];
    section1.headerImage = @"logo.png";
    
    NSString *cacheUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_login_name"];
    QEntryElement *usernameEntry = [[QEntryElement alloc] initWithTitle:@"名 字" Value:cacheUsername Placeholder:@"Your Name"];
    usernameEntry.key = @"username";
    [section1 addElement:usernameEntry];
    [usernameEntry release];
    
    QEntryElement *passwordEntry = [[QEntryElement alloc] initWithTitle:@"密 码" Value:nil Placeholder:@"Your Password"];
    passwordEntry.secureTextEntry = YES;
    passwordEntry.key = @"password";
    [section1 addElement:passwordEntry];
    [passwordEntry release];
    
    [root addSection:section1];
    [section1 release];
    
    
    
    QSection *section2 = [[QSection alloc] init];
    QButtonElement *submitButton = [[QButtonElement alloc] initWithTitle:@"登录" Value:@"OK"];
    submitButton.controllerAction = @"onLogin:";
    [section2 addElement: submitButton];
    [submitButton release];

    QButtonElement *cancelButton = [[QButtonElement alloc] initWithTitle:@"关闭" Value:@"Cancel"];
    cancelButton.controllerAction = @"onCancel:";
    [section2 addElement: cancelButton];
    [cancelButton release];

    [root addSection:section2];
    [section2 release];
    
    
    return root;
}
@end
