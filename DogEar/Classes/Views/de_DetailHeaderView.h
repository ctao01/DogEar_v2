//
//  de_DetailHeaderView.h
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface de_DetailHeaderView : UIView <UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate >

@property (nonatomic , retain) UIViewController * vcParent;
@property ( nonatomic ) BOOL allowEditing;

@end
