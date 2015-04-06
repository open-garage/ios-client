//
//  ManageHomeKitViewController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 06.04.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

@import HomeKit;
#import "ManageHomeKitViewController.h"

@interface ManageHomeKitViewController () <HMHomeManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *garageAccessoryInfoLabel;

@property (strong, nonatomic) HMHomeManager *homeManager;

@property (strong, nonatomic) HMHome *primaryHome;

@end

@implementation ManageHomeKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)removeCurrentGarageDoorPushed:(id)sender {
    NSLog(@"DBG: removing garage from primary home");
    
    if (self.primaryHome) {
        
        if (self.primaryHome.accessories && self.primaryHome.accessories.count > 0) {
            HMAccessory *accessory = self.primaryHome.accessories[0];
            
            [self.primaryHome removeAccessory:accessory completionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"ERROR: Can not remove garage door accessory");
                } else {
                    NSLog(@"DBG: Accessory removed");
                }
            }];
        }
    }
}

#pragma mark - HMHomeManager delegates

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
    NSLog(@"DBG: setting primary home");
    
    if (manager.primaryHome) {
        self.primaryHome = manager.primaryHome;
        
        self.homeNameTextField.text = self.primaryHome.name;
        
        if (self.primaryHome.rooms && self.primaryHome.rooms.count > 0) {
            self.roomNameTextField.text = [self.primaryHome.rooms[0] name];
        }
        
        if (self.primaryHome.accessories && self.primaryHome.accessories.count == 1) {
            HMAccessory *accessory = self.primaryHome.accessories[0];
            self.garageAccessoryInfoLabel.text = [NSString stringWithFormat:@"Status: Primary Home: %@ - Accessory: %@ - Room: %@", self.primaryHome.name, accessory.name, accessory.room.name];
        }
    }
}

@end
