//
//  de_HeaderView.m
//  DogEar
//
//  Created by Joy Tao on 12/10/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_HeaderView.h"
#import "UIImage+DGStyle.h"
#import "de_DetailViewController.h"

@interface de_HeaderView()
{
    UIImageView * imageView;
    UITextField * txtField;
    UITextView * txtView;
    UILabel * label;
}

@end

@implementation de_HeaderView
@synthesize dogEar = _dogEar;
@synthesize thumbImage = _thumbImage;
@synthesize vcParent = _vcParent;

@synthesize allowEditing = _allowEditing;
@synthesize titleField = _titleField;
@synthesize notesField = _notesField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectOffset(imageView.frame, 15.0f, 20.0f);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.borderColor = [[UIColor whiteColor]CGColor];
        imageView.layer.borderWidth = 2.0f;
        imageView.layer.cornerRadius = 6.0f;
        imageView.layer.shadowOffset =CGSizeMake(5.0f, 3.0f);
        imageView.layer.shadowColor = [[UIColor blackColor]CGColor];
        
        txtField = [[UITextField alloc]initWithFrame:CGRectMake(120.0f, 25.0f, 180.0f, 30.0f)];
        txtField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        txtField.delegate = self;
        txtField.returnKeyType = UIReturnKeyNext;
        txtField.backgroundColor = [UIColor whiteColor];
        txtField.layer.borderColor = [[UIColor grayColor] CGColor];
        txtField.layer.borderWidth = 1.0f;
        txtField.layer.cornerRadius = 2.0f;
        txtField.clipsToBounds = YES;

        
        
        self.titleField = [[UITextField alloc]init];
        self.titleField = txtField;
        
        label = [[UILabel alloc]initWithFrame:txtField.frame];
        label.frame = CGRectOffset(label.frame, 0.0f, 55.0f);
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        label.textColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentRight;
        
        txtView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 120.0f, 295.0f, 60.0f)];
        txtView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        txtView.delegate = self;
        txtView.returnKeyType = UIReturnKeyDone;
        txtView.backgroundColor = [UIColor whiteColor];
        txtView.layer.borderColor = [[UIColor grayColor] CGColor];
        txtView.layer.borderWidth = 1.0f;
        txtView.layer.cornerRadius = 5.0f;
        txtView.clipsToBounds = YES;
        
        self.notesField = [[UITextView alloc]init];
        self.notesField = txtView;
        
        [self addSubview:imageView];
        [self addSubview:self.titleField];
        [self addSubview:self.notesField];
        [self addSubview:label];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (self.dogEar == nil)
    {
        [imageView setImage:[self.thumbImage scaleToFitSize:imageView.frame.size]];
        label.text = [NSString mediumStyleDateAndShortStyleTimeWithDate:[NSDate date]];
        self.titleField.placeholder = @"Title";
        self.titleField.text = @"";
       
        self.notesField.text = @"Note";
        self.notesField.textColor =[UIColor lightGrayColor];
    }
    else
    {
        NSData *pngData = [NSData dataWithContentsOfFile:self.dogEar.imagePath];
        [imageView setImage:[[UIImage imageWithData:pngData] scaleToFitSize:imageView.frame.size]];
        label.text = [NSString mediumStyleDateAndShortStyleTimeWithDate:self.dogEar.insertedDate];
        self.titleField.placeholder = @"";
        self.titleField.text = self.dogEar.title;
        
        self.notesField.text = self.dogEar.note;
        self.notesField.textColor =[UIColor blackColor];
    }
}

#pragma mark - UITextFieldDelegate Method
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
    [vc.dogEar setTitle:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtView becomeFirstResponder];
    return YES;
}


#pragma mark - UITextViewDelegate Method
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Note"]&& [textView.textColor isEqual:[UIColor lightGrayColor]])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    de_DetailViewController * vc = (de_DetailViewController*)self.vcParent;
    [vc.dogEar setNote:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
