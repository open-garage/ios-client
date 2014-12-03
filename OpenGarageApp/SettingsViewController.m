//
//  SettingsViewController.m
//  OpenGarage
//
//  Created by Patrick Steiner on 29.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverUrlTextField;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tokenTextField.text = _token;
    _serverUrlTextField.text = _serverUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPushed:(id)sender {
    _token = _tokenTextField.text;
    _serverUrl = _serverUrlTextField.text;
    
    if ([self checkinput]) {
        [_delegate settingsViewControllerDidFinish:self withToken:_token andURL:_serverUrl];
    }
}
- (IBAction)cancelButtonPushed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)checkinput {
    // check if strings are empty
    if ([_token length] < 1 || [_serverUrl length] < 1) {
        return false;
    }
    
    return true;
}

@end
