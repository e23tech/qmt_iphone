//
//  CDSiteDataApiDelegate.h
//  quanmeiti
//
//  Created by Chen Dong on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDSiteDataApiClient;

@protocol CDSiteDataApiDelegate <NSObject>

@optional
- (void) apiClientDidStartedRequest:(CDSiteDataApiClient *)client;
- (void) apiClient:(CDSiteDataApiClient *)client didFinishedRequestResponse:(id)response;
- (void) apiClient:(CDSiteDataApiClient *)client didFailedRequestError:(NSError *)error;
- (void) apiClientDidCompletedRequest:(CDSiteDataApiClient *)client;
- (void) apiClient:(CDSiteDataApiClient *)client sendRequestException:(NSException *)exception;
- (void) apiClient:(CDSiteDataApiClient *)client uploadProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
@end
