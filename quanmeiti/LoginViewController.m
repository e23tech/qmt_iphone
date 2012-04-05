//
//  LoginViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginForm.h"
#import "CDSiteDataApiClient.h"
#import "MBProgressHUD.h"

@interface LoginViewController (Private)
- (void) onLogin:(QButtonElement *)button;
- (void) onCancel:(QButtonElement *)button;
@end

@implementation LoginViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    self.quickDialogTableView.backgroundColor = [UIColor colorWithHue:0.1174 saturation:0.7131 brightness:0.8618 alpha:1.0000];
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;
    
    ((QEntryElement *)[self.root elementWithKey:@"username"]).delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor colorWithRed:0.9582 green:0.9104 blue:0.7991 alpha:1.0000];
    
    if ([element isKindOfClass:[QEntryElement class]] || [element isKindOfClass:[QButtonElement class]]){
        cell.textLabel.textColor = [UIColor colorWithRed:0.6033 green:0.2323 blue:0.0000 alpha:1.0000];
    }   
}

- (void) QEntryShouldReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell
{
    NSLog(@"should return");
}

- (void) QEntryMustReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell
{
    NSLog(@"must return");
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell
{
//    NSLog(@"editing changed");
}

#pragma mark - selector

- (void) onCancel:(QButtonElement *)button;
{
    [self dismissModalViewControllerAnimated:YES];
    UITabBarController *rootController = (UITabBarController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootController setSelectedIndex:0];
}

- (void) onLogin:(QButtonElement *)button
{
    LoginForm *form = [[[LoginForm alloc] init] autorelease];
    [self.root fetchValueIntoObject:form];

    if (form.username.length == 0) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:form.username forKey:@"user_login_name"];

    
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    client.delegate = self;
    [client userLogin:form];
    
}

- (void)apiClientDidStartedRequest:(CDSiteDataApiClient *)client
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void) apiClientDidCompletedRequest:(CDSiteDataApiClient *)client
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)client didFinishedRequestResponse:(id)response
{
    NSDictionary *responseData = (NSDictionary *)response;

    if ([[responseData objectForKey:@"error"] isEqualToString:@"OK"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"user_is_logined"];
        NSDictionary *userinfo = [responseData objectForKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] setObject:userinfo forKey:@"cache_user_info"];
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录出错" message:@"用户名或密码不正确，请更正重试" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

- (void) apiClient:(CDSiteDataApiClient *)client didFailedRequestError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录出错" message:@"登录过程中发生了出错，请重试一下" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

- (void) apiClient:(CDSiteDataApiClient *)client sendRequestException:(NSException *)exception
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登录出错" message:@"我们的程序发生了一点小小的错误，我们会尽快解决" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
}

@end
