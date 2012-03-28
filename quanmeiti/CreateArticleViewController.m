//
//  CreateArticleViewController.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "constant.h"
#import "CreateArticleViewController.h"
#import "ArticleListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MTStatusBarOverlay.h"
#import "CDSiteDataApiClient.h"

static CGFloat const KEYBORD_HEIGHT = 216.0f;
static CGFloat const PADDING = 10.0f;
static NSUInteger const IMAGE_MAX_COUNT = 3;

@interface CreateArticleViewController (Private)

- (void) setupScrollView;
- (void) setupTextView;
- (void) setupBottomToolbar;
- (void) setupImageViews;
- (BOOL) imageCountLimitAlert;
- (void) afterPickerImage:(UIImage *)image;
@end

@implementation CreateArticleViewController

@synthesize post = _post;
@synthesize pageScrollView;
@synthesize articleTextView;
@synthesize postButton;
@synthesize hideKeyboardButton;
@synthesize navigationBar;
@synthesize hud;

- (id) init
{
    self = [super init];
    if (self) {
        imagesData = [[NSMutableArray alloc] initWithCapacity:3];
        imageViews = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

- (id) initWithPost:(NSDictionary *)post
{
    self = [self init];
    if (self) {
        self.post = post;
    }
    
    return self;
}

- (void) dealloc
{
    [imagesData release];
    [imageViews release];
    [hud release];
    [articleTextView release];
    [pageScrollView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"投稿";

    UIBarButtonItem *hideKeyboardButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    self.hideKeyboardButton = hideKeyboardButtonItem;
    [hideKeyboardButtonItem release];
    
    UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleBordered target:self action:@selector(postArticle)];
    self.postButton = postButtonItem;
    [postButtonItem release];
    if (articleTextView.text.length > 0)
        self.navigationItem.rightBarButtonItem = postButtonItem;
    
    
    [self setupScrollView];
    
    [self setupBottomToolbar];
    
    
    MBProgressHUD *_hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _hud.mode = MBProgressHUDModeDeterminate;
    _hud.labelText = @"正在上传数据...";
    _hud.detailsLabelText = @"正在上传数据...请勿关闭程序";
    self.hud = _hud;
    [self.navigationController.view addSubview:hud];
    [_hud release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.pageScrollView = nil;
    self.articleTextView = nil;
    self.hud = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [articleTextView resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVBAR_HEIGHT - TOOLBAR_HEIGHT);
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height + 1);
    scrollView.userInteractionEnabled = YES;
    scrollView.scrollEnabled = YES;
    self.pageScrollView = scrollView;
    [scrollView release];
    
    [self.view addSubview:pageScrollView];
    
    [self setupTextView];
    [self setupImageViews];
}

- (void) setupTextView
{
    CGRect textViewFrame = CGRectMake(PADDING/2, PADDING, self.view.frame.size.width-PADDING, 250);
    UITextView *editTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.articleTextView = editTextView;
    [editTextView release];
    
    articleTextView.delegate = self;
    articleTextView.editable = YES;
    articleTextView.font = [UIFont systemFontOfSize:16.0];
    articleTextView.textColor = [UIColor grayColor];
    articleTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    articleTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    articleTextView.scrollEnabled = YES;
    [articleTextView setKeyboardType:UIKeyboardTypeDefault];
    [articleTextView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    articleTextView.clipsToBounds = YES;
    [articleTextView enablesReturnKeyAutomatically];
    
    articleTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    articleTextView.layer.borderWidth = 1.0;
    articleTextView.layer.cornerRadius = 8;
    
    NSString *textString = (NSString *)[_post objectForKey:@"content"];
    if (textString.length > 0)
        articleTextView.text = textString;
    
    
    [pageScrollView addSubview:articleTextView];
}

- (void) setupBottomToolbar
{
    CGFloat toolbarY = self.view.frame.size.height - TOOLBAR_HEIGHT - NAVBAR_HEIGHT;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolbarY, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *addPictureButton = [[UIBarButtonItem alloc] initWithTitle:@"图库" style:UIBarButtonItemStyleBordered target:self action:@selector(selectPicture)];
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithTitle:@"拍照" style:UIBarButtonItemStyleBordered target:self action:@selector(cameraPicture)];
//    UIBarButtonItem *addVideoButton = [[UIBarButtonItem alloc] initWithTitle:@"视频" style:UIBarButtonItemStyleBordered target:self action:@selector(selectVideo)];
//    UIBarButtonItem *recordButton = [[UIBarButtonItem alloc] initWithTitle:@"录制" style:UIBarButtonItemStyleBordered target:self action:@selector(recordVideo)];
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
//    NSArray *items = [NSArray arrayWithObjects:addVideoButton, recordButton, flexButton, cameraButton, addPictureButton, nil];
    NSArray *items = [NSArray arrayWithObjects:cameraButton, flexButton, addPictureButton, nil];
//    [addVideoButton release];
    [addPictureButton release];
    [flexButton release];
    [cameraButton release];
//    [recordButton release];
    toolbar.items = items;
    
    [self.view addSubview:toolbar];
    [toolbar release];
    
    
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"show keyborad, post:%d, hide:%d", postButton.retainCount, hideKeyboardButton.retainCount);
    [articleTextView becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = hideKeyboardButton;
}

- (void) gotoArticleList
{
    ArticleListViewController *articleListController = [[ArticleListViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:articleListController animated:YES];
    [articleListController release];
}


- (void) hideKeyboard
{
    [articleTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = postButton;
}


#pragma mark selector

- (void) selectPicture
{
    BOOL alertState = [self imageCountLimitAlert];
    if (alertState == NO) return;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    NSArray *imageMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"image"]];
    pickerController.mediaTypes = imageMediaTypesOnly;
//    NSLog(@"%@", pickerController.mediaTypes);
    
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
    
}

- (void) cameraPicture
{
    BOOL alertState = [self imageCountLimitAlert];
    if (alertState == NO) return;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return;

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    pickerController.delegate = self;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"image"]];
    pickerController.mediaTypes = videoMediaTypesOnly;
//    NSLog(@"%@", pickerController.mediaTypes);
    
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

- (void) selectVideo
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    NSArray *imageMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
    pickerController.mediaTypes = imageMediaTypesOnly;
//    NSLog(@"%@", pickerController.mediaTypes);

    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}


