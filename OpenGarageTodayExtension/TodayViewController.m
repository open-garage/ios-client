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
    
    
    //TODO: Feature is not available in exentsions of type com.apple.widget-extension
    [self.garageController toggleWithResultBlock:^(BOOL success) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Garage Door", @"Garage Door Open Dialog") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:okButton];
        
        if (success) {
            alert.message = NSLocalizedString(@"Successfully toggled garage door", @"Garage door successfully opened dialog");
            
        } else {
            alert.message = NSLocalizedString(@"Error while toggling garage door", @"Error while toggling garage door dialog");
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
