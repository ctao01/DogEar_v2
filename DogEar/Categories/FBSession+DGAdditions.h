//
//  FBSession+DGAdditions.h
//  DogEar
//
//  Created by Joy Tao on 12/13/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

extern NSString *const DGFacebookSessionStateChangedNotification;

@interface FBSession (DGAdditions)

#pragma mark - Class Methods

+ (BOOL)openActiveSessionWithAllowLoginUI:(BOOL)allowLoginUI
								  success:(FBSessionStateHandler)success
								  failure:(FBSessionStateHandler)failure;

+ (BOOL)openActiveSessionWithPermissions:(NSArray*)permissions
                            allowLoginUI:(BOOL)allowLoginUI
								 success:(FBSessionStateHandler)success
								 failure:(FBSessionStateHandler)failure;

-(void) closeAndClearTokenInformationWithSeccess:(FBSessionStateHandler)success;


@end
 