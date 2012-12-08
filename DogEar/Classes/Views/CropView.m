//
//  CropView.m
//  PhotoEditingTesting
//
//  Created by Joy Tao on 12/6/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "CropView.h"

@interface CropView ()

@property (nonatomic , strong) UIColor * rectColor;
@property (nonatomic , strong) UIColor * strokeColor;
@end

@implementation CropView
@synthesize cropFrame, strokeColor, rectColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
//    if (self) {
//        
//        self.backgroundColor = [UIColor clearColor];
//        self.opaque = NO;
//        self.rectColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
//        self.strokeColor = [UIColor blackColor];
//        
//    }
    return self;
}
- (id) initWithOuterFrame:(CGRect)outerFrame andInnerFrame:(CGRect)innerFrame
{
    self = [super initWithFrame:outerFrame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.rectColor = [UIColor colorWithWhite:0.0f alpha:0.75];
        self.strokeColor = [UIColor blackColor];
        self.cropFrame = innerFrame;
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, 2.5f);
//    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
//    CGContextSetFillColorWithColor(context, self.rectColor.CGColor);
//    
//    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
//    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
//    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
//    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
//    CGContextClosePath(context);
//    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGRect outerRect = self.frame;
    CGRect innerRect  = self.cropFrame;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:outerRect cornerRadius:0.0f];
    
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:0.0f]];
    path.usesEvenOddFillRule = YES;
    
    [self.rectColor set];
    [path fill];
}


@end
