//
//  DataUpdater.h
//  LitAlert
//
//  Created by Mushfiqur Rahman on 12/6/13.
//  Copyright (c) 2013 IMpulse (BD) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUpdater : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (void)sendUserTokenWithURL:(NSString *)ServerUrl;

+ (void)sendBadgeCountResetWithURL:(NSString *)ServerUrl;

@end
