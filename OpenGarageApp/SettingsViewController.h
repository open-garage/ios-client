//
//  SettingsViewController.h
//  OpenGarage
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller withToken:(NSString *)token;

@end

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id<SettingsViewControllerDelegate> delegate;
@property (nonatomic) NSString *token;

@end
