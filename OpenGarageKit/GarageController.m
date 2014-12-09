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

@implementation GarageController

- (void)saveGarageKey:(GarageKey *)garageKey
{
    _garageKey = garageKey;
    [_garageKey saveKey];
}

- (void)apiCall:(NSString*)call WithResultBlock:(void (^)(BOOL success))resultBlock {
    if ([_garageKey isValid]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        
        manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        manager.securityPolicy.allowInvalidCertificates = YES;
        
        NSString *url = [NSString stringWithFormat:@"%@/api/v1/%@", [_garageKey serverURL], call];
        //NSLog(@"DBG: URL: %@ - Token: %@", url, _garageKey.serverToken);
        
        NSDictionary *parameters = @{@"token": _garageKey.serverToken};
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
