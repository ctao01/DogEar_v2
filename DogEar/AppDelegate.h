//
//  AppDelegate.h
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "de_DefaultViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate , UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong , nonatomic) de_DefaultViewController * bkSplashScreenVC;
@property (strong , nonatomic) UINavigationController * bkMainNav;
@end
