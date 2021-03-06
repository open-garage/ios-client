//
//  TodayViewController.m
//  OpenGarageTodayExtension
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <OpenGarageKit/OpenGarageKit.h>

// enable for AFNetworking
#define AF_APP_EXTENSIONS

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic) GarageController *garageController;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _infoLabel.text = @"";
    
    //self.preferredContentSize = CGSizeMake(0, 88);
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    _infoLabel.text = @"Refreshing...";
    
    [self.garageController statusWithResultBlock:^(BOOL success, GarageDoorStatus status) {
        if (success) {
            switch (status) {
                case GarageDoorStatusClosed:
                    _infoLabel.text = @"Closed";
                    break;
                case GarageDoorStatusOpen:
                    _infoLabel.text = @"Open";
                    break;
                case GarageDoorStatusError:
                    _infoLabel.text = @"Error";
                    break;
                default:
                    _infoLabel.text = @"Unknown";
                    break;
            }
            
            completionHandler(NCUpdateResultNewData);
            
        } else {
            completionHandler(NCUpdateResultFailed);
        }
    }];

    completionHandler(NCUpdateResultNewData);
}

- (GarageController *)garageController {
    if (_garageController == nil) {
        _garageController = [[GarageController alloc] init];
        
        _garageController.debuggingMode = DEBUGGING_MODE;
    }
    
    return _garageController;
}

- (IBAction)toggleButtonPushed:(id)sender {
    [self.garageController toggleWithResultBlock:^(BOOL success) {
        if (success) {
            _infoLabel.text = @"OK";
        } else {
            _infoLabel.text = @"ERROR";
        }
    }];
}

@end
