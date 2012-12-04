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
        self.deTitleLabel.frame = CGRectOffset(self.deTitleLabel.frame, 53.0f, 1.0f);

        self.deSubtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 30)];
        self.deSubtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.deSubtitleLabel.textColor = [UIColor darkGrayColor];
        self.deSubtitleLabel.frame = CGRectOffset(self.deSubtitleLabel.frame, 54.0f, 27.0f);

        
        self.dePhotoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
        self.dePhotoImageView.layer.shadowColor = [[UIColor grayColor] CGColor];
        self.dePhotoImageView.layer.shadowRadius = 8.0f;
        self.dePhotoImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.dePhotoImageView.frame = CGRectOffset(self.dePhotoImageView.frame, 5.0f, 5.0f);
        self.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.deTitleLabel];
        [self addSubview:self.deSubtitleLabel];
        [self addSubview:self.dePhotoImageView];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
