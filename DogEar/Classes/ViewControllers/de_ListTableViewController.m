//
//  BKCategoryViewController.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/19/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_ListTableViewController.h"
#import "de_PhotoViewController.h"
#import "DogEarObject.h"

@interface de_ListTableViewController ()

@end

@implementation de_ListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISegmentedControl * segmentControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Most Recent", @"Most Important", nil]];
    segmentControl.frame = CGRectMake(0.0f, 5.0f, 200.0f, 30.0f);
    segmentControl.center = CGPointMake(self.view.center.x, segmentControl.center.y);
    [segmentControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [view addSubview:segmentControl];
    
    self.tableView.tableHeaderView = view;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertedDate" ascending:FALSE];
    [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISegmentControl Action Method

- (void)didChangeSegmentControl:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            //JT- TODO: Array Sort By Date
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertedDate" ascending:FALSE];
            [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
            break;
        case 1:
            NSLog(@"sort by important");
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.collections) return 1;
    else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.collections) return [self.collections count];
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    /*NSDictionary * dogEar = (NSDictionary*)[self.collections objectAtIndex:indexPath.row];
    cell.textLabel.text = [dogEar objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString mediumStyleDateAndShortStyleTimeWithDate:[dogEar objectForKey:@"insertedDate"]];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[dogEar objectForKey:@"imagePath"]]];
    cell.imageView.image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:[[dogEar objectForKey:@"imageOrientation"] integerValue]];*/
    NSDictionary * dogEarDict = (NSDictionary*)[self.collections objectAtIndex:indexPath.row];
    DogEarObject * selectedDogEar = [DogEarObject new];
    [dogEarDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [selectedDogEar setValue:obj forKey:(NSString *)key];
    }];
    cell.textLabel.text = selectedDogEar.title;
    cell.detailTextLabel.text = [NSString mediumStyleDateAndShortStyleTimeWithDate:selectedDogEar.insertedDate];
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile: selectedDogEar.imagePath]];
    UIImage * thumbImage = [[UIImage alloc]initWithCGImage:image.CGImage scale:1.0f orientation:[selectedDogEar.imageOrientation integerValue]];
    cell.imageView.image = thumbImage;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table View Delegate Method

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dogEarDict = (NSDictionary*)[self.collections objectAtIndex:indexPath.row];
    DogEarObject * selectedDogEar = [DogEarObject new];
    [dogEarDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [selectedDogEar setValue:obj forKey:(NSString *)key];
    }];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:selectedDogEar.imagePath]];
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:[[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:[selectedDogEar.imageOrientation integerValue] ] toolBarType:BKToolBarTypeViewing];
    [self.navigationController pushViewController:vc animated:YES];
    [vc setExistingDogEar:selectedDogEar];
   
}

@end
