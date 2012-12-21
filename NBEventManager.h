//
//  NBEventManager.h
//  fish
//
//  Created by Yoshi on 12/20/12.
//
//
#import "RestKit/AFHTTPClient.h"
#import <RestKit/RestKit.h>

@interface NBEventManager : AFHTTPClient

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (NBEventManager *)sharedManager;

@end
