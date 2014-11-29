//
//  ViewController.m
//  OpenGarageApp
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "ViewController.h"
#import <OpenGarageKit/OpenGarageKit.h>

@interface ViewController ()

@property (nonatomic) GarageController *garageController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (GarageController *)garageController {
    if (_garageController == nil) {
        _garageController = [[GarageController alloc] init];
    }
    
    return _garageController;
}

- (IBAction)toggleButtonPushed:(id)sender {
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
