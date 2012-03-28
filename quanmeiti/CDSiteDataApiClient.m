//
//  QuanMeiTiApi.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CDSiteDataApiClient.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPRequestOperation.h"
#import "UIImage+Scale.h"

static NSUInteger const CD_HOTTEST_POSTS_COUNT = 5;
static NSUInteger const CD_LATTEST_POSTS_COUNT = 40;
static NSUInteger const CD_TOPICS_COUNT = 20;
static NSUInteger const CD_ALBUMS_COUNT = 15;

static NSString * const CD_API_HOST = @"http://qmt.e23.cn";
static NSString * const CD_API_KEY = @"123";

static NSString * const CD_API_HOTTEST_LATEST_POSTS_METHOD = @"post.hottest_latest";
static NSString * const CD_API_HOTTEST_POSTS_METHOD = @"post.hottest";
static NSString * const CD_API_LATEST_POSTS_METHOD = @"post.timeline";
static NSString * const CD_API_TOPICS_METHOD = @"topic.latest";
static NSString * const CD_API_ALBUMS_METHOD = @"album.latest";

@interface CDSiteDataApiClient (Private)
- (NSMutableDictionary *) makeBaseParams;
- (void) sendGetRequestWithPath:(NSString *)path params:(NSMutableDictionary *)params;
- (void) sendPostRequestWithPath:(NSString *)path params:(NSMutableDictionary *)params;
- (void) sendPostUploadRequestWithPath:(NSString *)path filesData:(NSArray *)filesData params:(NSMutableDictionary *)params;
@end

@implementation CDSiteDataApiClient

@synthesize tag;
@synthesize debug;
@synthesize delegate;

- (id)initWithBaseURL:(NSURL *)url 
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-CD-API-Key" value:CD_API_KEY];
	[self setDefaultHeader:@"X-CD-API-Version" value:@"1.0"];
	[self setDefaultHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSMutableDictionary *) makeBaseParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:CD_API_KEY, @"apikey", 
                                   @"json", @"format",
                                   nil];
    return params;
}

+ (CDSiteDataApiClient *)instanceClient 
{
    return (CDSiteDataApiClient *)[self clientWithBaseURL:[NSURL URLWithString:CD_API_HOST]];
}

- (void) sendGetRequestWithPath:(NSString *)path params:(NSMutableDictionary *)params
{
    if (path == nil) path = @"/api";
    
    if ([self.delegate respondsToSelector:@selector(apiClientDidStartedRequest:)])
        [self.delegate apiClientDidStartedRequest:self];
    
    @try {
        [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFinishedRequestResponse:)])
                [self.delegate apiClient:self didFinishedRequestResponse:response];
            
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFailedRequestError:)])
                [self.delegate apiClient:self didFailedRequestError:error];
            
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];
            
            [operation cancel];
        }];
    }
    @catch (NSException *exception) {
        if ([self.delegate respondsToSelector:@selector(apiClient:sendRequestError:)])
            [self.delegate apiClient:self sendRequestException:exception];
        

    }
    @finally {
        ;
    }
}

- (void) sendPostRequestWithPath:(NSString *)path params:(NSMutableDictionary *)params
{
    if (path == nil) path = @"/api";
    
    if ([self.delegate respondsToSelector:@selector(apiClientDidStartedRequest:)])
        [self.delegate apiClientDidStartedRequest:self];
    
    @try {
        [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFinishedRequestResponse:)])
                [self.delegate apiClient:self didFinishedRequestResponse:response];
            
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFailedRequestError:)])
                [self.delegate apiClient:self didFailedRequestError:error];
            
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];
            
            [operation cancel];
            
        }];
    }
    @catch (NSException *exception) {
        if ([self.delegate respondsToSelector:@selector(apiClient:sendRequestError:)])
            [self.delegate apiClient:self sendRequestException:exception];
        
    }
    @finally {
        ;
    }
}

