//
//  pictureViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "constant.h"
#import "PictureListViewController.h"
#import "PictureDetailViewControllerViewController.h"
#import "CDSiteDataApiClient.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface PictureListViewController (Private)
- (void) fetchAlbumPictures;
- (void) showAlertViewWithMessage:(NSString *)message;
@end

@implementation PictureListViewController

@synthesize albumid;
@synthesize pictures;

- (id)initWithAlbumID:(NSUInteger)album_id
{
    self = [super init];
    if (self) {
        self.albumid = album_id;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    [pictures release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    
    gmGridView.style = GMGridViewStyleSwap;
    gmGridView.itemSpacing = PICTURE_CELL_PADDING;
    gmGridView.minEdgeInsets = UIEdgeInsetsMake(PICTURE_CELL_PADDING, PICTURE_CELL_PADDING, PICTURE_CELL_PADDING, PICTURE_CELL_PADDING);
    gmGridView.centerGrid = NO;
    gmGridView.actionDelegate = self;
    gmGridView.dataSource = self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchAlbumPictures)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
    
    gmGridView.mainSuperView = self.navigationController.view;
    
    [self fetchAlbumPictures];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Grid view data source

- (NSInteger) numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [pictures count];
}

- (GMGridViewCell *) GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
        [view release];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDictionary *picture = [pictures objectAtIndex:index];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSURL *imageUrl = [NSURL URLWithString:[picture objectForKey:@"url"]];
    [imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    [cell.contentView addSubview:imageView];
    [imageView release];
    
    return cell;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(PICTURE_CELL_WIDTH, PICTURE_CELL_HEIGHT);
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    PictureDetailViewControllerViewController *pictureDetailViewController = [[PictureDetailViewControllerViewController alloc] init];
    [pictureDetailViewController setHidesBottomBarWhenPushed:YES];
    pictureDetailViewController.currentPage = position;
    pictureDetailViewController.pictures = pictures;
    
    [self.navigationController pushViewController: pictureDetailViewController animated:YES];
    [pictureDetailViewController release];
}

#pragma mark - fetch data

- (void) fetchAlbumPictures
{
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    [client setDelegate:self];
    [client fetchPicturesWithAlbumID:albumid];
}

#pragma mark - CDSiteDataApi delegate

- (void) apiClientDidStartedRequest:(CDSiteDataApiClient *)client
{
    [MBProgressHUD hideHUDForView:self.parentViewController.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)apiClient didFinishedRequestResponse:(id)response
{
    NSDictionary *responseData = (NSDictionary *)response;
    if ([[responseData objectForKey:@"error"] isEqualToString:@"OK"]) {
        NSMutableArray *latestPictures = (NSMutableArray *)[responseData objectForKey:@"pictures"];
        if ([latestPictures count] > 0) {
            self.pictures = latestPictures;
            [gmGridView reloadData];
        }
        else 
            [self showAlertViewWithMessage:@"此图库还没有图片，正在更新中..."];
    }
    else 
        [self showAlertViewWithMessage:@"当前相册暂无图片"];
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






