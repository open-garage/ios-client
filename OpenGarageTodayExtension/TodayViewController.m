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

#define AF_APP_EXTENSIONS

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic) GarageController *garageController;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (GarageController *)garageController {
    if (_garageController == nil) {
        _garageController = [[GarageController alloc] init];
    }
    
    return _garageController;
}

- (IBAction)toggleButtonPushed:(id)sender {
    NSLog(@"DBG: Extension button pushed");
    
    [self.garageController toggleWithResultBlock:^(BOOL success) {
        if (success) {
            NSLog(@"DBG: OK :)");
            
        } else {
            NSLog(@"DBG: ERROR :(");
        }
    }];
}

@end
