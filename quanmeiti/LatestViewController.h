//
//  LatestViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"


@interface LatestViewController : UITableViewController <UIScrollViewDelegate, CDSiteDataApiDelegate> {
    BOOL pageControlUsed;
}

@property (nonatomic, retain) UIScrollView *pageScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UILabel *hottestPostTitle;
@property (nonatomic, retain) NSMutableArray *hottestPosts;
@property (retain) NSMutableArray *latestPosts;
@property (retain) NSMutableArray *hottestImageViews;

@end
