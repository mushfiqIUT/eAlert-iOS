//
//  AppDelegate.m
//  Actusmi
//
//  Created by Mushfiqur Rahman on 29/04/2013.
//  Copyright (c) 2013 Impulse BD Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DataUpdater.h"

@implementation AppDelegate

NSString *const serverRegisterUrl = @"https://elitalerts.impulsebdltd.com/elitalerts/register.php";
NSString *const serverBadgeResetUrl = @"https://elitalerts.impulsebdltd.com/elitalerts/reset.php";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //NSLog(@"Trying to register for APN in didFinishLaunchingWithOptions");
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    application.applicationIconBadgeNumber = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self registerDefaultsFromSettingsBundle];
    
    self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    
    self.window.rootViewController = self.webViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
   NSLog(@"My device token String is: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"apnsToken"]; //save token to resend it if request fails
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"apnsTokenSentSuccessfully"]; // set flag for request status
    
    [DataUpdater sendUserTokenWithURL:serverRegisterUrl]; //send token
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    //NSLog(@"Failed to get device token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //NSLog(@"User Info: %@",userInfo);
    
     //send badgeCount=0 to server;
    
    application.applicationIconBadgeNumber = 0;
    [DataUpdater sendBadgeCountResetWithURL:serverBadgeResetUrl];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //send badgeCount=0 to server;
    
    application.applicationIconBadgeNumber = 0;
    [DataUpdater sendBadgeCountResetWithURL:serverBadgeResetUrl];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma
#pragma mark-User Default Setup
    
- (void)registerDefaultsFromSettingsBundle
    {
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        [defs synchronize];
        
        NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
        
        if(!settingsBundle) {
            //NSLog(@"Could not find Settings.bundle");
            return;
        }
        
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
        NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
        
        for (NSDictionary *prefSpecification in preferences) {
            NSString *key = [prefSpecification objectForKey:@"Key"];
            if (key) {
                // check if value readable in userDefaults
                id currentObject = [defs objectForKey:key];
                if (currentObject == nil) {
                    // not readable: set value from Settings.bundle
                    id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                    [defaultsToRegister setObject:objectToSet forKey:key];
                    //NSLog(@"Setting object %@ for key %@", objectToSet, key);
                }
                else {
                    // already readable: don't touch
                    //NSLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key,currentObject);
                }
            }
        }
        
        [defs registerDefaults:defaultsToRegister];
        [defs synchronize];
    }


@end
