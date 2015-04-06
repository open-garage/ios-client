//
//  AccessoryBrowserTableViewController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 06.04.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

@import HomeKit;
#import "AccessoryBrowserTableViewController.h"

@interface AccessoryBrowserTableViewController () <HMAccessoryBrowserDelegate>

@property (strong, nonatomic) NSArray *accessories;
@property (strong, nonatomic) HMAccessoryBrowser *homeAccessoryBrowser;
@property (strong, nonatomic) HMHomeManager *homeManager;

@end

@implementation AccessoryBrowserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accessories = [[NSArray alloc] init];
    
    self.homeManager = [[HMHomeManager alloc] init];
    
    self.homeAccessoryBrowser = [[HMAccessoryBrowser alloc] init];
    self.homeAccessoryBrowser.delegate = self;
    [self.homeAccessoryBrowser startSearchingForNewAccessories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return self.accessories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccessoryCell" forIndexPath:indexPath];
    HMAccessory *accessory = self.accessories[indexPath.row];
    
    cell.textLabel.text = accessory.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HMAccessory *accessory = self.accessories[indexPath.row];
    
    if (self.homeManager.primaryHome) {
        if (self.homeManager.primaryHome.accessories.count == 0) {
            
            [self.homeManager.primaryHome addAccessory:accessory completionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"ERROR: Can not add accessory to primary home");
                } else {
                    NSLog(@"DBG: Added accessory to home");
                }
            }];
        } else {
            NSLog(@"ERROR: Garage door already added.");
        }
    }
    
    
    
}

- (NSArray *)allAccessoires
{
    return self.homeAccessoryBrowser.discoveredAccessories;
}

- (void)resetDisplayedAccessoires
{
    self.accessories = [self allAccessoires];
}

- (void)reloadTable
{
    [self resetDisplayedAccessoires];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - HMAccessoryBrowser delegates

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory
{
    NSLog(@"DBG: new accessory found name: %@ identifier: %@", accessory.name, accessory.identifier);
    [self reloadTable];
}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didRemoveNewAccessory:(HMAccessory *)accessory
{
    [self reloadTable];
}

@end
