//
//  de_DetailViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DetailViewController.h"
#import "de_DetailHeaderView.h"
#import "de_HeaderView.h"

#import "de_CategoryListViewController.h"
#import "de_ReminderViewController.h"
#import "de_FlagViewController.h"

#import "de_PhotoViewController.h"

#define kPDFPageBounds CGRectMake(0, 0, 8.5 * 72, 11 * 72)


@interface de_DetailViewController ()
{
    UIPrintInteractionController *printController;
    UIActivityIndicatorView * activityIndicator;
    
    de_HeaderView * headerView ;
}

@property (nonatomic) BOOL isEditing;
@property (nonatomic ,retain) UIImage * image;

- (NSData *)generatePDFDataForPrinting;

- (void) setTableViewUserInteractionEnable:(BOOL)enable;
- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)collections withObject:(DogEarObject*)object;
- (void) handleImageWithDogEarObject:(DogEarObject*)object;

- (NSMutableArray*) decodedCollectionsWithObject:(DogEarObject*)object;

@end

@implementation de_DetailViewController
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
    
    NSLog(@"viewDidLoad");
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-content-master"]];
    self.tableView.backgroundView = bgImage;
        
//    headerView = [[de_HeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
//    headerView.center = CGPointMake(self.view.center.x, headerView.center.y);
    headerView = [[de_HeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 120.0f)];

//    headerView.vcParent = self;
    if (self.existingDogEar == nil)
    {
        headerView.dogEar = nil;
        headerView.thumbImage = self.image;
        [self setHeaderViewEditingEnable:YES];

        self.dogEar = [DogEarObject new];
        [self.dogEar setInsertedDate:[NSDate date]];
        
        UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDogEar)];
        self.navigationItem.rightBarButtonItem = saveItem;
        self.navigationItem.title = @"Add A DogEar";

        
    }
    else if (self.existingDogEar != nil)
    {
        headerView.dogEar = self.existingDogEar;
        headerView.thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.existingDogEar.imagePath]];
        headerView.allowEditing = NO;
        
        [self setHeaderViewEditingEnable:NO];
        [self setTableViewUserInteractionEnable:NO];

        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = editItem;
        
        UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backToHome)];
        self.navigationItem.leftBarButtonItem = backItem;
        self.navigationItem.title = @"Details";
        self.dogEar = [self setupNewObjectWithObject:self.existingDogEar];

    }
    headerView.vcParent = self;
    self.tableView.tableHeaderView = headerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 44.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 20.0, 0.0f);
    
    //JT-Note:
    Class printControllerClass = NSClassFromString(@"UIPrintInteractionController");
    if (printControllerClass) {
        printController = [printControllerClass sharedPrintController];
    }

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [activityIndicator stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        if (self.dogEar.category == nil || self.dogEar.title == nil)    //JT - Comment: Necessary to select Category
        {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enter a Title and Category for your DogEar" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        else
        {
            NSLog(@"complete editing");
            
            [self setTableViewUserInteractionEnable:NO];
            [self setHeaderViewEditingEnable:NO];
            [self removeOldDogEarObject];
            [self updateNewDogEarObject];   // add latest object to saved Array
            

//            NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
//            
//            [array addObject:self.dogEar];
//            [self updateDogEarDataCollectionWithSelectedCollections:array];

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
        [self setHeaderViewEditingEnable:YES];
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];

        
        [self.navigationItem.leftBarButtonItem setTitle:@"Cancel"];
        [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
        [self.navigationItem.leftBarButtonItem setAction:@selector(cancelEditing)];
        

    }
}

#pragma mark - NSNotification Center

- (void) appHasGoneInBackground:(NSNotification*) notice
{
    NSLog(@"appHasGoneInBackground");
}


#pragma mark - Navigation Item Method

- (void) backToHome
{
    NSLog(@"backToHome");
    de_PhotoViewController * vc = (de_PhotoViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    vc.existingDogEar = self.dogEar;
    [self.navigationController popToViewController:vc animated:YES];
    
    NSLog(@"reminderDate:%@",self.dogEar.reminderDate);
    NSLog(@"repeatingReminder:%@",self.dogEar.repeatingReminder);
    NSLog(@"category:%@",self.dogEar.category);
    NSLog(@"flagged:%@",self.dogEar.flagged);
    NSLog(@"title:%@",self.dogEar.title);
    NSLog(@"note:%@",self.dogEar.note);
}

- (void) cancelEditing
{
    [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
    
    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
    [self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backToHome)];
    
    [self setTableViewUserInteractionEnable:NO];
    [self setHeaderViewEditingEnable:NO];
    self.isEditing = NO;

}


#pragma mark - Private Method

- (DogEarObject*) setupNewObjectWithObject:(DogEarObject*)object
{
    DogEarObject * dogEarObject = [DogEarObject new];
    [dogEarObject setCategory:object.category];
    [dogEarObject setTitle:object.title];
    [dogEarObject setNote:object.note];
    [dogEarObject setInsertedDate:object.insertedDate];
    [dogEarObject setFlagged:object.flagged];
    [dogEarObject setReminderDate:object.reminderDate];
    [dogEarObject setRepeatingReminder:object.repeatingReminder];
    [dogEarObject setImagePath:object.imagePath];
    
    return dogEarObject;
}

- (void) removeOldDogEarObject
{
    NSMutableArray * temp = [[NSMutableArray alloc]initWithArray:[self decodedCollectionsWithObject:self.existingDogEar]];
    
    for (int d = 0; d < [temp count]; d++)
    {
        DogEarObject * object = [temp objectAtIndex:d];
        if ([object.title isEqualToString:self.existingDogEar.title] && [object.insertedDate isEqualToDate:self.existingDogEar.insertedDate])
            [temp removeObject:object];
    }
    
    [self updateDogEarDataCollectionWithSelectedCollections:temp withObject:self.existingDogEar];
}

- (void) updateNewDogEarObject
{
    NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollectionsWithObject:self.dogEar]];
    
    [array addObject:self.dogEar];
    [self updateDogEarDataCollectionWithSelectedCollections:array withObject:self.dogEar];
    
    self.existingDogEar = [self setupNewObjectWithObject:self.dogEar];


}

