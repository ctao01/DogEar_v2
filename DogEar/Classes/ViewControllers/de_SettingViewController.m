//
//  BKSettingViewController.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/16/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_SettingViewController.h"
#import "de_AccountSettingViewController.h"
#import "de_AboutViewController.h"

@interface de_SettingViewController ()
@end

@implementation de_SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-content-master"]];
    self.tableView.backgroundView = bgImage;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (void) backToPhotoViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -

- (void) rescheduleAllNotifications
{
    NSData * decodedObjects = [[NSUserDefaults standardUserDefaults]objectForKey:@"DogEar_Notifications"];
    NSArray * notifications = [NSKeyedUnarchiver unarchiveObjectWithData:decodedObjects ];
    
    NSLog(@"rescheduleAllNotifications:%i",[notifications count]);

    for (UILocalNotification *notification in notifications)
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

}

- (void) cancelAllNotifications
{
    NSArray * notifications = [NSArray arrayWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
    NSLog(@"cancelAllNotifications:%i",[notifications count]);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:notifications];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObjects forKey:@"DogEar_Notifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark -

- (void) switchTurnOnOff:(id)sender
{
    UISwitch * toggle = (UISwitch*)sender;
    NSLog(@"toggle.on=%@",toggle.on? @"YES":@"NO");
    if (toggle.on)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DogEar_PostNotification"];
        [self rescheduleAllNotifications];
        [toggle setOn:YES animated:YES];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"DogEar_PostNotification"];
        [self cancelAllNotifications];

        [toggle setOn:NO animated:YES];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"About";
            break;
        case 1:
        {
            cell.textLabel.text = @"Notifications";
            UISwitch * reminderSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 44.0f)];
            [reminderSwitch addTarget:self action:@selector(switchTurnOnOff:) forControlEvents:UIControlEventValueChanged];
            reminderSwitch.on = ([[NSUserDefaults standardUserDefaults]boolForKey:@"DogEar_PostNotification"]==YES) ? YES:NO;
            cell.accessoryView = reminderSwitch;
            cell.selectionStyle = UITableViewCellAccessoryNone;
        }
            break;
        case 2:
            cell.textLabel.text = @"Facebook/Twitter";
            break;
        case 3:
            cell.textLabel.text = @"How To Use";
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
   
    if (indexPath.row == 0)
    {
        de_AboutViewController * vc = [[de_AboutViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if (indexPath.row == 2)
    {
        de_AccountSettingViewController * vc = [[de_AccountSettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if (indexPath.row == 3)
    {
        UIViewController * vc = [[UIViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        
        float height = [self.tabBarController.view bounds].size.height;
        float width = [self.tabBarController.view bounds].size.width;
        
        NSLog(@"%f",height);
        UIImageView *backgroundImage ;
        if (height >= 568.0f)
            backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-instructions-fix-568h"]];
        else
            backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-instructions-fix"]];
        
        CGRect bgFrame = CGRectMake(0.0f, 0.0f, width, height - 20.0f - 44.0f - 49.0f);
        backgroundImage.frame = bgFrame;
        [vc.view addSubview:backgroundImage];
        [vc.navigationItem setTitle:cell.textLabel.text];
    }
        
}

@end
