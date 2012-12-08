//
//  UIImage+DGStyle.h
//  DogEar
//
//  Created by Joy Tao on 12/4/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>


@interface UIImage (DGStyle)

+ (UIImage *)rotateImage:(UIImage *)aImage;

// Image Enhance

-(UIImage*)autoEnhance;
-(UIImage*)redEyeCorrection;

// Image Resize

-(UIImage*)cropToSize:(CGSize)newSize;
-(UIImage*)scaleByFactor:(float)scaleFactor;
-(UIImage*)scaleToFitSize:(CGSize)newSize;
-(UIImage*) getSubImage:(CGRect)rect fromImage:(CGRect)originRect;
-(UIImage*) getSubImage:(CGRect)rect;

@end
