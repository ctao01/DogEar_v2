//
//  de_CustomTableViewCell.h
//  DogEar
//
//  Created by Joy Tao on 12/4/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface de_CustomTableViewCell : UITableViewCell
@property (nonatomic , strong) UILabel * deTitleLabel;
@property (nonatomic , strong) UILabel * deSubtitleLabel;

@property (nonatomic , strong) UIImageView * dePhotoImageView;

@end
