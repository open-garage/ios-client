//
//  SettingsViewController.h
//  OpenGarage
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGarageKit/OpenGarageKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller withGarageKey:(GarageKey *)garageKey;

@end

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic) GarageKey *garageKey;

@end
