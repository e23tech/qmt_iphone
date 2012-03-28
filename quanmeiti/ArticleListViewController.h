//
//  ArticleListViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"
#import "PullRefreshTableViewController.h"


@interface ArticleListViewController : PullRefreshTableViewController <CDSiteDataApiDelegate>

@property (retain) NSMutableArray *articles;
@end
