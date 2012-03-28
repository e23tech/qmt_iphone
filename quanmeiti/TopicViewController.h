//
//  TopicViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"

@interface TopicViewController : UITableViewController <CDSiteDataApiDelegate>

@property (nonatomic, retain) NSMutableArray *topics;

@end
