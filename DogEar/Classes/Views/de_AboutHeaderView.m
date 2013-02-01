//
//  de_AboutHeaderView.m
//  DogEar
//
//  Created by Joy Tao on 2/1/13.
//  Copyright (c) 2013 Joy Tao. All rights reserved.
//

#import "de_AboutHeaderView.h"
#define DEVICE_OS [[[UIDevice currentDevice] systemVersion] intValue]

@implementation de_AboutHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage * logoImg = [UIImage imageNamed:@"DogEarLogo_About"];
        UIImageView * imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 180.0f, 180.0f)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = logoImg;
        imgView.center = CGPointMake(self.center.x, imgView.center.y);
        
        [self addSubview:imgView];
        
        UILabel * aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 170.0f, frame.size.width, 60.0f)];
        aboutLabel.lineBreakMode = UILineBreakModeWordWrap;
        aboutLabel.numberOfLines = 0;
        if (DEVICE_OS >=6.0)
            aboutLabel.textAlignment = NSTextAlignmentCenter;
        else
            aboutLabel.textAlignment = NSTextAlignmentCenter;
        
        aboutLabel.backgroundColor = [UIColor clearColor];
        
        NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        aboutLabel.text = [NSString stringWithFormat:@"version %@\n © bloomfield knoble, inc.\n 2013 All Rights Reserved.",version];
        aboutLabel.center = CGPointMake(self.center.x, aboutLabel.center.y);
        [self addSubview:aboutLabel];
        
        
    }
    return self;
}

@end
