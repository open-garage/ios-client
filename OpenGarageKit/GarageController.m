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

- (void)apiCall:(NSString*)call WithResultBlock:(void (^)(BOOL success))resultBlock
{
    if ([self.garageKey isValid]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"DBG: REACHABLE");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                case AFNetworkReachabilityStatusUnknown:
                default:
                    NSLog(@"DBG: NOT REACHABLE");
                    break;
            }
        }];
        
        NSString *url = [NSString stringWithFormat:@"%@/api/v1/%@", [self.garageKey serverURL], call];
        
        //NSLog(@"DBG: URL: %@ - Token: %@", url, self.garageKey.serverToken);
        //NSDictionary *parameters = @{@"token": self.garageKey.serverToken};
        NSDictionary *parameters = @{
                                     @"token": self.garageKey.serverToken,
                                     @"debug": @1
                                     };
        
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
    if ([self.garageKey serverURL]) {
        NSURL *baseURL = [NSURL URLWithString:[self.garageKey serverURL]];
        _serverStatusManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        NSOperationQueue *operationQueue = _serverStatusManager.operationQueue;
        
        __weak typeof(self) weakSelf = self;
        
        [_serverStatusManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    //NSLog(@"DBG: Open-Garage server %@ is reachable", baseURL);
                    [operationQueue setSuspended:NO];
                    [weakSelf openGarageServerIsReachable:YES];
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    //NSLog(@"DBG: Open-Garage server %@ is NOT reachable", baseURL);
                    [operationQueue setSuspended:YES];
                    [weakSelf openGarageServerIsReachable:NO];
                    break;
            }
        }];
        
        [_serverStatusManager.reachabilityManager startMonitoring];
    } else {
        NSLog(@"ERROR: No server URL set");
    }
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
