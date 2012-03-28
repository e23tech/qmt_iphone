//
//  MoreViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface MoreViewController : QuickDialogController <MFMessageComposeViewControllerDelegate>

- (void) aboutme:(QLabelElement *)label;
- (void) shareToFriend:(QLabelElement *)label;
- (void) gotoAppStoreRating:(QLabelElement *)label;
- (void) test:(QButtonElement *)button;
@end
