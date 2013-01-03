
/*
     File: LocationsAppDelegate.h
 
 */
#import <RestKit/RestKit.h>


@class User;


@interface LocationsAppDelegate : UIResponder <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	
	RKObjectManager *objectManager;
	User *user;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) RKObjectManager *objectManager;

@property (nonatomic, retain) User *user;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;

@end
