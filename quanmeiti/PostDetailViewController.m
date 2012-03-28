//
//  PostDetailViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostDetailViewController.h"

@implementation PostDetailViewController

@synthesize post;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = @"查看新闻";
    }
    return self;
}

- (void) dealloc
{
    [post release];
    [super dealloc];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSString *html = [post objectForKey:@"content"];
    [webView loadHTMLString:html baseURL:nil];
    self.view = webView;
    [webView release];
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

#pragma mark UIWebView delegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"load finished");
}

@end
