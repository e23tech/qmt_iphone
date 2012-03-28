//
//  LoginViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"

@interface LoginViewController : QuickDialogController <QuickDialogStyleProvider, QuickDialogEntryElementDelegate, CDSiteDataApiDelegate>

@end
