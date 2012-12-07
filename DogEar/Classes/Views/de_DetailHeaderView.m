//
//  de_DetailHeaderView.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DetailHeaderView.h"
#import "de_DetailViewController.h"
#import "UIImage+DGStyle.h"

@interface de_DetailHeaderView ()
{
    UIImageView * imageView;
}
@property (nonatomic , retain) UITableView * table;

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder tag:(NSInteger)tag;

@end

@implementation de_DetailHeaderView

@synthesize vcParent = _vcParent;
@synthesize allowEditing = _allowEditing;
@synthesize thumbImage = _thumbImage;
@synthesize dogEar = _dogEar;

@synthesize table = _table;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 95.0f, 95.0f)];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectOffset(imageView.frame, 15.0f, 10.0f);
        [self addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        self.table = [[UITableView alloc]initWithFrame:CGRectMake(110.0f, 5.0f, 209.0f, 100.0f) style:UITableViewStyleGrouped];
        self.table.dataSource = self;
        self.table.delegate = self;
//        self.table.backgroundColor = [UIColor clearColor];
        [self.table setBackgroundView:nil];
        UIView * clearBG = [[UIView alloc]initWithFrame:CGRectZero];
        clearBG.backgroundColor = [UIColor clearColor];
        [self.table setBackgroundView:clearBG];
        
        self.table.scrollEnabled = NO;
        
        [self addSubview:self.table];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if (self.dogEar == nil)[imageView setImage:[self.thumbImage scaleToFitSize:imageView.frame.size]];
    else
    {
        NSData *pngData = [NSData dataWithContentsOfFile:self.dogEar.imagePath];
        [imageView setImage:[[UIImage imageWithData:pngData] scaleToFitSize:imageView.frame.size]];
    }
//    imageView.image = self.thumbImage;
}

- (void) setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.table reloadData];
}

#pragma mark - 

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder tag:(NSInteger)tag
{
    UITextField *tf = [[UITextField alloc] init];
	tf.placeholder = placeholder ;
	tf.text = text ;
    tf.tag = tag;
	tf.autocorrectionType = UITextAutocorrectionTypeNo ;
	tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tf.adjustsFontSizeToFitWidth = YES;
	tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    tf.delegate = self;

//    if (self.dogEar != nil)
//        [tf setEnabled:NO];
//    else
//        [tf setEnabled:YES];
    
    
	return tf ;
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITextField * textField = nil;
    NSLog(@"reload");
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Title";
        cell.tag = 1111;
//        if (textField) [textField removeFromSuperview];
        UITextField * tf1 = (UITextField*)[cell viewWithTag:1001];
        if (tf1) [tf1 removeFromSuperview];
        
        textField = [self makeTextField:self.dogEar?self.dogEar.title:@""
                            placeholder:self.dogEar?@"":@"Title"
                                    tag:1001];
        textField.returnKeyType = UIReturnKeyNext;
        [cell addSubview:textField];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Notes";
        cell.tag = 2222;
        UITextField * tf2 = (UITextField*)[cell viewWithTag:1002];
        if (tf2) [tf2 removeFromSuperview];
        
        textField = [self makeTextField:self.dogEar?self.dogEar.note:@""
                            placeholder:self.dogEar?@"":@"Notes"
                                    tag:1002];
        textField.returnKeyType = UIReturnKeyDone;
        [cell addSubview:textField];
    }
    if (self.allowEditing) [textField setEnabled:YES];
    else [textField setEnabled:NO];
    
    textField.frame = CGRectMake(80.0f, 0.0f, 120.0f, 30);
    textField.center = CGPointMake(textField.center.x, 25.0f);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableView Delegate Method

#pragma mark - UITextField Delegate Method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    de_DetailViewController * vc = (de_DetailViewController*)self.vcParent;
    
    if (!self.dogEar){
        if ([textField.placeholder isEqualToString:@"Title"])
            [vc.dogEar setTitle:textField.text];
        else if ([textField.placeholder isEqualToString:@"Notes"])
            [vc.dogEar setNote:textField.text];
    }
    else{
        if (textField.tag == 1001)
            [vc.dogEar setTitle:textField.text];

        else if (textField.tag = 1002)
            [vc.dogEar setNote:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSInteger nextTag = textField.tag + 1;
    
    NSIndexPath * notesIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell * cell = [self.table cellForRowAtIndexPath:notesIndexPath];
    UIResponder * nextResponder = [cell viewWithTag:nextTag];
    if (nextResponder)
        [nextResponder becomeFirstResponder];
    
    else
        [textField resignFirstResponder];
    
    
    return YES;
}

@end
