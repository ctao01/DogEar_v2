//
//  de_MainTabBarController.h
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface de_MainTabBarController : UITabBarController <UITabBarControllerDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate >

- (void) addCenterButtonWithFrame:(CGRect)frame;
- (void) activateCamera;

- (void) makeTabBarHidden:(BOOL)hide;


@end
