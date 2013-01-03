//
//  de_HeaderView.h
//  DogEar
//
//  Created by Joy Tao on 12/10/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface de_HeaderView : UIView < UITextFieldDelegate , UITextViewDelegate>

@property (nonatomic , strong) UIViewController * vcParent;

@property (nonatomic , assign) UIImage * thumbImage;
@property (nonatomic , strong) UITextField * titleField;
@property (nonatomic , strong) UITextView * notesField;

@property (nonatomic , strong) DogEarObject * dogEar;

@property (nonatomic ) BOOL allowEditing;

@end
