//
//  UIImage+DGStyle.h
//  DogEar
//
//  Created by Joy Tao on 12/4/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DGStyle)

+ (UIImage *)rotateImage:(UIImage *)aImage;
+ (UIImage *) resizedImage:(UIImage*)image inRect:(CGRect)thumbRect;

@end
