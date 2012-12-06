//
//  de_CropView.m
//  DogEar
//
//  Created by Joy Tao on 12/6/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_CropView.h"
@interface de_CropView ()

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *rectColor;
@end

@implementation de_CropView
@synthesize strokeColor, rectColor;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.strokeColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.rectColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(ctx, self.rectColor.CGColor);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, rect.origin.x, rect.origin.y);  // top left
    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y);  // top right
    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);  // bottom right
    CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height);  // bottom left
    CGContextClosePath(ctx);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);

}

@end
