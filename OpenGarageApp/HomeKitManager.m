//
//  HomeKitManager.m
//  OpenGarage
//
//  Created by Patrick Steiner on 04.04.15.
//  Copyright (c) 2015 Patrick Steiner. All rights reserved.
//

@import HomeKit;
#import "HomeKitManager.h"

@interface HomeKitManager () <HMHomeManagerDelegate, HMAccessoryBrowserDelegate>

@property (strong, nonatomic) HMHomeManager *homeManager;
@property (strong, nonatomic) NSArray *homes;
@property (strong, nonatomic) HMHome *primaryHome;

@property (strong, nonatomic) HMHome *home;
@property (strong, nonatomic) HMRoom *room;
@property (strong, nonatomic) HMAccessory *accessory;

@property (strong, nonatomic) HMAccessoryBrowser *accessoryBrowser;

@end

@implementation HomeKitManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupHomeKit];
    }
    return self;
    
}

- (void)setupHomeKit
{
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
}

- (void)homeKitBrowserAccessoryStart
{
    NSLog(@"DBG: start scanning for accessories");
    self.accessoryBrowser = [[HMAccessoryBrowser alloc] init];
    self.accessoryBrowser.delegate = self;
    [self.accessoryBrowser startSearchingForNewAccessories];
}

- (void)homeKitBrowserAccessoryStop
{
    [self.accessoryBrowser stopSearchingForNewAccessories];
}

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager
{
    NSLog(@"DBG: did update homes");
    self.homes = manager.homes;
    self.primaryHome = manager.primaryHome;
    
    NSLog(@"DBG: found homes: %lu", (unsigned long)self.homes.count);
    
    if (self.primaryHome) {
        NSLog(@"DBG: primary home: %@", self.primaryHome.name);
        
        
        for (HMAccessory *accessory in self.primaryHome.accessories) {
            NSLog(@"DBG: accessory name: %@ accessory id: %@", accessory.name, accessory.identifier);
        }
    }
    
    if (self.homes.count < 1) {
        [self addHomeToHomeManager];
    }
}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory
{
    NSLog(@"DBG: new accessory found name: %@ identifier: %@", accessory.name, accessory.identifier);
}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didRemoveNewAccessory:(HMAccessory *)accessory
{
    NSLog(@"DBG: remove accessory %@", accessory.name);
}

- (void)addHomeToHomeManager
{
    __weak typeof(self) weakSelf = self;
    
    [self.homeManager addHomeWithName:@"Liezen #1" completionHandler:^(HMHome *home, NSError *error) {
        if (error != nil) {
            NSLog(@"ERROR: Adding the home failed");
        } else {
            NSLog(@"DBG: Adding the home was successful");
            weakSelf.home = home;
            [weakSelf addRoomToHome:home];
        }
    }];
}

- (void)addRoomToHome:(HMHome *)home
{
    __weak typeof(self) weakSelf = self;
    
    [home addRoomWithName:@"Garage" completionHandler:^(HMRoom *room, NSError *error) {
        if (error != nil) {
            NSLog(@"ERROR: Adding the room failed");
        } else {
            NSLog(@"DBG: Successfully added the room");
            
            weakSelf.room = room;
        }
    }];
}

- (void)addAccessoryToRoom:(HMRoom *)room
{

}

@end