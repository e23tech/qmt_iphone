//
//  QuanMeiTiApi.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "CDSiteDataApiDelegate.h"
#import "LoginForm.h"

@interface CDSiteDataApiClient : AFHTTPClient {
    
}

@property NSInteger tag;
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, assign) id<CDSiteDataApiDelegate> delegate;

+ (CDSiteDataApiClient *) instanceClient;

- (id)initWithBaseURL:(NSURL *)url;
- (void) fetchHottestAndLatestPosts;
- (void) fetchHottestPosts;
- (void) fetchLatestPosts;
- (void) fetchTopics;
- (void) fetchTopicPosts:(NSUInteger)topicid;
- (void) fetchAlbums;
- (void) fetchPicturesWithAlbumID:(NSUInteger)albumID;
- (void) userLogin:(LoginForm *)form;
- (void) fetchUserContributePostsWithUserID:(NSUInteger)userid;
- (void) uploadArticle:(NSString *)content images:(NSArray *)images userID:(NSUInteger)userid postID:(NSUInteger)postid;
@end
