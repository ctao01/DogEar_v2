//
//  de_DetailViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DetailViewController.h"
#import "de_DetailHeaderView.h"

#import "de_CategoryListViewController.h"
#import "de_ReminderViewController.h"
#import "de_FlagViewController.h"

@interface de_DetailViewController ()
@property (nonatomic) BOOL isEditing; 
@property (nonatomic ,retain) UIImage * image;

@end

@implementation de_DetailViewController
@synthesize action = _action;
@synthesize isEditing = _isEditing;
@synthesize image = _image;

@synthesize dogEar = _dogEar;
@synthesize existingDogEar = _existingDogEar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}
- (id) initWithStyle:(UITableViewStyle)style andImage:(UIImage*)image
{
    self = [self initWithStyle:style];
    if (self)
        self.image = image;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-master"]];
    self.tableView.backgroundView = bgImage;
        
    CGRect bounds = [[UIScreen mainScreen]bounds];
    de_DetailHeaderView * headerView = [[de_DetailHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, 110.0f)];
    headerView.center = CGPointMake(self.view.center.x, headerView.center.y);
    headerView.vcParent = self;
    if (self.existingDogEar == nil)
    {
        headerView.dogEar = nil;
        headerView.thumbImage = self.image;
    }
    else headerView.dogEar = self.existingDogEar;
    
//    if (self.action == DogEarActionEditing) headerView.allowEditing = YES;
//    else if (self.action == DogEarActionViewing) headerView.allowEditing = NO;
    
    self.tableView.tableHeaderView = headerView;
    self.dogEar = nil;
    
    if(!self.existingDogEar) self.dogEar = [DogEarObject new];
    else self.dogEar = self.existingDogEar;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.action == DogEarActionEditing)
    {
        NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:path];
        
        if (![cell.detailTextLabel.text isEqualToString:@""])
        {
            UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDogEar)];
            self.navigationItem.rightBarButtonItem = saveItem;
        }
        else
            self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.isEditing = NO;
        
        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = editItem;
        
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) edit:(id)sender
{
    NSString * keyString = self.dogEar.category;
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:keyString];
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
    
    if (self.isEditing)
    {
        self.tableView.userInteractionEnabled = NO;
        //JT-TODO: Done Feature
        [decodedCollections addObject:self.dogEar];

        
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.isEditing = NO;
        
    }
    else
    {
        //JT:TODO - remove dogEar from Array
        [decodedCollections removeObject:self.existingDogEar];
        
        self.tableView.userInteractionEnabled = YES;
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        self.isEditing = YES; 
    }
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:decodedCollections];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    [dict setObject:encodedObjects forKey:keyString];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark -

- (void) saveDogEar
{
    [self.dogEar setInsertedDate:[NSDate date]];

    
    [self.dogEar setImagePath:[NSString imagePathWithFileName:[self.dogEar.title stringByAppendingFormat:@"%@",[NSString generateRandomString]]]];
    [self.dogEar setImageOrientation: [NSNumber numberWithInteger:[self.image imageOrientation]]];

    
    // setNotification
    if (self.dogEar.reminderDate)
    {
        UILocalNotification * reminder = [[UILocalNotification alloc]init];
        if (reminder == nil) return;
        reminder.fireDate = self.dogEar.reminderDate;
        reminder.timeZone = [NSTimeZone defaultTimeZone];
        
        reminder.alertBody = [NSString stringWithFormat:@"%@",self.dogEar.title? self.dogEar.title: @"DogEar"];//JT-TODO: alertBody
        reminder.alertLaunchImage = self.dogEar.imagePath;    
        reminder.alertAction = @"View";
        reminder.soundName = UILocalNotificationDefaultSoundName;
        reminder.applicationIconBadgeNumber = 1;
        
        NSDictionary * userDict = [NSDictionary dictionaryWithObject:
                                  [NSString reminderStyleWithDate:self.dogEar.reminderDate] forKey:@"DogEarReminderNotificationDataKey"];
        reminder.userInfo = userDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
    }
}

- (void) addDogEar
{
    [self saveDogEar];
    NSData *pngData = UIImagePNGRepresentation(self.image);
    [pngData writeToFile:self.dogEar.imagePath atomically:YES];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString * key = cell.detailTextLabel.text;
    
    NSDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    NSMutableArray * selectedObjects = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[dict objectForKey:key]]];
    [selectedObjects addObject:self.dogEar];
    
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:selectedObjects];
    [dict setValue:encodedObjects forKey:key];
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    if (self.tabBarController.selectedIndex == 0)[self.navigationController popToRootViewControllerAnimated:YES];
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.tabBarController setSelectedIndex:0];
        UINavigationController * nc = [self.tabBarController.viewControllers objectAtIndex:0];
        [nc popToRootViewControllerAnimated:YES];
    }
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: NSDictionary
    
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Category";
            cell.detailTextLabel.text = self.dogEar.category ? self.dogEar.category : @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Reminder";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case 2:
            cell.textLabel.text = @"Flagged";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case 3:
            cell.textLabel.text = @"Print";
            break;
            
        default:
            break;
    }

    
    return cell;
}

#pragma mark - UITableView Delegate Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        de_CategoryListViewController * tv = [[de_CategoryListViewController alloc]initWithStyle:UITableViewStylePlain];
        tv.categoryString = cell.detailTextLabel.text;
        [self.navigationController pushViewController:tv animated:YES];
        
    }
    else if (indexPath.row == 1)
    {
        de_ReminderViewController * vc = [[de_ReminderViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc.selectedDate = self.dogEar && self.dogEar.reminderDate ? self.dogEar.reminderDate:nil;
        vc.repeatedTimes = self.dogEar && self.dogEar.repeatingReminder ? [self.dogEar.repeatingReminder integerValue]:0;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2)
    {
        de_FlagViewController * vc = [[de_FlagViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc.selectedRow = self.dogEar && self.dogEar.flagged ? self.dogEar.flagged : nil;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
