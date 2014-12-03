//
//  ViewController.m
//  OpenGarageApp
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import <OpenGarageKit/OpenGarageKit.h>
#import "ViewController.h"
#import "SettingsViewController.h"

@interface ViewController () <SettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (nonatomic) GarageController *garageController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

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
    _toggleButton.enabled = NO;
    [_progressIndicator startAnimating];
    
    
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
        
        _toggleButton.enabled = YES;
        [_progressIndicator stopAnimating];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSettings"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        SettingsViewController *settingsViewController = navigationController.viewControllers[0];
        settingsViewController.delegate = self;
        settingsViewController.token = self.garageController.token;
        settingsViewController.serverUrl = self.garageController.serverUrl;
    }
}

#pragma mark - SettingsViewController Delegates

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller withToken:(NSString *)token andURL:(NSString *)url {
    [self.garageController saveToken:token];
    [self.garageController saveServerURL:url];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
