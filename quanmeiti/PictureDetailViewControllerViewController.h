//
//  PictureDetailViewControllerViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureDetailViewControllerViewController : UIViewController <UIScrollViewDelegate> {
    
}

@property NSUInteger currentPage;

@property (retain) UIScrollView *imageScrollView;
@property (retain) UILabel *titleLabel;
@property (retain) NSMutableArray *imageViews;
@property (retain) UIToolbar *bottomToolbar;
@property (retain) NSArray *pictures;
@end
