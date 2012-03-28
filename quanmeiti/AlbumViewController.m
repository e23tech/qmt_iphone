//
//  AlbumViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "constant.h"
#import "AlbumViewController.h"
#import "PictureListViewController.h"
#import "CDSiteDataApiClient.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface AlbumViewController (Private)
- (void) fetchAlbumData;
- (void) showAlertViewWithMessage:(NSString *)message;
@end

@implementation AlbumViewController

@synthesize albums;

- (id)init
{
    self = [super init];
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

- (void) dealloc
{
    [albums release];
    [super dealloc];
}

#pragma mark - View lifecycle


 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
     [super loadView];
     
     self.view.backgroundColor = [UIColor whiteColor];
     
     gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
     gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     gmGridView.backgroundColor = [UIColor clearColor];
     [self.view addSubview:gmGridView];

     gmGridView.style = GMGridViewStyleSwap;
     gmGridView.itemSpacing = ALBUM_CELL_PADDING;
     gmGridView.minEdgeInsets = UIEdgeInsetsMake(ALBUM_CELL_PADDING, ALBUM_CELL_PADDING, ALBUM_CELL_PADDING, ALBUM_CELL_PADDING);
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
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchAlbumData)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];
    gmGridView.mainSuperView = self.navigationController.view;
    
    [self fetchAlbumData];
    
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
    return [albums count];
}

- (GMGridViewCell *) GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
        [view release];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSDictionary *album = [albums objectAtIndex:index];
    CGRect imageViewFrame = cell.contentView.frame;
    imageViewFrame.size.height -= ALBUM_CELL_TITLE_LABEL_HEIGHT;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    NSURL *imageUrl = [NSURL URLWithString:[album objectForKey:@"thumbnail"]];
    [imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [cell.contentView addSubview:imageView];
    
    CGRect titleLabelFrame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height, imageView.frame.size.width, ALBUM_CELL_TITLE_LABEL_HEIGHT);
    UILabel *titelLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    titelLabel.text = (NSString *)[album objectForKey:@"title"];
    titelLabel.backgroundColor = [UIColor colorWithWhite:.3 alpha:.3];
    titelLabel.textColor = [UIColor grayColor];
    titelLabel.font = [UIFont systemFontOfSize:12.0f];
    [cell.contentView addSubview:titelLabel];
    
    [imageView release];
    [titelLabel release];
    
    return cell;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(ALBUM_CELL_WIDTH, ALBUM_CELL_HEIGHT);
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSDictionary *album = [albums objectAtIndex:position];
    NSUInteger albumid = [[album objectForKey:@"id"] intValue];
    PictureListViewController *picListViewController = [[PictureListViewController alloc] initWithAlbumID:albumid];
    [picListViewController setHidesBottomBarWhenPushed:YES];
    
    [self.navigationController pushViewController: picListViewController animated:YES];
    [picListViewController release];
}

#pragma mark - fetch data

- (void) fetchAlbumData
{
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    [client setDelegate:self];
    [client fetchAlbums];
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
        NSMutableArray *latestAlbums = (NSMutableArray *)[responseData objectForKey:@"albums"];
        if ([latestAlbums count] > 0) {
            self.albums = latestAlbums;
            [gmGridView reloadData];
        }
        else 
            [self showAlertViewWithMessage:@"现在还没有图库，正在更新中..."];
    }
    else {
        [self showAlertViewWithMessage:@"服务器正在进行系统升级，请稍候重试"];
    }
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






