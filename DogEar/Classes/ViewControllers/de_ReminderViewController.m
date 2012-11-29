//
//  de_ReminderViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/28/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_ReminderViewController.h"

#import "de_RepeatingLNViewController.h"
#import "de_DetailViewController.h"

@interface de_ReminderViewController ()
{
    UIDatePicker * picker;
}
@property (nonatomic , retain) NSArray * notifArray;
@end

@implementation de_ReminderViewController

@synthesize selectedDate = _selectedDate;
@synthesize repeatedTimes;

@synthesize notifArray = _notifArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.scrollEnabled = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-master"]];
    self.tableView.backgroundView = bgImage;
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    picker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0.0f, 250.0f, bounds.size.width, bounds.size.height - 250.0f + 44.0f)];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    picker.date = [NSDate date];
    picker.hidden = YES;
    [picker addTarget:self
               action:@selector(changeDateReminder:)
     forControlEvents:UIControlEventValueChanged];
    [picker setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:picker];
    
    self.notifArray = [[NSArray alloc]initWithObjects:@"Never", @"Every Hour",@"Every Day",@"Every Week",@"Every Month",@"Every Year", nil];
        
    UIBarButtonItem * doneItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addReminder:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissTheView)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.title = @"Reminder";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    picker.hidden = NO;
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    picker.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)changeDateReminder:(id)sender
{
    UIDatePicker * datePicker = (UIDatePicker*)sender;
    self.selectedDate = datePicker.date;
    [self.tableView reloadData];
}

- (void) dismissTheView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addReminder:(id)sender
{
    de_DetailViewController * vc = (de_DetailViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    [vc.dogEar setReminderDate:self.selectedDate];
    [vc.dogEar setRepeatingReminder:[NSNumber numberWithInteger:self.repeatedTimes]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = (self.selectedDate != nil)? [NSString reminderStyleWithDate:self.selectedDate]:[NSString reminderStyleWithDate:[NSDate date]] ;
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    else if (indexPath.row == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Repeat";
        cell.detailTextLabel.text = [self.notifArray objectAtIndex:self.repeatedTimes];
    }
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            de_RepeatingLNViewController * vc = [[de_RepeatingLNViewController alloc]initWithStyle:UITableViewStyleGrouped];
            vc.checkedIndexPath = [NSIndexPath indexPathForRow:self.repeatedTimes inSection:0];
            vc.array = [[NSArray alloc]initWithArray:self.notifArray];
            [self.navigationController pushViewController:vc animated:YES];

        }
            
            break;
        default:
            break;
    }
    
}

@end