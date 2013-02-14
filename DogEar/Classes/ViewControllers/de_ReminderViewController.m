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
    BOOL isExpandedTable;
    
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
        isExpandedTable = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-content-master"]];
    self.tableView.backgroundView = bgImage;
    

    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    picker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0.0f, bounds.size.height - 250.0f -44.0f, bounds.size.width, 250.0f +44.0f)];
    picker.datePickerMode = UIDatePickerModeDateAndTime;
    
    NSDate * oneHourAheadDate = [[NSDate date] dateByAddingTimeInterval:60 * 60];
    picker.date = oneHourAheadDate;
    [picker addTarget:self
               action:@selector(changeDateReminder:)
     forControlEvents:UIControlEventValueChanged];
    [picker setBackgroundColor:[UIColor clearColor]];
    picker.hidden = YES;
    [self.view addSubview:picker];
    
    self.notifArray = [[NSArray alloc]initWithObjects:@"Never", @"Every Hour",@"Every Day",@"Every Week",@"Every Month",@"Every Year", nil];
        
    UIBarButtonItem * doneItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addReminder:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissTheView)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.title = @"Set A Reminder";
    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    de_DetailViewController * vc = (de_DetailViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    if (vc.dogEar.reminderDate != NULL || isExpandedTable == YES) isExpandedTable = YES;
    else isExpandedTable = NO;
    NSLog(@"isExpandedTable:%@",isExpandedTable? @"YES":@"NO");
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) switchTurnOnOff:(id)sender
{
    UISwitch * toggle = (UISwitch*)sender;
    
    if (toggle.on)
    {
        isExpandedTable = YES;
        [toggle setOn:NO animated:YES];
    }
    else
    {
        isExpandedTable = NO;
        [toggle setOn:YES animated:YES];
        picker.hidden = YES;

    }
    NSLog(@"%@",isExpandedTable ? @"YES" : @"NO");
    
    [self.tableView reloadData];
}

- (void) cancelExistingNotificationWithObject:(DogEarObject*)object
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
   for (UILocalNotification *notification in localNotifications)
   {
       NSDictionary * dict = notification.userInfo;
       if (dict)
       {
           NSDate * insertedDate = [dict objectForKey:@"DogEarObjectInsertedDate"];
           if ([insertedDate isEqualToDate:object.insertedDate])
               [[UIApplication sharedApplication] cancelLocalNotification:notification];
       }
   }
}

- (void)changeDateReminder:(id)sender
{
//    UIDatePicker * datePicker = (UIDatePicker*)sender;
//    self.selectedDate = datePicker.date;
    [self.tableView reloadData];
}

- (void) dismissTheView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addReminder:(id)sender
{
    de_DetailViewController * vc = (de_DetailViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    if (isExpandedTable == YES)
    {
        [self cancelExistingNotificationWithObject:vc.dogEar];
        
        [vc.dogEar setReminderDate:picker.date];
        [vc.dogEar setRepeatingReminder:[NSNumber numberWithInteger:self.repeatedTimes]];
        
        if ((picker.date != NULL) && ([NSNumber numberWithInteger:self.repeatedTimes]!= NULL))
        {
            UILocalNotification * reminder = [[UILocalNotification alloc]init];
            if (reminder == nil) return;
            reminder.fireDate = vc.dogEar.reminderDate;
            reminder.timeZone = [NSTimeZone defaultTimeZone];
            
            reminder.alertBody = [NSString stringWithFormat:@"%@: %@",vc.dogEar.category, vc.dogEar.title];
            reminder.hasAction = TRUE;
            reminder.alertAction = @"Check it";
            reminder.soundName = UILocalNotificationDefaultSoundName;   //JT-TODO: Select Notification sound
            reminder.applicationIconBadgeNumber = 1;
            
            //JT-Note: Repeating Notification
            NSInteger repeatingType = self.repeatedTimes;
            if (repeatingType == 0 ) reminder.repeatInterval = 0;
            else if (repeatingType == 1) reminder.repeatInterval = NSHourCalendarUnit;
            else if (repeatingType == 2) reminder.repeatInterval = NSDayCalendarUnit;
            else if (repeatingType == 3) reminder.repeatInterval = NSWeekCalendarUnit;
            else if (repeatingType == 4) reminder.repeatInterval = NSMonthCalendarUnit;
            else if (repeatingType == 5) reminder.repeatInterval = NSYearCalendarUnit;
            
            NSDictionary * userDict = [NSDictionary dictionaryWithObject:
                                       [vc.dogEar insertedDate] forKey:@"DogEarObjectInsertedDate"];
            reminder.userInfo = userDict;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
        }

    }
    else
    {
        [vc.dogEar setReminderDate:NULL];
        [vc.dogEar setRepeatingReminder:NULL];
    }
    
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
    if (isExpandedTable == NO) return 1;
    else return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//
    if (indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Remind Me On A Day";
    
        UISwitch * reminderSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 44.0f)];
        [reminderSwitch addTarget:self action:@selector(switchTurnOnOff:) forControlEvents:UIControlEventValueChanged];
        reminderSwitch.on = isExpandedTable;
        cell.accessoryView = reminderSwitch;
    }
    
    else if (indexPath.row == 1)
            cell.textLabel.text = (self.selectedDate != nil)? [NSString reminderStyleWithDate:self.selectedDate]:[NSString reminderStyleWithDate:[[NSDate date] dateByAddingTimeInterval:60 * 60]] ;
    else if (indexPath.row == 2)
    {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Repeat";
            cell.detailTextLabel.text = [self.notifArray objectAtIndex:self.repeatedTimes];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
        {
            picker.hidden = NO;
        }
            break;
        case 2:
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
