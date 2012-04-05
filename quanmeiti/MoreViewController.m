//
//  MoreViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "TestViewController.h"
#import "LoginForm.h"
#import "constant.h"

@interface MoreViewController (Private)
- (void) userLogout:(QButtonElement *)button;
@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

- (void) aboutme:(QLabelElement *)label
{
    NSLog(@"about me");
}


- (void) gotoAppStoreRating:(QLabelElement *)label
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app//id486268988?mt=8"]];
}

#pragma mark MFMessageComposeViewController

- (void) shareToFriend:(QLabelElement *)label
{
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
	if([MFMessageComposeViewController canSendText]) {
		controller.body = APP_STORE_URL;
		controller.messageComposeDelegate = self;
		[self.view.window.rootViewController presentModalViewController:controller animated:YES];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"短信发送成功" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    else
        NSLog(@"send sms error, result: %d", result);
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void) test:(QButtonElement *)button
{
    TestViewController *testController = [[TestViewController alloc] init];
    testController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:testController animated:YES];
    [testController release];
}


@end
