//
//  GarageKey.m
//  OpenGarage
//
//  Created by Patrick Steiner on 09.12.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "GarageKey.h"
#import "OpenGarageConstants.h"

@implementation GarageKey

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadKey];
    }
    return self;
}

-(void)saveKey
{
    if ([self isValid]) {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
        
        [defaults setObject:_serverToken forKey:kToken];
        [defaults setObject:_serverAddress forKey:kServerAddress];
        [defaults setObject:_serverPort forKey:kServerPort];
        
        [defaults synchronize];
    }
}

- (void)loadKey
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    
    _serverToken = [defaults objectForKey:kToken];
    _serverAddress = [defaults objectForKey:kServerAddress];
    _serverPort = [defaults objectForKey:kServerPort];
}

- (BOOL)isValid
{
    // TODO: implement a better value checking.
    if ([_serverToken length] < 1) {
        NSLog(@"ERROR: server token (%@) is invalid", _serverToken);
        return NO;
    }
    
    if ([_serverAddress length] < 1) {
        NSLog(@"ERROR: server address (%@) is invalid", _serverAddress);
        return NO;
    }
    
    if ([_serverPort integerValue] < 1) {
        NSLog(@"ERROR: server port (%@) is invalid", _serverPort);
        return NO;
    }
    
    return YES;
}

- (NSString *)serverURL
{
    if ([self isValid]) {
        return [NSString stringWithFormat:@"https://%@:%li", _serverAddress, (long)[_serverPort integerValue]];
    }
    
    return nil;
}

@end
