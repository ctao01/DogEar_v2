//
//  CropView.h
//  PhotoEditingTesting
//
//  Created by Joy Tao on 12/6/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropView : UIView

- (id) initWithOuterFrame:(CGRect)outerFrame andInnerFrame:(CGRect)innerFrame;
@property (nonatomic) CGRect cropFrame;

@end
