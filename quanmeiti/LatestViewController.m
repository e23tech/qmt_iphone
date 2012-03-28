//
//  LatestViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LatestViewController.h"
#import "PostDetailViewController.h"
#import "CDPostListTableViewCell.h"
#import "CDSiteDataApiClient.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

static const NSUInteger HOTTEST_IMAGES_MAX_COUNT = 8;
static const NSUInteger HOTTEST_HEIGHT = 160;
static const NSUInteger PAGE_CONTROL_HEIGHT = 18;
static const NSUInteger HOTTEST_POST_LABEL_HEIGHT = 24;

@interface LatestViewController (private)
- (void) setupPageScrollView:(UIView *)contentView;
- (void) setupPageControl:(UIView *)contentView;
- (void) setupHottestPostTitleLabel:(UIView *)contentView;
- (void) loadScrollViewWithPage:(NSUInteger) page;
- (void) fetchLatestData;
- (void) reloadHottestImageViewsData;
- (void) showAlertViewWithMessage:(NSString *)message;
@end


@implementation LatestViewController

@synthesize pageScrollView;
@synthesize pageControl;
@synthesize hottestPosts;
@synthesize latestPosts;
@synthesize hottestImageViews;
@synthesize hottestPostTitle;

- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchLatestData)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
    
    [self fetchLatestData];
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
//    self.pageControl = nil;
//    self.pageScrollView = nil;
//    self.hottestPostTitle = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    [pageControl release];
    [pageScrollView release];
    [hottestPosts release];
    [latestPosts release];
    [hottestImageViews release];
    [hottestPostTitle release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [hottestPosts count] > 0 ? 1 : 0;
    else if (section == 1)
        return [latestPosts count];
    else
        return 0;
}


- (CDPostListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellHottestPostIdentifier = @"CellHottestPost";
    if (indexPath.section == 0) {
        CDPostListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellHottestPostIdentifier];
        if (cell == nil) {
            cell = [[[CDPostListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellHottestPostIdentifier] autorelease];
        }

        [self setupPageScrollView:cell.contentView];
        [self setupHottestPostTitleLabel:cell.contentView];
        [self setupPageControl:cell.contentView];
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    CDPostListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CDPostListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *post = [latestPosts objectAtIndex:indexPath.row];
    cell.titleLabel.text = [post objectForKey:@"title"];
    cell.dateLabel.text = [post objectForKey:@"create_time_text"];
    cell.countLabel.text = [post objectForKey:@"visit_nums"];

    NSURL *imageUrl = [NSURL URLWithString:[post objectForKey:@"thumbnail"]];
    [cell.thumbnailView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return HOTTEST_HEIGHT;
    else
        return 60.0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    PostDetailViewController *detailViewController = [[PostDetailViewController alloc] init];
    detailViewController.post = [latestPosts objectAtIndex:indexPath.row];
    [detailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:pageScrollView]) {
        if (pageControlUsed) return;
        
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;

        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page + 1];

        hottestPostTitle.text = [[hottestPosts objectAtIndex:pageControl.currentPage] objectForKey:@"title"];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

#pragma mark setup hottest container view

- (void) setupPageScrollView:(UIView *)contentView
{
    if (pageScrollView == nil) {
        self.pageScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, HOTTEST_HEIGHT)] autorelease];
        pageScrollView.pagingEnabled = YES;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        pageScrollView.scrollsToTop = NO;
        pageScrollView.delegate = self;
        pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width * hottestPosts.count, pageScrollView.frame.size.height);

        NSMutableArray *imageViews = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<[hottestPosts count]; i++) {
            [imageViews addObject:[NSNull null]];
        }
        self.hottestImageViews = imageViews;
        [imageViews release];

        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        [contentView addSubview:pageScrollView];
    }
    
    
}

- (void) setupPageControl:(UIView *)contentView
{
    if (pageControl == nil) {
        CGFloat pageControlY = pageScrollView.frame.size.height - PAGE_CONTROL_HEIGHT - HOTTEST_POST_LABEL_HEIGHT;
        CGRect pageControlFrame = CGRectMake(0, pageControlY, self.view.frame.size.width, PAGE_CONTROL_HEIGHT);
        self.pageControl = [[[UIPageControl alloc] initWithFrame:pageControlFrame] autorelease];
        pageControl.numberOfPages = hottestPosts.count;
        pageControl.currentPage = 0;
        pageControl.backgroundColor = [UIColor clearColor];
        pageControl.contentMode = UIViewContentModeRight;

        [contentView addSubview: pageControl];
    }
}

