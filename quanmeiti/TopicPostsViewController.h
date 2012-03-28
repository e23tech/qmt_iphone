//
//  PostListViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"

@interface TopicPostsViewController : UITableViewController <CDSiteDataApiDelegate>

@property NSUInteger topicid;
@property (retain) NSMutableArray *posts;

- (id) initWithStyle:(UITableViewStyle)style topicID:(NSUInteger)tid;
@end
