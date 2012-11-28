//
//  de_DetailHeaderView.h
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DogEarObject.h"

@interface de_DetailHeaderView : UIView <UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate >

@property (nonatomic , strong) UIViewController * vcParent;
//@property (nonatomic ) BOOL allowEditing;

@property (nonatomic , assign) UIImage * thumbImage;
@property (nonatomic , strong) DogEarObject * dogEar;


@end
