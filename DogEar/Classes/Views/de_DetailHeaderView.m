//
//  de_DetailHeaderView.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DetailHeaderView.h"
#import "de_DetailViewController.h"

@interface de_DetailHeaderView ()

@property (nonatomic , retain) UITableView * table;

-(UITextField*) makeTextField: (NSString*)text placeholder: (NSString*)placeholder tag:(NSInteger)tag;

@end

@implementation de_DetailHeaderView
@synthesize vcParent = _vcParent;
@synthesize allowEditing = _allowEditing;

@synthesize table = _table;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = CGRectOffset(imageView.frame, 10.0f, 5.0f);
        [self addSubview:imageView];
        
        self.table = [[UITableView alloc]initWithFrame:CGRectMake(110.0f, 5.0f, 209.0f, 100.0f) style:UITableViewStyleGrouped];
        self.table.dataSource = self;
        self.table.delegate = self;
        self.table.backgroundColor = [UIColor clearColor];
        self.table.scrollEnabled = NO;
        
        [self addSubview:self.table];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
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
    if (!self.allowEditing)
    {
        [tf setEnabled:NO];
        tf.userInteractionEnabled = NO;
    }
    else
    {
        [tf setEnabled:YES];
        [tf setUserInteractionEnabled:YES];
    }
    
    
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
    
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Title";
        cell.tag = 1111;
        textField = [self makeTextField:@"" placeholder:@"Title" tag:1001];
        textField.returnKeyType = UIReturnKeyNext;
        [cell addSubview:textField];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Notes";
        cell.tag = 2222;
        textField = [self makeTextField:@"" placeholder:@"Notes" tag:1002];
        textField.returnKeyType = UIReturnKeyDone;
        [cell addSubview:textField];
    }
    
    textField.frame = CGRectMake(80.0f, 0.0f, 120.0f, 30);
    textField.center = CGPointMake(textField.center.x, 25.0f);
    textField.delegate = self;
    
    return cell;
}

#pragma mark - UITableView Delegate Method

#pragma mark - UITextField Delegate Method

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    de_DetailViewController * vc = (de_DetailViewController*)self.vcParent;
    
    if ([textField.placeholder isEqualToString:@"Title"])
        [vc.dogear setTitle:textField.text];
    
    else if ([textField.placeholder isEqualToString:@"Notes"])
        [vc.dogear setNote:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    
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
