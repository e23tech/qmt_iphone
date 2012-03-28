//
//  ArticleListViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ArticleListViewController.h"
#import "CreateArticleViewController.h"
#import "CDQDRootElementBuilder.h"
#import "LoginViewController.h"
#import "LoginForm.h"
#import "CDSiteDataApiClient.h"
#import "MTStatusBarOverlay.h"
#import "CDPostListTableViewCell.h"
#import "PostDetailViewController.h"

@interface ArticleListViewController (Private)
- (void) fetchContributePosts;
@end

@implementation ArticleListViewController

@synthesize articles;

- (void) dealloc
{
    [articles release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    UIBarButtonItem *rightButtomItem = [[UIBarButtonItem alloc] initWithTitle:@"投稿" style:UIBarButtonItemStyleBordered target:self action:@selector(gotoCreateArticleController:)];
    self.navigationItem.rightBarButtonItem = rightButtomItem;
    [rightButtomItem release];
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL userIsLogined = [LoginForm userIsLogined];
    
    if (userIsLogined == NO) {
        [self performSelector:@selector(gotoUserLoginController:)];
    }
    else if ([articles count] == 0) {
        [self fetchContributePosts];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [articles count];
}

- (CDPostListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CDPostListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[CDPostListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *article = [articles objectAtIndex:indexPath.row];
    cell.dateLabel.text = [article objectForKey:@"create_time_text"];
    cell.titleLabel.text = [article objectForKey:@"title"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
//    PostDetailViewController *detailViewController = [[PostDetailViewController alloc] init];
//    detailViewController.post = [articles objectAtIndex:indexPath.row];
//    [detailViewController setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
    
    NSDictionary *post = [articles objectAtIndex:indexPath.row];
    CreateArticleViewController *createArticleController = [[CreateArticleViewController alloc] initWithPost:post];
    createArticleController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createArticleController animated:YES];
    [createArticleController release];
}

#pragma mark - button selector

- (void) gotoCreateArticleController:(id)sender
{
    BOOL userIsLogined = [LoginForm userIsLogined];
    if (userIsLogined == NO) {
        [self performSelector:@selector(gotoUserLoginController:)];
        return;
    }
    
    CreateArticleViewController *createArticleController = [[CreateArticleViewController alloc] init];
    createArticleController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:createArticleController animated:YES];
    [createArticleController release];
}

- (void) gotoUserLoginController:(id)sender
{
    QRootElement *root = [CDQDRootElementBuilder createLoginRoot];
    QuickDialogController *loginViewController = [QuickDialogController controllerForRoot:root];
    loginViewController.hidesBottomBarWhenPushed = YES;
    [self presentModalViewController:loginViewController animated:YES];
}


#pragma mark - private methods

-(void) fetchContributePosts
{
    BOOL userIsLogined = [LoginForm userIsLogined];
    
    if (userIsLogined == NO) {
        [self stopLoading];
        return;
    }
        
    NSUInteger userid = [LoginForm cacheUserid];
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    client.delegate = self;
    [client fetchUserContributePostsWithUserID:userid];
}

- (void) apiClientDidStartedRequest:(CDSiteDataApiClient *)client
{
    [[MTStatusBarOverlay sharedOverlay] postImmediateMessage:@"正在请求数据..." animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)client didFinishedRequestResponse:(id)response
{
    NSDictionary *responseData = (NSDictionary *)response;
    if ([[responseData objectForKey:@"error"] isEqualToString:@"OK"]) {
        NSMutableArray *posts = (NSMutableArray *)[responseData objectForKey:@"posts"];
        NSUInteger postCount = [posts count];
        if (postCount > 0) {
            self.articles = posts;
            [self.tableView reloadData];
        }
        [[MTStatusBarOverlay sharedOverlay] postMessage:[NSString stringWithFormat:@"共更新了%d篇文章", articles.count] animated:YES];
    }
    else
        [[MTStatusBarOverlay sharedOverlay] postImmediateErrorMessage:@"更新数据出错" duration:1.0 animated:YES];

}

- (void) apiClient:(CDSiteDataApiClient *)client didFailedRequestError:(NSError *)error
{
    [[MTStatusBarOverlay sharedOverlay] postImmediateErrorMessage:@"更新数据出错" duration:1.0 animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)client sendRequestException:(NSException *)exception
{
    [[MTStatusBarOverlay sharedOverlay] postImmediateErrorMessage:@"程序发生错误" duration:1.0 animated:YES];
}

- (void) apiClientDidCompletedRequest:(CDSiteDataApiClient *)client
{
    [[MTStatusBarOverlay sharedOverlay] postFinishMessage:@"更新数据完成" duration:1.0 animated:YES];
    [self stopLoading];
}


#pragma mark - pull to refresh

- (void)setupStrings
{
    textPull = [[NSString alloc] initWithString:@"下拉刷新..."];
    textRelease = [[NSString alloc] initWithString:@"释放立即刷新..."];
    textLoading = [[NSString alloc] initWithString:@"正在刷新..."];
}

- (void) refresh
{
    [self fetchContributePosts];
}

@end
