//
//  FBSession+DGAdditions.m
//  DogEar
//
//  Created by Joy Tao on 12/13/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "FBSession+DGAdditions.h"
NSString *const DGFacebookSessionStateChangedNotification = @"bloomfieldknoble.inc.urbanzombie:UZFacebookSessionStateChangedNotification";

@interface FBSession (UZPrivate)

+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error success:(FBSessionStateHandler)success failure:(FBSessionStateHandler)failure;

@end


@implementation FBSession (UZAdditions)

#pragma mark - Class Methods

+ (BOOL)openActiveSessionWithAllowLoginUI:(BOOL)allowLoginUI
								  success:(FBSessionStateHandler)success
								  failure:(FBSessionStateHandler)failure
{
	NSArray *permissions = [NSArray arrayWithObjects:@"publish_actions", @"email", nil];
	
	return [FBSession openActiveSessionWithPermissions:permissions
										  allowLoginUI:allowLoginUI
									 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
										 [self sessionStateChanged:session state:state error:error success:success failure:failure];
									 }];
}

+ (BOOL)openActiveSessionWithPermissions:(NSArray*)permissions
                            allowLoginUI:(BOOL)allowLoginUI
								 success:(FBSessionStateHandler)success
								 failure:(FBSessionStateHandler)failure
{
	return [FBSession openActiveSessionWithPermissions:permissions
										  allowLoginUI:allowLoginUI
									 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
										 [self sessionStateChanged:session state:state error:error success:success failure:failure];

									 }];
}

-(void) closeAndClearTokenInformationWithSeccess:(FBSessionStateHandler)success
{
    __block id closeObserver;
	closeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:DGFacebookSessionStateChangedNotification
                                                                      object:self
                                                                       queue:nil
                                                                  usingBlock:^(NSNotification *note)
                     {
                         FBSession * session = (FBSession *)note.object;
                         if (session.state == FBSessionStateClosed && success) success(session, session.state, nil);
                         
                         [[NSNotificationCenter defaultCenter] removeObserver:closeObserver];
                         
                     }];
	
	[self closeAndClearTokenInformation];
}

@end

@implementation FBSession (UZPrivate)

+ (void)sessionStateChanged:(FBSession *)session
					  state:(FBSessionState)state
					  error:(NSError *)error
					success:(FBSessionStateHandler)success
					failure:(FBSessionStateHandler)failure
{
	switch (state) {
		case FBSessionStateCreated:
		case FBSessionStateCreatedTokenLoaded:
		case FBSessionStateCreatedOpening:
		case FBSessionStateOpen:
		case FBSessionStateOpenTokenExtended:
			if (success) success(session, state, error);
			break;
		case FBSessionStateClosed:
			[FBSession.activeSession closeAndClearTokenInformation];
			//TODO: Do we need to exec a block on success close?
			//if (success) success(session, state, error);
			break;
		case FBSessionStateClosedLoginFailed:
			[FBSession.activeSession closeAndClearTokenInformation];
			if (failure) failure(session, state, error);
			break;
		default:
			if (error && failure) failure(session, state, error);
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DGFacebookSessionStateChangedNotification object:session];
    
}

@end
