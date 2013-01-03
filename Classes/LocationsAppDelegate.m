
/*
     File: LocationsAppDelegate.m
 
 
 */

#import "LocationsAppDelegate.h"
#import "RootViewController.h"
#import "GDataXMLNode.h"

#import "User.h"
#import "Event.h"
#import "AuthenticationViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "RestKit/AFNetworking.h"
#import "NBEventManager.h"

NSURL *gBaseURL = nil;

@interface LocationsAppDelegate ()

- (void)configureRestKit;
- (void)login;
- (void)showAuthentication:(User *)user;

@end


@implementation LocationsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize user;
@synthesize objectManager;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Initialize RestKit
	gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
	objectManager = [RKObjectManager managerWithBaseURL:gBaseURL];
//	NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Fishn" ofType:@"momd"]];
    // Enable Activity Indicator Spinner
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
    // Initialize managed object store
//	managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
	objectManager.managedObjectStore = managedObjectStore;

	// configure RestKit Data Store
/*
	NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Fishn.sqlite"];
	[managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:nil];
	[managedObjectStore createManagedObjectContexts];
*/
    
	// Setup our object mappings
    /**
     Mapping by entity. Here we are configuring a mapping by targetting a Core Data entity with a specific
     name. This allows us to map back Twitter user objects directly onto NSManagedObject instances --
     there is no backing model class!
     */
	RKEntityMapping *eventMapping = [RKEntityMapping mappingForEntityForName:@"Event" inManagedObjectStore:managedObjectStore];
	[eventMapping addAttributeMappingsFromDictionary:@{
	 @"id": @"eventId",
	 @"name": @"name",
	 @"amount": @"amount",
	 @"length": @"length",
	 @"updated_at": @"updatedAt",
	 @"created_at": @"createdAt",
	 @"latitude": @"latitude",
	 @"longitude": @"longitude",
	 @"thumbnail": @"thumbnail",
	 @"airTemp": @"airTemp",
	 }];
	eventMapping.identificationAttributes = @[ @"eventId" ];

	//RKRelationshipMapping *eventRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"events"
	//																					   toKeyPath:@"events"
	//																					 withMapping:eventMapping];
	//[eventMapping addPropertyMapping:eventRelationship];
 
	// Register our mappings with the provider
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping
                                                                                       pathPattern:nil
                                                                                           keyPath:@"event"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

	// Core Data configuration
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Fishn.sqlite"];
    //NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
	
	// *****************************************************************************************************************
	
	
	
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
	}
	rootViewController.managedObjectContext = context;
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	
	//[window addSubview:[navigationController view]];
	[window setRootViewController:navigationController];
	[window makeKeyAndVisible];
	
    [self login];
	
	//NSLog(@"App Del %@ - %@", user.login, user.password);
	//[[RKObjectManager sharedManager].HTTPClient setAuthorizationHeaderWithUsername:user.login password:user.password];
	
	[rootViewController release];
	[aNavigationController release];
    

    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
}


- (void)saveContext {
    
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    

#pragma mark -
#pragma mark Authentication


- (void)configureRestKit {
#if TARGET_IPHONE_SIMULATOR
	gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
#else
	gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
#endif
	//self.user.login = @"user@example.com";
	//self.user.password = @"please";
    //[ObjectiveResourceConfig setResponseType:JSONResponse];
    //[ObjectiveResourceConfig setUser:[self.user login]];
    //[ObjectiveResourceConfig setPassword:[self.user password]];
}

- (User *)user {
    if (user == nil) {
        //NSURL *url = [NSURL URLWithString:[ObjectiveResourceConfig getSite]];
        self.user = [User currentUserForSite:gBaseURL];
        [user addObserver:self];
    }
    return user;
}

- (void)showAuthentication:(User *)aUser {
    AuthenticationViewController *controller =
	[[AuthenticationViewController alloc] initWithCurrentUser:aUser];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)login {
    if ([self.user hasCredentials]) {
        NSError *error = nil;
        BOOL authenticated = [self.user authenticate:&error];
        if (authenticated == NO) {
            [AppHelpers handleRemoteError:error];
            [self showAuthentication:self.user];
        }
    } else {
        [self showAuthentication:self.user];
    }
}

#pragma mark -
#pragma mark Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kUserLoginKey]) {
		NSLog(@"%@",[object valueForKeyPath:keyPath]);
		//user.login = [object valueForKeyPath:keyPath];
        //[ObjectiveResourceConfig setUser:[object valueForKeyPath:keyPath]];
		[user saveCredentialsToKeychain];
		//[self setUser:[object valueForKeyPath:keyPath]];

    } else if ([keyPath isEqualToString:kUserPasswordKey]){
        //user.password = [object valueForKeyPath:keyPath];
		//[ObjectiveResourceConfig setPassword:[object valueForKeyPath:keyPath]];
		//[user setPassword:[object valueForKeyPath:keyPath]];
		[user saveCredentialsToKeychain];
    }
}

#pragma mark -
#pragma mark Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Fishn.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

	// Allow inferred migration from the original version of the application.
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}


@end
