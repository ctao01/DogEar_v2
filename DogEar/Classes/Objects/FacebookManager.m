//
//  FacebookManager.m
//  DogEar
//
//  Created by Joy Tao on 1/9/13.
//  Copyright (c) 2013 Joy Tao. All rights reserved.
//

#import "FacebookManager.h"

static FacebookManager * sharedManager = nil;

@implementation FacebookManager

+ (id) sharedManager
{
    @synchronized(self){
        if (sharedManager == nil)
            sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (void) connectToFacebookAccount
{
    ACAccountStore * accountStore = [[ACAccountStore alloc]init];
    ACAccountType * facebookType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:facebookType
                                          options:nil
                                       completion:^(BOOL granted, NSError * error)
     {
         NSString * message;
         if (granted)
         {
             if (!error)
             {
                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Facebook_Account"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 message = @"DogEar successfully connected to your Facebook account.";
                 
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Facebook_Account"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
             }
         }
         else
         {
             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Facebook_Account"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
         }
     }];
    
}


@end
