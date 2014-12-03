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

// https://192.168.0.165:8000/api/v1/toggle

/**
 iOS Certificate Pinnig:
 http://initwithfunk.com/blog/2014/03/12/afnetworking-ssl-pinning-with-self-signed-certificates/#fnref:1
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
}

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock {
    if ([_serverUrl length] > 0 && [_token length] > 0) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        NSDictionary *parameters = @{@"token": _token};
        NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:_serverUrl parameters:parameters error:nil];
        
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"ERROR: %@", error);
                resultBlock(false);
            } else {
                NSHTTPURLResponse *resp = (NSHTTPURLResponse*)response;
                
                if (resp.statusCode == 200) {
                    NSString *errorString = [responseObject[@"error"] stringValue];
                    if ([errorString isEqualToString:@"0"]) {
                        resultBlock(true);
                    } else {
                        NSLog(@"ERROR: code: %@", errorString);
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

@end
