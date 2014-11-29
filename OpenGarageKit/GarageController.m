//
//  GarageController.m
//  GarageOpen
//
//  Created by Patrick Steiner on 09.11.14.
//  Copyright (c) 2014 Patrick Steiner. All rights reserved.
//

#import "GarageController.h"
#import <AFNetworking.h>

#define kSERVERURL @"https://192.168.0.165:8000/api/v1/toggle"
#define kToken @"A"

/**
 iOS Certificate Pinnig:
 http://initwithfunk.com/blog/2014/03/12/afnetworking-ssl-pinning-with-self-signed-certificates/#fnref:1
 */

@implementation GarageController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadToken];
    }
    return self;
}

- (void)loadToken {
    _token = @"A";
}

- (void)saveToken:(NSString *)token {
    _token = token;
}

- (void)toggleWithResultBlock:(void (^)(BOOL success))resultBlock {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    NSDictionary *parameters = @{@"token": kToken};
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:kSERVERURL parameters:parameters error:nil];
    
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
}

@end