- (void) setupHottestPostTitleLabel:(UIView *)contentView
{
    if (hottestPostTitle == nil) {
        self.hottestPostTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 
                                                                           pageScrollView.frame.size.height - HOTTEST_POST_LABEL_HEIGHT, 
                                                                           pageScrollView.frame.size.width, 
                                                                           HOTTEST_POST_LABEL_HEIGHT)] autorelease];
        hottestPostTitle.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        hottestPostTitle.textColor = [UIColor whiteColor];
        hottestPostTitle.font = [UIFont systemFontOfSize:14.0];
        hottestPostTitle.textAlignment = UITextAlignmentCenter;
        
        hottestPostTitle.text = [[hottestPosts objectAtIndex:pageControl.currentPage] objectForKey:@"title"];
        
        [contentView addSubview:hottestPostTitle];
    }
    else {
        
    }
}

- (void) loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= hottestPosts.count || page >= hottestImageViews.count) return;
	
    NSDictionary *post = (NSDictionary *)[hottestPosts objectAtIndex:page];
    UIImageView *imageView = [hottestImageViews objectAtIndex:page];
    if ((NSNull *)imageView == [NSNull null]) {
        imageView = [[UIImageView alloc] init];
        NSURL *imageUrl = [NSURL URLWithString:[post objectForKey:@"thumbnail"]];
        [imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHottestImageView:)];
        [imageView addGestureRecognizer:recognizer];
        [recognizer release];
        
        [hottestImageViews replaceObjectAtIndex:page withObject:imageView];
        [imageView release];
    }
	
    // add the imageView to the scroll view
    if (nil == imageView.superview) {
        CGRect frame = pageScrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
        [pageScrollView addSubview:imageView];
    }
}

- (void) tapHottestImageView:(UITapGestureRecognizer *) recognizer
{
    PostDetailViewController *detailViewController = [[PostDetailViewController alloc] init];
    detailViewController.post = [hottestPosts objectAtIndex:pageControl.currentPage];
    [detailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}


#pragma mark - fetch data

- (void) fetchLatestData
{
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    [client setDelegate:self];
    [client fetchHottestAndLatestPosts];
}

#pragma mark - CDSiteDataApi delegate

- (void) apiClientDidStartedRequest:(CDSiteDataApiClient *)client
{
    [MBProgressHUD hideHUDForView:self.parentViewController.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)apiClient didFinishedRequestResponse:(id)response
{
    NSMutableArray *hottest = (NSMutableArray *) [response objectForKey:@"hottest"];
    NSMutableArray *latest = (NSMutableArray *) [response objectForKey:@"latest"];
    
    if ([latest count] > 0)
        self.latestPosts = latest;
    
    if ([hottest count] > 0) {
        self.hottestPosts = hottest;
        
        [hottestImageViews removeAllObjects];
        for (UIView *view in [pageScrollView subviews]) {
            [view removeFromSuperview];
        }
        
        for (int i=0; i<hottestPosts.count; i++) {
            [hottestImageViews addObject:[NSNull null]];
        }
        
        pageControl.currentPage = 0;
        pageControl.numberOfPages = [hottestPosts count];
        hottestPostTitle.text = [[hottestPosts objectAtIndex:0] objectForKey:@"title"];
        
        NSUInteger imageCount = ([hottestPosts count] > HOTTEST_IMAGES_MAX_COUNT) ? HOTTEST_IMAGES_MAX_COUNT : [hottestPosts count];
        pageScrollView.contentSize = CGSizeMake(pageScrollView.frame.size.width * imageCount, pageScrollView.frame.size.height);

        [pageScrollView scrollRectToVisible:CGRectMake(0, 0, pageScrollView.frame.size.width, pageScrollView.frame.size.height) animated:NO];
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
    
    if ([hottest count] == 0 && [latest count] == 0) {
        [self showAlertViewWithMessage:@"服务器正在进行系统升级，请稍候重试"];
        return;
    }
    else 
        [self.tableView reloadData];
}

- (void) apiClient:(CDSiteDataApiClient *)apiClient didFailedRequestError:(NSError *)error
{
    NSLog(@"%@", error);
    [self showAlertViewWithMessage:@"载入数据失败，请检查您的网络是否已经连接"];
}

- (void) apiClientDidCompletedRequest:(CDSiteDataApiClient *)client
{
    [MBProgressHUD hideHUDForView:self.parentViewController.view animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)apiClient sendRequestException:(NSException *)exception
{
    [self showAlertViewWithMessage:@"载入数据失败，请检查您的网络是否已经连接"];
}

- (void) showAlertViewWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"载入数据出错" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

@end




