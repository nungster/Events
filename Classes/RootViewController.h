
/*
     File: RootViewController.h
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 

 
 */

#import <CoreLocation/CoreLocation.h>
#import <RestKit/RestKit.h>

@class User;

@interface RootViewController : UITableViewController <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate> {
	
    NSArray *eventsArray;

	NSManagedObjectContext *managedObjectContext;

    CLLocationManager *locationManager;
    UIBarButtonItem *addButton;
	
	User *user;
	RKObjectManager *objectManager;
	NSArray *data;
	
}

@property (nonatomic, retain) NSArray *eventsArray;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;	    
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) RKObjectManager *objectManager;


- (void)addEvent;
- (IBAction)add;
- (IBAction)refresh;

@end
