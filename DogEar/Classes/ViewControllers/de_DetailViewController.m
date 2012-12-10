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

#define kPDFPageBounds CGRectMake(0, 0, 8.5 * 72, 11 * 72)


@interface de_DetailViewController ()
{
    UIPrintInteractionController *printController;
    UIActivityIndicatorView * activityIndicator;
}

@property (nonatomic) BOOL isEditing;
@property (nonatomic ,retain) UIImage * image;

- (NSData *)generatePDFDataForPrinting;

- (void) setTableViewUserInteractionEnable:(BOOL)enable;
- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)collections;
- (void) handleImageWith:(DogEarObject*)object;

- (NSMutableArray*) decodedCollections;
- (NSString *) keyString;

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
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    
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
    
    self.tableView.tableHeaderView = headerView;
    
    //JT-Note:
    Class printControllerClass = NSClassFromString(@"UIPrintInteractionController");
    if (printControllerClass) {
        printController = [printControllerClass sharedPrintController];
    }
    
    if (self.existingDogEar != nil)
    {
        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = editItem;
        
        UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
        self.navigationItem.leftBarButtonItem = backItem;
        
        //        self.tableView.userInteractionEnabled = NO;
        for (int c = 0; c < [self.tableView numberOfRowsInSection:0] - 1; c++) {
            NSIndexPath * disabledIndexPath = [NSIndexPath indexPathForRow:c inSection:0];
            UITableViewCell * disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
            [disabledCell setUserInteractionEnabled:NO];
        }
    }
    NSLog(@"existingDogEar:%@",(self.existingDogEar != nil) ? @"YES":@"NO");
    NSLog(@"existingDogEarTitle:%@",self.existingDogEar.title);

    if(self.existingDogEar == nil )
    {   self.dogEar = [DogEarObject new];
        [self.dogEar setInsertedDate:[NSDate date]]; 
    }
    else self.dogEar = self.existingDogEar;

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    if (self.existingDogEar == nil)
    {
        if (![[self keyString] isEqualToString:@""])
        {
            UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDogEar)];
            self.navigationItem.rightBarButtonItem = saveItem;
        }
        else
            self.navigationItem.rightBarButtonItem = nil;
    }

}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) edit:(id)sender
{
    if (self.isEditing)
    {
        if (self.dogEar.category == nil)    //JT - Comment: Necessary to select Category
        {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Notice" message:@"Please select a category" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        else
        {
            [self setTableViewUserInteractionEnable:NO];
            
            [self saveDogEar];  // update self.dogear

            NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
            
            [array addObject:self.dogEar];
            [self updateDogEarDataCollectionWithSelectedCollections:array];

            [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
            [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
            
            [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
            [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
            [self.navigationItem.leftBarButtonItem setAction:@selector(backToHome)];
            
    //        self.navigationItem.leftBarButtonItem = nil;

            self.isEditing = NO;
        }
    }
    else
    {
        self.isEditing = YES;
        [self setTableViewUserInteractionEnable:YES];
        
        NSMutableArray * temp = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
        
        for (int d = 0; d < [temp count]; d++)
        {
            DogEarObject * object = [temp objectAtIndex:d];
            if ([object.title isEqualToString:self.existingDogEar.title] && [object.insertedDate isEqualToDate:self.existingDogEar.insertedDate])
                [temp removeObject:object];
        }

        [self updateDogEarDataCollectionWithSelectedCollections:temp];
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        [self.navigationItem.leftBarButtonItem setAction:@selector(cancelEditing)];
        

    }
}

- (void) backToHome
{
    if (self.tabBarController.selectedIndex == 0)[self.navigationController popToRootViewControllerAnimated:YES];
    else {
        [self.tabBarController setSelectedIndex:0];
        UINavigationController * nc = [self.tabBarController.viewControllers objectAtIndex:0];
        [nc popToRootViewControllerAnimated:YES];
    }
}

- (void) cancelEditing
{
    [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    
    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
    [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backToHome)];
    
    [self setTableViewUserInteractionEnable:NO];
    self.isEditing = NO;
    
    NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
    [array addObject:self.existingDogEar];
    [self updateDogEarDataCollectionWithSelectedCollections:array];

}

#pragma mark - Private Method

- (void) setTableViewUserInteractionEnable:(BOOL)enable
{
    for (int c = 0; c < [self.tableView numberOfRowsInSection:0] - 1; c++) {
        NSIndexPath * disabledIndexPath = [NSIndexPath indexPathForRow:c inSection:0];
        UITableViewCell * disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
        [disabledCell setUserInteractionEnabled:enable];
    }
}

- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)collections
{
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:collections];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    [dict setObject:encodedObjects forKey:[self keyString]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"updateDogEarDataCollectionWithSelectedCollections");
}

- (void) handleImageWith:(DogEarObject*)object
{
    [object setImagePath:[NSString imagePathWithFileName:[object.title stringByAppendingFormat:@"%@",[NSString generateRandomString]]]];
    [object setImageOrientation: [NSNumber numberWithInteger:[self.image imageOrientation]]];
    //JT-Note: Save Image to Device
    NSData *pngData = UIImagePNGRepresentation(self.image);
    [pngData writeToFile:object.imagePath atomically:YES];
}

#pragma mark - Private Getter / Setter

- (NSMutableArray*) decodedCollections 
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString * keyString = cell.detailTextLabel.text;
    
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:keyString];
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        
    return decodedCollections;
}

- (NSString *) keyString    //JT- TODO: keyString v.s. self.dog.ear category
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString * keyString = cell.detailTextLabel.text;
    return keyString;
}



