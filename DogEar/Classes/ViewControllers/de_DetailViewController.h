//
//  de_DetailViewController.h
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DogEarObject.h"

@class UIPrintInteractionController;
@interface de_DetailViewController : UITableViewController < UIAlertViewDelegate >

@property (nonatomic , strong ) DogEarObject * dogEar; // JT-Note: new dog ear
@property (nonatomic , strong ) DogEarObject * existingDogEar;

- (id) initWithStyle:(UITableViewStyle)style andImage:(UIImage*)image;

@end
