//
//  GarageController.m
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "GarageController.h"
#import <AFNetworking.h>

/**
 iOS Certificate Pinnig:
 http://initwithfunk.com/blog/2014/03/12/afnetworking-ssl-pinning-with-self-signed-certificates/#fnref:1
 
 Convert crt to cer
 openssl x509 -in server.crt -outform der -out server.cer
 */

@interface GarageController ()

@property (nonatomic) AFHTTPRequestOperationManager *serverStatusManager;

@end

@implementation GarageController

- (GarageKey *)garageKey
{
    if (_garageKey == nil) {
        _garageKey = [[GarageKey alloc] init];
    }
    
    return _garageKey;
}

- (void)saveGarageKey:(GarageKey *)garageKey
{
    _garageKey = garageKey;
    [self.garageKey saveKey];
}

- (BOOL)garageKeyIsValid
{
    if ([self.garageKey.serverAddress length] < 1) {
        return NO;
    }
    
    if ([self.garageKey.serverPort integerValue] < 1) {
        return NO;
    }
    
    if ([self.garageKey.serverToken length] < 1) {
        return NO;
    }
    
    return YES;
}

- (void)apiCall:(NSString*)call WithResultBlock:(void (^)(BOOL success))resultBlock
{
    if ([self.garageKey isValid]) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        NSString *url = [NSString stringWithFormat:@"%@/api/v1/%@", [self.garageKey serverURL], call];
        
        //NSLog(@"DBG: URL: %@ - Token: %@", url, self.garageKey.serverToken);
        
        NSDictionary *parameters;
        
        if (_debuggingMode) {
            parameters = @{
                           @"token": self.garageKey.serverToken,
                           @"state": @"toggle",
                           @"debug": @"on"
                           };
        } else {
            parameters = @{
                           @"token": self.garageKey.serverToken,
                           @"state": @"toggle"
                           };
        }
        
        NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"ERROR: %@", error);
                resultBlock(false);
            } else {
                NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
                
                if (resp.statusCode == 200) {
                    NSString *errorString = [responseObject[@"status"] stringValue];
                    if ([errorString isEqualToString:@"0"]) {
                        resultBlock(true);
                    } else {
                        NSLog(@"Status code: %@", errorString);
                        resultBlock(false);
                    }
                } else {
                    NSLog(@"ERROR: %@ %@", response, responseObject);
                    resultBlock(false);
                }
            }
        }];
        
        [dataTask resume];
    } else {
        NSLog(@"ERROR: Garage key is no valid.");
        resultBlock(false);
    }
}

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock
{
    [self apiCall:@"toggle" WithResultBlock:^(BOOL success) {
        resultBlock(success);
    }];
}

- (void)statusWithResultBlock:(void (^)(BOOL success))resultBlock
{
    [self apiCall:@"status" WithResultBlock:^(BOOL success) {
        resultBlock(success);
    }];
}

- (void)startMonitoringServer
{
    __weak typeof(self) weakSelf = self;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //NSLog(@"DBG: Network is reachable");
                [weakSelf openGarageServerIsReachable:YES];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
            default:
                //NSLog(@"DBG: Network is NOT reachable");
                [weakSelf openGarageServerIsReachable:NO];
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stopMonitoringServer
{
    [_serverStatusManager.reachabilityManager stopMonitoring];
}

- (void)openGarageServerIsReachable:(BOOL)reachable
{
    _serverIsReachable = reachable;
    [_delegate openGarageServerReachabilityChanged:reachable];
}

@end