#pragma mark - DogEar Method

- (void) saveDogEar
{
    //JT
    
    if (self.existingDogEar != nil)
        [self handleImageWith:self.existingDogEar];
    else [self handleImageWith:self.dogEar];
    
    /*[self.dogEar setImagePath:[NSString imagePathWithFileName:[self.dogEar.title stringByAppendingFormat:@"%@",[NSString generateRandomString]]]];
    [self.dogEar setImageOrientation: [NSNumber numberWithInteger:[self.image imageOrientation]]];
    //JT-Note: Save Image to Device
    NSData *pngData = UIImagePNGRepresentation(self.image);
    [pngData writeToFile:self.dogEar.imagePath atomically:YES];*/
    
    
    //JT-Note: Set Notification
    if ((self.dogEar.reminderDate != NULL) && (self.dogEar.repeatingReminder!= NULL))
    {
        UILocalNotification * reminder = [[UILocalNotification alloc]init];
        if (reminder == nil) return;
        reminder.fireDate = self.dogEar.reminderDate;
        reminder.timeZone = [NSTimeZone defaultTimeZone];
        
        reminder.alertBody = [NSString stringWithFormat:@"%@,%@",[self keyString],self.dogEar.title? self.dogEar.title: @"DogEar"];
        reminder.alertAction = @"Check it";
        reminder.soundName = UILocalNotificationDefaultSoundName;   //JT-TODO: Select Notification sound
        reminder.applicationIconBadgeNumber = 1;
        
        //JT-Note: Repeating Notification
        NSInteger repeatingType = [self.dogEar.repeatingReminder integerValue];
        if (repeatingType == 1) reminder.repeatInterval = NSHourCalendarUnit;
        else if (repeatingType == 2) reminder.repeatInterval = NSDayCalendarUnit;
        else if (repeatingType == 3) reminder.repeatInterval = NSWeekCalendarUnit;
        else if (repeatingType == 4) reminder.repeatInterval = NSMonthCalendarUnit;
        else if (repeatingType == 5) reminder.repeatInterval = NSYearCalendarUnit;
        
        NSDictionary * userDict = [NSDictionary dictionaryWithObject:
                                  [self.dogEar insertedDate] forKey:@"DogEarObjectInsertedDate"];
        reminder.userInfo = userDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
    }
    
    NSLog(@"reminderDate:%@",self.dogEar.reminderDate);
    NSLog(@"repeatingReminder:%@",self.dogEar.repeatingReminder);
    NSLog(@"category:%@",self.dogEar.category);
    NSLog(@"flagged:%@",self.dogEar.flagged);
    NSLog(@"title:%@",self.dogEar.title);
    NSLog(@"note:%@",self.dogEar.note);



}

