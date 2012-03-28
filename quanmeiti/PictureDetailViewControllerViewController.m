//
//  PictureDetailViewControllerViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PictureDetailViewControllerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MTStatusBarOverlay.h"

static const CGFloat TOOLBAR_HEIGHT = 40.0;
static const CGFloat TITLE_LABEL_HEIGHT = 40;
static UIWindow *statusWindow;

@interface PictureDetailViewControllerViewController (private)
- (void) setupImageViews;
- (void) setupTitleLabel;
- (void) setupBottomToolbar;
- (void) setHideOtherControls:(BOOL)hide;
- (void) loadScrollViewWithPage:(NSUInteger)page;
- (void) initLoadImageViews;
@end

@implementation PictureDetailViewControllerViewController

@synthesize currentPage;
@synthesize imageScrollView;
@synthesize titleLabel;
@synthesize imageViews;
@synthesize pictures;
@synthesize bottomToolbar;

- (id)init
{
    self = [super init];
    if (self) {
        self.currentPage = 0;
    }
    return self;
}

- (void) dealloc
{
    [titleLabel release];
    [imageViews release];
    [bottomToolbar release];
    [pictures release];
    [imageScrollView release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    [backButtonItem release];
    
    [self setupImageView];
    [self setupBottomToolbar];
    [self setupTitleLabel];
    
    [self initLoadImageViews];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.titleLabel = nil;
    self.bottomToolbar = nil;
    self.imageScrollView = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark setup ui control

- (void) setupImageView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.imageScrollView = scrollView;
    [scrollView release];
    
    CGFloat scrollViewWidth = [pictures count] * self.view.frame.size.width;
    imageScrollView.contentSize = CGSizeMake(scrollViewWidth, self.view.frame.size.height);
    imageScrollView.contentMode = UIViewContentModeScaleAspectFit;
    imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageScrollView.pagingEnabled = YES;
    imageScrollView.scrollEnabled = YES;
    imageScrollView.delegate = self;
    imageScrollView.maximumZoomScale = 1.0;
    imageScrollView.minimumZoomScale = 1.0;
    imageScrollView.alpha = 0.9;
    imageScrollView.backgroundColor = [UIColor blackColor];
    
    self.imageViews = [NSMutableArray array];
    for (NSUInteger i=0; i<pictures.count; i++) {
        [imageViews addObject:[NSNull null]];
    }
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    recognizer.numberOfTapsRequired = 1;
    [imageScrollView addGestureRecognizer:recognizer];
    [recognizer release];
    
    [self.view addSubview:imageScrollView];
    
}

- (void) loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= pictures.count) return;
	
    UIImageView *imageView = [imageViews objectAtIndex:page];
    if ((NSNull *)imageView == [NSNull null]) {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        NSDictionary *picture = (NSDictionary *)[pictures objectAtIndex:page];
        NSURL *imageUrl = [NSURL URLWithString:[picture objectForKey:@"url"]];
        [imageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

        [imageViews replaceObjectAtIndex:page withObject:imageView];
        [imageView release];
    }
	
    // add the imageView to the scroll view
    if (nil == imageView.superview) {
        CGRect frame = imageScrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageView.frame = frame;
        [imageScrollView addSubview:imageView];
    }
}

- (void) initLoadImageViews
{
    if (currentPage > 0) {
        [self loadScrollViewWithPage:currentPage];
        [self loadScrollViewWithPage:currentPage - 1];
        [self loadScrollViewWithPage:currentPage + 1];
        
        CGRect frame = imageScrollView.frame;
        frame.origin.x = frame.size.width * currentPage;
        frame.origin.y = 0;
        [imageScrollView scrollRectToVisible:frame animated:NO];
    }
    else {
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
}

- (void) setupTitleLabel
{
    CGFloat labelFrameY = self.view.frame.size.height - bottomToolbar.frame.size.height - TITLE_LABEL_HEIGHT;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelFrameY, self.view.frame.size.width, TITLE_LABEL_HEIGHT)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = self.title;
    self.titleLabel = label;
    [label release];
    
    NSString *title = [[pictures objectAtIndex:0] objectForKey:@"desc"];
    titleLabel.text = title;
    
    [self.view addSubview:titleLabel];
}

- (void) setupBottomToolbar
{
    CGRect frame = CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT);
    
    UIToolbar *navbar = [[UIToolbar alloc] initWithFrame:frame];
    self.bottomToolbar = navbar;
    [navbar release];
    
    [bottomToolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexButton];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存到相册" style:UIBarButtonItemStyleBordered target:self action:@selector(savePicture:)];
    [items addObject:saveButton];
    [saveButton release];
    [flexButton release];
    
    bottomToolbar.items = items;
    
    [self.view addSubview:bottomToolbar];
}

#pragma mark tapImageView

- (void) tapImageView:(UITapGestureRecognizer *)recognizer
{
    static BOOL isHidden = NO;
    isHidden = !isHidden;
    
    [self.navigationController.navigationBar setHidden:isHidden];
    [self.bottomToolbar setHidden:isHidden];
    
    NSString *title = [[pictures objectAtIndex:recognizer.view.tag] objectForKey:@"desc"];
    if (title != NULL)
        [self.titleLabel setHidden:isHidden];

    
    if (statusWindow == nil) {
        CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
        statusWindow = [[UIWindow alloc] initWithFrame:frame];
        statusWindow.windowLevel = UIWindowLevelAlert;
        statusWindow.backgroundColor = [UIColor blackColor];
    }
    
    if ([statusWindow isHidden])
        [statusWindow makeKeyAndVisible];
    else
        [statusWindow setHidden:YES];
    
}

#pragma mark UIScrollView delegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [imageViews objectAtIndex:currentPage];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    NSLog(@"scrollViewDidEndZooming, %f", view.frame.size.height);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, scale, scale);
    view.transform = transform;
    
    CGSize size = scrollView.bounds.size;
    CGFloat imageViewY = 0.0;
    if (view.frame.size.height < size.height)
        imageViewY = (size.height - view.frame.size.height) / 2;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	view.frame = CGRectMake(view.frame.origin.x, imageViewY, view.frame.size.width, view.frame.size.height);
    [UIView commitAnimations];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self loadScrollViewWithPage:currentPage];
    [self loadScrollViewWithPage:currentPage - 1];
    [self loadScrollViewWithPage:currentPage + 1];
 
    if (currentPage < pictures.count) {
        NSString *title = (NSString *)[[pictures objectAtIndex:currentPage] objectForKey:@"desc"];
        titleLabel.text = title;
    }

}


- (void) savePicture:(id) sender
{
    UIImageView *imageView = [imageViews objectAtIndex:currentPage];
    if (imageView.image == nil)
        return;
    
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedOverlay];
    [overlay postImmediateMessage:@"正在保存图片" animated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedOverlay];
    
    if (error)
        [overlay postErrorMessage:@"保存图片出错" duration:1.0 animated:YES];
    else
        [overlay postFinishMessage:@"图片已经保存到相册中" duration:1.0 animated:YES];
}

@end
