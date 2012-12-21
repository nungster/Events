//
//  NBEventManager.m
//  fish
//
//  Created by Yoshi on 12/20/12.
//
//

#import "NBEventManager.h"
#import "RestKit/AFJSONRequestOperation.h"
#import "RestKit/AFNetworkActivityIndicatorManager.h"


@implementation NBEventManager

#pragma mark - Methods

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;
{
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
	
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
	
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
	
    return self;
}

#pragma mark - Singleton Methods

+ (NBEventManager *)sharedManager
{
    static dispatch_once_t pred;
    static NBEventManager *_sharedManager = nil;
	
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURL:gBaseURL]; });
	
    return _sharedManager;
}

@end