- (void) addDogEar
{
    [activityIndicator startAnimating];
    
       //JT-Note: Add "insertedDate" only when add a new object.
    [self saveDogEar];

    NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
    [array addObject:self.dogEar];
    [self updateDogEarDataCollectionWithSelectedCollections:array];
    
    /*NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString * key = cell.detailTextLabel.text;
    
    NSDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    NSMutableArray * selectedObjects = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[dict objectForKey:key]]];
//    [[self decodedCollections] addObject:self.dogEar];
    [selectedObjects addObject:self.dogEar];
    
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:selectedObjects];
    [dict setValue:encodedObjects forKey:key];
    
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];*/
//    [self updateDogEarDataCollectionWithSelectedCollections:[self decodedCollections]];

    if (self.tabBarController.selectedIndex == 0)[self.navigationController popToRootViewControllerAnimated:YES];
    else {
        [self.tabBarController setSelectedIndex:0];
        UINavigationController * nc = [self.tabBarController.viewControllers objectAtIndex:0];
        [nc popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Print Feature

- (NSData *) generatePDFDataForPrinting
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, kPDFPageBounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [self drawStuffInContext:ctx];  // Method also usable from drawRect:.
    UIImageView * imageView = [[UIImageView alloc]initWithImage:self.image];
    [imageView.layer renderInContext:ctx];
    
    UIGraphicsEndPDFContext();
    return pdfData;
}

#pragma mark = UIAlertView Delegate


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
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Category";
            cell.detailTextLabel.text = self.dogEar.category ? self.dogEar.category : @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            
            cell.textLabel.text = @"Reminder";
            cell.detailTextLabel.text = (self.dogEar.reminderDate != NULL)? [NSString reminderSubtitleStyleWithDate:self.dogEar.reminderDate]: @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case 2:
        {
            cell.textLabel.text = @"Flagged";
            NSArray * flaggedItems = [[NSArray alloc]init];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BKFlaggedItems"])
                flaggedItems = [[[NSUserDefaults standardUserDefaults] objectForKey:@"BKFlaggedItems"] copy];
            else
                flaggedItems = [[NSArray alloc]initWithObjects:@"Casual",@"Somewhat Important",@"Important",@"Very Important",@"Crucial", nil];
            cell.detailTextLabel.text = (self.dogEar.flagged != NULL)?[flaggedItems objectAtIndex:[self.dogEar.flagged integerValue]]:@"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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
    NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        de_CategoryListViewController * tv = [[de_CategoryListViewController alloc]initWithStyle:UITableViewStylePlain];
        if (cell.detailTextLabel.text) tv.selectedIndexPath = [NSIndexPath indexPathForRow:[array indexOfObject:cell.detailTextLabel.text] inSection:0];
        else tv.selectedIndexPath = nil;    // JT-TODO: default choose the first category ?
        
//        tv.categoryString = cell.detailTextLabel.text;
        [self.navigationController pushViewController:tv animated:YES];
        
    }
    else if (indexPath.row == 1)
    {
        de_ReminderViewController * vc = [[de_ReminderViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc.selectedDate = self.dogEar && (self.dogEar.reminderDate != nil) ? self.dogEar.reminderDate:nil;
        vc.repeatedTimes = self.dogEar && (self.dogEar.repeatingReminder != nil) ? [self.dogEar.repeatingReminder integerValue]:0;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2)
    {
        de_FlagViewController * vc = [[de_FlagViewController alloc]initWithStyle:UITableViewStyleGrouped];
        if (self.dogEar.flagged != nil) vc.selectedIndexPath = [NSIndexPath indexPathForRow:[self.dogEar.flagged integerValue] inSection:0];
        else vc.selectedIndexPath = nil;
//        vc.selectedRow = self.dogEar && self.dogEar.flagged ? self.dogEar.flagged : nil;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3)
    {
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
            if (!completed && error) NSLog(@"Print error: %@", error);
        };
        
        NSData *pdfData = [self generatePDFDataForPrinting];
        printController.printingItem = pdfData;
        [printController presentAnimated:YES completionHandler:completionHandler];
    }
}

@end
