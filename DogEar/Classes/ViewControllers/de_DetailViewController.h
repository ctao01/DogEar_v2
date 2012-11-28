//
//  de_DetailViewController.h
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DogEarObject.h"

typedef enum {
    DogEarActionViewing,
    DogEarActionEditing
} DogEarAction;

@interface de_DetailViewController : UITableViewController
@property (nonatomic) DogEarAction action;

@property (nonatomic , strong ) DogEarObject * dogEar; // JT-Note: new dog ear
@property (nonatomic , strong ) DogEarObject * existingDogEar;

- (id) initWithStyle:(UITableViewStyle)style andImage:(UIImage*)image;

@end
