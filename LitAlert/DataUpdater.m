//
//  DataUpdater.m
//  LitAlert
//
//  Created by Mushfiqur Rahman on 12/6/13.
//  Copyright (c) 2013 IMpulse (BD) Ltd. All rights reserved.
//

#import "DataUpdater.h"

@implementation DataUpdater

NSString *const userName = @"elitalerts"; //@"elit-alert";
NSString *const password = @"45xr61ElitAlerts"; //@"45xr61ElitAlert";
NSArray *trustedHosts;

+ (void)sendUserTokenWithURL:(NSString *)ServerUrl {
    
    trustedHosts = @[@"elitalerts.impulsebdltd.com"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"apnsTokenSentSuccessfully"]) {
        //NSLog(@"apnsTokenSentSuccessfully already");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:ServerUrl]; //set here your URL
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *stringData = [NSString stringWithFormat:@"username=%@&password=%@&token=%@",userName,password,[[NSUserDefaults standardUserDefaults] objectForKey:@"apnsToken"]];
    
   // NSLog(@"Token register postbody: %@",stringData);
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    [NSURLConnection connectionWithRequest:request delegate:self];

}


+ (void)sendBadgeCountResetWithURL:(NSString *)ServerUrl {
    
    trustedHosts = @[@"elitalerts.impulsebdltd.com"];
    
    NSURL *url = [NSURL URLWithString:ServerUrl]; //set here your URL
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    
    NSMutableURLRequest *request =  [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *stringData = [NSString stringWithFormat:@"username=%@&password=%@&token=%@",userName,password,[[NSUserDefaults standardUserDefaults] objectForKey:@"apnsToken"]];  //this will set badgeCount = 0 in server;
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}


#pragma
#pragma mark- NSURLConnection Delegate


+(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   // NSLog(@"Error with connection in token sending: %@", [error localizedDescription]);
}


+(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   // NSLog(@"NSURLconnectionDidFinishLoading of token register/ reset badge count");
    
}

+ (BOOL) connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    
}

+ (void) connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
        {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            //NSLog(@"challenge.protectionSpace.host::: in trusted host %@",challenge.protectionSpace.host);
        }
        else
        {
            //NSLog(@"trusthost not called");
            //NSLog(@"challenge.protectionSpace.host::: %@",challenge.protectionSpace.host);
        }
    }
    else
    {
        //NSLog(@"not truest server");
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    
}



@end
