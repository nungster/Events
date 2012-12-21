#import "User.h"

#import "Session.h"

@interface User ()
- (void)loadCredentialsFromKeychain;
- (NSURLProtectionSpace *)protectionSpace;
@end

@implementation User

@synthesize login;
@synthesize password;
@synthesize siteURL;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [login release];
    [password release];
    [siteURL release];
    [super dealloc];
}

+ (User *)currentUserForSite:(NSURL *)aSiteURL {
    User *user = [[[self alloc] init] autorelease];
    user.siteURL = aSiteURL;
    [user loadCredentialsFromKeychain];
    return user;
}

- (BOOL)hasCredentials {    
    return (self.login != nil && self.password != nil);
}

- (BOOL)authenticate:(NSError **)error { 
    if (![self hasCredentials]) {
		NSLog(@"User does not have cred");
        return NO;
    }
    
    Session *session = [[[Session alloc] init] autorelease];
    session.login = self.login;
    session.password = self.password;
	
    NSLog(@"User has street cred");
    return YES;
}

- (void)saveCredentialsToKeychain {
    NSURLCredential *credentials = 
        [NSURLCredential credentialWithUser:self.login
                                   password:self.password
                                persistence:NSURLCredentialPersistencePermanent];
    
    [[NSURLCredentialStorage sharedCredentialStorage]   
        setDefaultCredential:credentials forProtectionSpace:[self protectionSpace]];
}

#pragma mark -
#pragma mark Key-value observing

- (void)addObserver:(id)observer {
    [self addObserver:observer forKeyPath:kUserLoginKey options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:kUserPasswordKey options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer forKeyPath:kUserLoginKey];
    [self removeObserver:observer forKeyPath:kUserPasswordKey];
}

-(id)valueForKey:(NSString *)key {
	if ([key isEqualToString:@"login"]) {
		if (login == nil)
			return [NSNull null];
		return login;
	}
	if ([key isEqualToString:@"password"]) {
		if (password == nil)
			return [NSNull null];
		return password;
	}
	@throw [NSException exceptionWithName:NSUndefinedKeyException reason:[NSString stringWithFormat:@"key '%@' not found", key] userInfo:nil];
	return nil;
}

-(NSArray *)allKeys {
	return [NSArray arrayWithObjects:@"login", @"password", nil];
}

-(NSArray *)allValues {
	return [NSArray arrayWithObjects:login, password, nil];
}

#pragma mark -
#pragma mark Private methods

- (void)loadCredentialsFromKeychain {
    NSDictionary *credentialInfo = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:[self protectionSpace]];

    // Assumes there's only one set of credentials, and since we
    // don't have the username key in hand, we pull the first key.
    NSArray *keys = [credentialInfo allKeys];
    if ([keys count] > 0) {
        //NSString *userNameKey = [[credentialInfo allKeys] objectAtIndex:0];
        //NSURLCredential *credential = [credentialInfo valueForKey:userNameKey];
		NSURLCredential *credential = [[ NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[self protectionSpace]];
        self.login = credential.user;
        self.password = credential.password;
    }
}

- (NSURLProtectionSpace *)protectionSpace {
    return [[[NSURLProtectionSpace alloc] initWithHost:[siteURL host]
                                                  port:[[siteURL port] intValue]
                                              protocol:[siteURL scheme]
                                                 realm:@"Web Password"
                                  authenticationMethod:NSURLAuthenticationMethodDefault] autorelease];
}

@end
