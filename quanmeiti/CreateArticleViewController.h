//
//  CreateArticleViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"
#import "MBProgressHUD.h"

@interface CreateArticleViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CDSiteDataApiDelegate> {
    NSMutableArray *imagesData;
    NSMutableArray *imageViews;
}

@property (nonatomic, retain) NSDictionary *post;
@property (nonatomic, retain) UIScrollView *pageScrollView;
@property (nonatomic, retain) UITextView *articleTextView;
@property (nonatomic, retain) UIBarButtonItem *postButton;
@property (nonatomic, retain) UIBarButtonItem *hideKeyboardButton;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) MBProgressHUD *hud;

- (id) initWithPost:(NSDictionary *)post;
@end