- (void) setTableViewUserInteractionEnable:(BOOL)enable
{
    for (int c = 0; c < [self.tableView numberOfRowsInSection:0] - 1; c++) {
        NSIndexPath * disabledIndexPath = [NSIndexPath indexPathForRow:c inSection:0];
        UITableViewCell * disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
        [disabledCell setUserInteractionEnabled:enable];
    }
}

- (void) setHeaderViewEditingEnable:(BOOL)enable
{
    [headerView.titleField setEnabled:enable];
    [headerView.notesField setEditable:enable];
}

- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)collections withObject:(DogEarObject*)object
{
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:collections];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    [dict setObject:encodedObjects forKey:object.category];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"updateDogEarDataCollectionWithSelectedCollections");
}

- (void) handleImageWithDogEarObject:(DogEarObject*)object
{
    [object setImagePath:[NSString imagePathWithFileName:[object.title stringByAppendingFormat:@"%@",[NSString generateRandomString]]]];
    //JT-Note: Save Image to Device
    NSData *pngData = UIImagePNGRepresentation(self.image);
    [pngData writeToFile:object.imagePath atomically:YES];
}

#pragma mark - Private Getter / Setter

- (NSMutableArray*) decodedCollectionsWithObject:(DogEarObject*)object
{
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:object.category];
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        
    return decodedCollections;
}


#pragma mark - DogEar Method


- (void) addDogEar
{
    
    if (self.dogEar.category == nil || self.dogEar.title == nil)
    {
        if ([headerView.titleField.text length]>0)
            [self.dogEar setTitle:headerView.titleField.text];
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Please enter a Title and Category for your DogEar" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alertView show];
    }
    else
    {
        [activityIndicator startAnimating];
        if (self.existingDogEar != nil)
            [self handleImageWithDogEarObject:self.existingDogEar];
        else [self handleImageWithDogEarObject:self.dogEar];
        
        NSLog(@"reminderDate:%@",self.dogEar.reminderDate);
        NSLog(@"repeatingReminder:%@",self.dogEar.repeatingReminder);
        NSLog(@"category:%@",self.dogEar.category);
        NSLog(@"flagged:%@",self.dogEar.flagged);
        NSLog(@"title:%@",self.dogEar.title);
        NSLog(@"note:%@",self.dogEar.note);
        
        NSMutableArray * array = [[NSMutableArray alloc]initWithArray:[self decodedCollectionsWithObject:self.dogEar]];
        [array addObject:self.dogEar];
        [self updateDogEarDataCollectionWithSelectedCollections:array withObject:self.dogEar];
        
        if (self.tabBarController.selectedIndex == 0)[self.navigationController popToRootViewControllerAnimated:YES];
        else {
            [self.tabBarController setSelectedIndex:0];
            UINavigationController * nc = [self.tabBarController.viewControllers objectAtIndex:0];
            [nc popToRootViewControllerAnimated:YES];
        }
    }
    
    
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
//    if (section == 0) return 1;
//    else return 4;
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: NSDictionary
    
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    // Configure the cell...
   
//    if (indexPath.section == 0)
//    {
//        cell.textLabel.text = @"Note";
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    else if (indexPath.section == 1)
//   {
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
//   }

    
    return cell;
}

#pragma mark - UITableView Delegate Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
//    if (indexPath.section == 0)
//    {
//        UIViewController * vcNote = [[UIViewController alloc]init];
//        [self.navigationController pushViewController:vcNote animated:YES];
//        UITextView * textView = [[UITextView alloc]initWithFrame:vcNote.view.frame];
//        textView.text = self.dogEar.note ? self.dogEar.note : @"";
//        [vcNote.view addSubview:textView];
//    }
//    else if (indexPath.section == 1)
//    {
        if (indexPath.row == 0)
        {
            de_CategoryListViewController * tv = [[de_CategoryListViewController alloc]initWithStyle:UITableViewStylePlain];
            if (cell.detailTextLabel.text) tv.selectedIndexPath = [NSIndexPath indexPathForRow:[array indexOfObject:cell.detailTextLabel.text] inSection:0];
            else tv.selectedIndexPath = nil;    // JT-TODO: default choose the first category ?
            
            //        tv.categoryString = cell.detailTextLabel.text;
            [self.navigationController pushViewController:tv animated:YES];
            //        [self removeOldDogEarObject];
            
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
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];


            };
            
            NSData *pdfData = [self generatePDFDataForPrinting];
            printController.printingItem = pdfData;
            [printController presentAnimated:YES completionHandler:completionHandler];
        }
//    }
}

@end