- (void) sendPostUploadRequestWithPath:(NSString *)path filesData:(NSArray *)filesData params:(NSMutableDictionary *)params
{
    if (path == nil) path = @"/api";
    
    if ([self.delegate respondsToSelector:@selector(apiClientDidStartedRequest:)])
        [self.delegate apiClientDidStartedRequest:self];
    
    @try {
        NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (int i=0; i<filesData.count; i++) {
                NSData *fileData = [filesData objectAtIndex:i];
                NSString *uploadName = [NSString stringWithFormat:@"post_picture_%d.jpg", i];
                [formData appendPartWithFileData:fileData name:uploadName fileName:uploadName mimeType:@"application/octet-stream"];
            }
        }];
        [request setTimeoutInterval:300.0];
        
        AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFinishedRequestResponse:)])
                [self.delegate apiClient:self didFinishedRequestResponse:responseObject];
                
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(apiClient:didFailedRequestError:)])
                [self.delegate apiClient:self didFailedRequestError:error];
            
            [operation cancel];
            
            if ([self.delegate respondsToSelector:@selector(apiClientDidCompletedRequest:)])
                [self.delegate apiClientDidCompletedRequest:self];

        }];
        
        [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
            if ([self.delegate respondsToSelector:@selector(apiClient:uploadProgress:totalBytesWritten:totalBytesExpectedToWrite:)])
                [self.delegate apiClient:self uploadProgress:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }];
        
        [self enqueueHTTPRequestOperation:operation];
    }
    @catch (NSException *exception) {
        if ([self.delegate respondsToSelector:@selector(apiClient:sendRequestError:)])
            [self.delegate apiClient:self sendRequestException:exception];
        
    }
    @finally {
        ;
    }
}

#pragma mark - detail methods

- (void) fetchHottestPosts
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"post.hottest" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%d", CD_HOTTEST_POSTS_COUNT] forKey:@"count"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [[CDSiteDataApiClient instanceClient] getPath:CD_API_HOST parameters:params success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"%@", JSON);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
   
}

- (void) fetchLatestPosts
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"post.timeline" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%d", CD_LATTEST_POSTS_COUNT] forKey:@"count"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
    
    
}

- (void) fetchHottestAndLatestPosts
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"post.hottest_latest" forKey:@"methods"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
    
}

- (void) fetchTopics
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"special.latest" forKey:@"methods"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
}

- (void) fetchTopicPosts:(NSUInteger)topicid
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"special.posts" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%d", topicid] forKey:@"specialid"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
}

- (void) fetchAlbums
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"album.latest" forKey:@"methods"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
}

- (void) fetchPicturesWithAlbumID:(NSUInteger)albumID
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"album.pictures" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%d", albumID] forKey:@"albumid"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    [self sendGetRequestWithPath:@"/api" params:params];
}

- (void) userLogin:(LoginForm *)form
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"user.login" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%@", form.username] forKey:@"username"];
    [params setObject:[NSString stringWithFormat:@"%@", form.password] forKey:@"password"];
    
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    [self sendPostRequestWithPath:@"/api" params:params];
}

- (void) fetchUserContributePostsWithUserID:(NSUInteger)userid
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"post.contribute_posts" forKey:@"methods"];
    [params setObject:[NSString stringWithFormat:@"%d", userid] forKey:@"userid"];
    NSLog(@"userid: %d", userid);
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    [self sendGetRequestWithPath:@"/api" params:params];
}

- (void) uploadArticle:(NSString *)content images:(NSArray *)images userID:(NSUInteger)userid postID:(NSUInteger)postid
{
    NSMutableDictionary *params = [self makeBaseParams];
    [params setObject:@"post.create" forKey:@"methods"];
    [params setObject:content forKey:@"content"];
    [params setObject:[NSString stringWithFormat:@"%d", userid] forKey:@"user_id"];
    [params setObject:[NSString stringWithFormat:@"%d", postid] forKey:@"post_id"];
    if (debug) {
        [params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"debug"];
    }
    
    NSMutableArray *imagesData = [NSMutableArray array];
    CGSize smallImageSize = CGSizeMake(768.0f, 1024.0f);
    
    for (UIImage *image in images) {
        if (image.size.width > image.size.height)
            smallImageSize = CGSizeMake(1024.0f, 768.0f);
        UIImage *smallImage = [image scaleToSize:smallImageSize];
        [imagesData addObject:UIImageJPEGRepresentation(smallImage, 0.9f)];
    }
    
    [self sendPostUploadRequestWithPath:@"/api" filesData:imagesData params:params];
}

@end

