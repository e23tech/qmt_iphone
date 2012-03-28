//
//  TestViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestViewController.h"
#import "GMGridView.h"
#import <QuartzCore/QuartzCore.h>
#import "GMGridViewLayoutStrategies.h"


#define NUMBER_ITEMS_ON_LOAD 20

@interface TestViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    __gm_weak GMGridView *_gmGridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
    
    NSMutableArray *_data;
}

//- (void)addMoreItem;
//- (void)removeItem;
//- (void)refreshItem;
//- (void)presentInfo;
//- (void)presentOptions:(UIBarButtonItem *)barButton;
//- (void)optionsDoneAction;

@end

@implementation TestViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _data = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < NUMBER_ITEMS_ON_LOAD; i ++) 
        {
            [_data addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    _gmGridView = gmGridView;
    
//    _gmGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = spacing;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _gmGridView.centerGrid = YES;
    _gmGridView.actionDelegate = self;
//    _gmGridView.sortingDelegate = self;
//    _gmGridView.transformDelegate = self;
    _gmGridView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _gmGridView.mainSuperView = self.navigationController.view;
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

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_data count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    if (INTERFACE_IS_PHONE) 
    {
        return CGSizeMake(93.3, 73.3);
    }
    else
    {
        return CGSizeMake(230, 175);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell) 
    {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor redColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
//        view.layer.shadowColor = [UIColor grayColor].CGColor;
//        view.layer.shadowOffset = CGSizeMake(5, 5);
//        view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
//        view.layer.shadowRadius = 8;
        
        cell.contentView = view;
        [view release];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = (NSString *)[_data objectAtIndex:index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    [cell.contentView addSubview:label];
    [label release];
    
    return cell;
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    [_data removeObjectAtIndex:index];
}

- (void) GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"tap item view");
}

@end
