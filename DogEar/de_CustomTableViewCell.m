//
//  de_CustomTableViewCell.m
//  DogEar
//
//  Created by Joy Tao on 12/4/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_CustomTableViewCell.h"

@implementation de_CustomTableViewCell
@synthesize deTitleLabel = _deTitleLabel;
@synthesize deSubtitleLabel = _deSubtitleLabel;
@synthesize dePhotoImageView = _dePhotoImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.deTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 170.0f, 30.0f)];
        self.deTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        self.deTitleLabel.textColor = [UIColor blackColor];
        
        self.deSubtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 30)];
        self.deSubtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.deSubtitleLabel.textColor = [UIColor darkGrayColor];
        
        self.dePhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        self.dePhotoImageView.layer.shadowColor = [[UIColor grayColor] CGColor];
        self.dePhotoImageView.layer.shadowRadius = 8.0f;
        self.dePhotoImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        
        [self addSubview:self.deTitleLabel];
        [self addSubview:self.deSubtitleLabel];
        [self addSubview:self.dePhotoImageView];
        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    
    self.dePhotoImageView.frame = CGRectOffset(self.dePhotoImageView.frame, 5.0f, 5.0f);
    
    self.deTitleLabel.frame = CGRectOffset(self.deTitleLabel.frame, 50.0f, 1.0f);
    self.deSubtitleLabel.frame = CGRectOffset(self.deSubtitleLabel.frame, 50.0f, (CGRectGetHeight(bounds)/2.0f) - (height(self.deSubtitleLabel)/2.0f));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
