//
//  GarageController.m
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "GarageController.h"
#import <AFNetworking.h>

#define kToken @"token"
#define kServerURL @"serverurl"

/**
 iOS Certificate Pinnig:
 http://initwithfunk.com/blog/2014/03/12/afnetworking-ssl-pinning-with-self-signed-certificates/#fnref:1
 
 Convert crt to cer
 openssl x509 -in server.crt -outform der -out server.cer
 */

@implementation GarageController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadStoredData];
    }
    return self;
}

- (void)loadStoredData {
    [self loadServerURL];
    [self loadToken];
}

- (void)loadToken {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    NSString *token = [defaults objectForKey:kToken];
    
    _token = token;
}

- (void)saveToken:(NSString *)token {
    _token = token;
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    [defaults setObject:token forKey:kToken];
    [defaults synchronize];
}

- (void)loadServerURL {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    NSString *url = [defaults objectForKey:kServerURL];
    
    _serverUrl = url;
}

- (void)saveServerURL:(NSString *)url {
    _serverUrl = url;
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.at.helmsdeep.opengarage"];
    [defaults setObject:url forKey:kServerURL];
    [defaults synchronize];
}

- (void)apiCall:(NSString*)call WithResultBlock:(void (^)(BOOL success))resultBlock {
    if ([_serverUrl length] > 0 && [_token length] > 0) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        NSString *url = [NSString stringWithFormat:@"%@/api/v1/%@", _serverUrl, call];
        //NSLog(@"DBG: URL: %@ - Token: %@", url, _token);
        
        NSDictionary *parameters = @{@"token": _token};
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
        NSLog(@"ERROR: serverurl or authentication token empty");
        resultBlock(false);
    }
}

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock {
    [self apiCall:@"toggle" WithResultBlock:^(BOOL success) {
        resultBlock(success);
    }];
}

- (void)statusWithResultBlock:(void (^)(BOOL success))resultBlock {
    [self apiCall:@"status" WithResultBlock:^(BOOL success) {
        resultBlock(success);
    }];
}

@end
