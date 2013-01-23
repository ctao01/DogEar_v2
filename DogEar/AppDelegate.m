//
//  AppDelegate.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic , strong) UILocalNotification * localNotification;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.bkSplashScreenVC = [[de_DefaultViewController alloc]init];
    application.applicationIconBadgeNumber = 0;
    
    //JT-Note: Handle Local Notification
    UILocalNotification * notification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsLocalNotificationKey"];
    
    if (notification)
    {
        self.localNotification = notification;
        [application cancelLocalNotification:notification];
//        application.applicationIconBadgeNumber = 0;
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(showAlert:) userInfo:nil repeats:NO];
    }
    self.bkMainNav = [[UINavigationController alloc]initWithRootViewController:self.bkSplashScreenVC];
    self.window.rootViewController = self.bkMainNav;
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"DogEar_PostNotification"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DogEar_PostNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

- (void) showAlert:(NSTimer*) timer
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DogEar Reminder"
                                                    message:self.localNotification.alertBody
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Check it",nil];
    [alert show];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
#pragma mark - NSLocalNotification

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{    
    self.localNotification = notification;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DogEar Reminder"
                                                    message:notification.alertBody
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Check it",nil];
    [alert show];
    [application cancelLocalNotification:notification];

}

#pragma mark -

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self.bkSplashScreenVC showReminderWithLocalNotification:self.localNotification];
        
    }
}

@end
