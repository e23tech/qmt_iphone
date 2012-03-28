//
//  AlbumViewController.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDSiteDataApiDelegate.h"
#import "GMGridView.h"

@interface AlbumViewController : UIViewController <CDSiteDataApiDelegate, GMGridViewActionDelegate, GMGridViewDataSource> {
    GMGridView *gmGridView;
}

//@property (nonatomic, retain)
@property (nonatomic, retain) NSMutableArray *albums;
@end
