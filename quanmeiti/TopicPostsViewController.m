//
//  PostListViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TopicPostsViewController.h"
#import "CDPostListTableViewCell.h"
#import "PostDetailViewController.h"
#import "CDSiteDataApiClient.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface TopicPostsViewController (Private)
- (void) fetchTopicPosts;
- (void) showAlertViewWithMessage:(NSString *)message;
@end

@implementation TopicPostsViewController

@synthesize topicid;
@synthesize posts;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (id) initWithStyle:(UITableViewStyle)style topicID:(NSUInteger)tid
{
    self = [super initWithStyle:style];
    if (self) {
        NSLog(@"topic id: %d", tid);
        self.topicid = tid;
    }
    return self;
}

- (void) dealloc
{
    [posts release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchTopicPosts)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [rightButtonItem release];

    self.clearsSelectionOnViewWillAppear = YES;
    
    [self fetchTopicPosts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [posts count];
}

- (CDPostListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CDPostListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CDPostListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *post = [posts objectAtIndex:indexPath.row];
    cell.titleLabel.text = [post objectForKey:@"title"];
    cell.dateLabel.text = [post objectForKey:@"create_time_text"];
    cell.countLabel.text = [post objectForKey:@"visit_nums"];
    
    NSURL *imageUrl = [NSURL URLWithString:[post objectForKey:@"thumbnail"]];
    [cell.thumbnailView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostDetailViewController *detailViewController = [[PostDetailViewController alloc] init];
    detailViewController.post = [posts objectAtIndex:indexPath.row];
    [detailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

#pragma mark - fetch data

- (void) fetchTopicPosts
{
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    [client setDelegate:self];
    [client fetchTopicPosts:topicid];
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
        NSMutableArray *topicPosts = [responseData objectForKey:@"posts"];
        if ([topicPosts count] > 0) {
            self.posts = topicPosts;
            [self.tableView reloadData];
        }
        else 
            [self showAlertViewWithMessage:@"此专题还没有文章，正在更新中..."];
    }
    else {
        [self showAlertViewWithMessage:@"当前服务器正在进行系统升级，请稍候重试"];
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