- (void) recordVideo
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return;
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    pickerController.delegate = self;
    pickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
    pickerController.mediaTypes = videoMediaTypesOnly;
//    NSLog(@"%@", pickerController.mediaTypes);
    
    [self presentModalViewController:pickerController animated:YES];
    [pickerController release];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedOverlay];
            
            NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            NSArray *imageMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"image"]];
            NSArray *videoMediaTypesOnly = [mediaTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains %@)", @"movie"]];
            if ([imageMediaTypesOnly isEqual:picker.mediaTypes]) {
                [overlay postImmediateMessage:@"正在保存照片..." animated:YES];
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                NSLog(@"camera photo library");
            }
            else if ([videoMediaTypesOnly isEqual:picker.mediaTypes]) {
                NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
                    [overlay postImmediateMessage:@"正在保存短片..." animated:YES];
                    UISaveVideoAtPathToSavedPhotosAlbum (moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
            }
            else {
                NSLog(@"no valid media");
            }
            
            NSLog(@"camera");
        }
        else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            NSLog(@"photo library");
            UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self afterPickerImage:pickerImage];
        }
        else 
            NSLog(@"other source type:%d", picker.sourceType);
        
//        NSLog(@"info: %@", info);
    }];
}


- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    NSLog(@"picker cancel: %d", picker.sourceType);
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedOverlay];
    
    if (error)
        [overlay postErrorMessage:@"保存照片出错" duration:1.0f animated:YES];
    else {
        [overlay postFinishMessage:@"照片已经保存到相册中" duration:1.0f animated:YES];
        [self afterPickerImage:image];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void) video:(NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedOverlay];
    
    if (error)
        [overlay postErrorMessage:@"保存短片出错" duration:1.0f animated:YES];
    else
        [overlay postFinishMessage:@"短片已经保存到相册中" duration:1.0f animated:YES];
}

- (void) setupImageViews
{
    CGFloat imageViewWidth = 93.3f;
    CGFloat imageViewHeight = 80.0f;
    CGFloat imageViewPadding = 10.0f;
    CGFloat imageViewY = articleTextView.frame.origin.y + articleTextView.frame.size.height + 10;
    for (int i=0; i<IMAGE_MAX_COUNT; i++) {
        CGFloat imageViewX = imageViewPadding * (i + 1) + imageViewWidth * i;
        CGRect frame = CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        
        [imageViews addObject:imageView];
        [imageView release];
    }
}

- (void) afterPickerImage:(UIImage *)image
{
    [imagesData addObject:image];
    NSUInteger index = [imagesData count] - 1;
    UIImageView *imageView = (UIImageView *)[imageViews objectAtIndex:index];
    imageView.image = image;
}

- (BOOL)imageCountLimitAlert
{
    if ([imagesData count] == IMAGE_MAX_COUNT) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"一次只允许上传3张图片" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        return NO;
    }
    else
        return YES;
    
}


#pragma mark - upload CDSiteDataApiClient delegate

- (void) postArticle
{
//    NSLog(@"Post: %@", imagesData);
    NSUInteger userid = [LoginForm cacheUserid];
    NSUInteger postid = [[_post objectForKey:@"id"] integerValue];
    CDSiteDataApiClient *client = [CDSiteDataApiClient instanceClient];
    client.delegate = self;
    [client uploadArticle:articleTextView.text images:imagesData userID:userid postID:postid];
}

- (void) apiClientDidStartedRequest:(CDSiteDataApiClient *)client
{
    NSLog(@"upload start");
    [hud show:YES];
}

- (void) apiClient:(CDSiteDataApiClient *)client didFinishedRequestResponse:(id)response
{
    NSLog(@"upload finish request: %@", response);
}

- (void) apiClient:(CDSiteDataApiClient *)client didFailedRequestError:(NSError *)error
{
    NSLog(@"upload error: %@", error);
}

- (void) apiClient:(CDSiteDataApiClient *)client sendRequestException:(NSException *)exception
{
    NSLog(@"upload exception: %@", exception);
}

- (void) apiClientDidCompletedRequest:(CDSiteDataApiClient *)client
{
    NSLog(@"upload complete");
    [hud hide:YES];
    articleTextView.text = nil;
    for (UIImageView *imageView in imageViews) {
        [imageView removeFromSuperview];
    }
    [imagesData removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) apiClient:(CDSiteDataApiClient *)client uploadProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    CGFloat progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    hud.progress = progress;
}

@end



