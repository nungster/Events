
/*
     File: RootViewController.m
 Abstract: The table view controller responsible for displaying the list of events, supporting additional functionality:
 * Addition of new new events;
 * Deletion of existing events using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.
 
  
 */

#import "RootViewController.h"
#import "LocationsAppDelegate.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "UpdatesTableViewCell.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "User.h"
#import "NBEventManager.h"


@interface RootViewController ()
- (void)fetchRemoteEvents;
- (UIBarButtonItem *)newAddButton;
- (void)showEvent:(Event *)event;
- (void)deleteRowsAtIndexPaths:(NSArray *)array;
- (void)destroyRemoteGoalAtIndexPath:(NSIndexPath *)indexPath;
@end


@implementation RootViewController


@synthesize eventsArray, managedObjectContext, addButton, locationManager;
@synthesize objectManager;
@synthesize user, data;

#pragma mark -
#pragma mark View lifecycle
- (User *)user {
    if (user == nil) {
        //NSURL *url = [NSURL URLWithString:[ObjectiveResourceConfig getSite]];
        self.user = [User currentUserForSite:gBaseURL];
        [user addObserver:self];
    }
    return user;
}


- (void)viewDidLoad {
	LocationsAppDelegate *appDelegate = (LocationsAppDelegate *)[[UIApplication sharedApplication] delegate];
	managedObjectContext = [appDelegate managedObjectContext];
		
    [super viewDidLoad];
	// Set debug logging level. Set to 'RKLogLevelTrace' to see JSON payload
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
	
	
	// Set the title.
    self.title = @"Fishn";
    self.tableView.separatorColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"carbonfiber.jpg"]];
	
	// Configure the add and edit buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    /*
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
	addButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = addButton;
	*/
	// create a toolbar where we can place some buttons
	UIToolbar* toolbar = [[UIToolbar alloc]
						  initWithFrame:CGRectMake(0, 0, 100, 45)];
	[toolbar setBarStyle: UIBarStyleBlackOpaque];
	// create an array for the buttons
	NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
	// create a standard refresh button
	UIBarButtonItem *add2Button = [[UIBarButtonItem alloc]
									  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
									  target:self
									  action:@selector(addEvent)];
	add2Button.style = UIBarButtonItemStyleBordered;
	[buttons addObject:add2Button];
	[add2Button release];
	// create a spacer between the buttons
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
							   target:nil
							   action:nil];
	[buttons addObject:spacer];
	
	// create a standard refresh button
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
								   target:self
								   action:@selector(refresh)];
	refreshButton.style = UIBarButtonItemStyleBordered;
	[buttons addObject:refreshButton];
	[refreshButton release];
	
	/****************************  Extra navbar items **********************
	// create a spacer between the buttons
	[buttons addObject:spacer];
	[spacer release];
	// create a standard delete button with the trash icon
	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
									 target:self
									 action:@selector(deleteAction:)];
	deleteButton.style = UIBarButtonItemStyleBordered;
	[buttons addObject:deleteButton];
	[deleteButton release];
	**********************/
	
	// put the buttons in the toolbar and release them
	[toolbar setItems:buttons animated:NO];
	[buttons release];

	// place the toolbar into the navigation bar
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithCustomView:toolbar] autorelease];
	[toolbar release];
	
	
	self.navigationController.navigationBar.tintColor = [UIColor blackColor]; 
	 
	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
	
	/***************************************************
	 Fetch existing events.
	 Create a fetch request, add a sort descriptor, then execute the fetch.
	 ***************************************************/
	
	NSFetchRequest *frequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
	[frequest setEntity:entity];
	
	// Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[frequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *error = nil;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:frequest error:&error] mutableCopy];
	if (mutableFetchResults == nil) {
		// Handle the error.
	}
	
	[frequest release];

	// Set self's events array to the mutable array, then clean up.
	//self.eventsArray = data;
	//[self setEventsArray:mutableFetchResults];
	[mutableFetchResults release];
	//[request release];
	
/*
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    NSError *error = nil;
	
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert([[self.fetchedResultsController fetchedObjects] count], @"Seeding didn't work...");
    if (! fetchSuccessful) {
		
     }
 */
	NSLog(@"RVC %@ - %@", appDelegate.user.login, appDelegate.user.password);
	[[NBEventManager sharedManager] setUsername:appDelegate.user.login andPassword:appDelegate.user.password];
	
	[RKObjectManager sharedManager].HTTPClient = [NBEventManager sharedManager];
	
	/*
	[[NBEventManager sharedManager] getPath:@"/events.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
	    self.eventsArray = (NSArray *)[responseObject objectForKey:@"events"];
	//	NSLog(@"JSON");
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		// error stuff here
	}];
*/
    [self loadData];


}

- (void)loadData
{
    // Load the object model via RestKit
    [[RKObjectManager sharedManager] getObjectsAtPath:@"events.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        RKLogInfo(@"Load complete: Table should refresh...");
		NSLog(@"It worked: %@", [mappingResult array]);
		
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"updatedAt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
		
    }];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}


- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.eventsArray = nil;
	self.locationManager = nil;
	self.addButton = nil;
}

- (void)configureRestKit {
#if TARGET_IPHONE_SIMULATOR
	gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
#else
	gBaseURL = [[NSURL alloc] initWithString:@"http://localhost:3000"];
#endif
	//self.user.login = @"user@example.com";
	//self.user.password = @"please";

}

- (void)sendRequest
{
 	//[objectManager loadObjectsAtResourcePath:@"/events.json" delegate:self];
}


#pragma mark -
#pragma mark Object Loader RestKit Stuff
/*
- (void)objectLoader:(RKManagedObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if ([request isGET]) {
        if ([response isOK]) {
            NSLog(@"Data returned: %@", [response bodyAsString]);
        }
    } else if ([request isPOST]) {
        if ([response isJSON]) {
            NSLog(@"POST returned a JSON response");
        }
    } else if ([request isDELETE]) {
        if ([response isNotFound]) {
            NSLog(@"Resource '%@' not exists", [request resourcePath]);
        }
    }
}


- (void)objectLoader:(RKManagedObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"Number of objects [%d]", [objects count]);
    data = objects;
	self.eventsArray = objects;
    [self.tableView reloadData];
}
*/


#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// As many rows as there are obects in the events array.
    return [eventsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		//[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		//[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateFormat:@"dd-MMM-yyyy"];
	}
		
    static NSString *CellIdentifier = @"CustomCell";
/* Standard cell format
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
*/
	UpdatesTableViewCell *cell = (UpdatesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"UpdatesTableViewCell" owner:nil options:nil];
        
        for (UIView *view in views) {
            if([view isKindOfClass:[UITableViewCell class]])
            {
                cell = (UpdatesTableViewCell*)view;
            }
        }
    }

	// Get the event corresponding to the current index path and configure the table view cell.
	//eventsArray = (NSMutableArray *)data;
	Event *event = [eventsArray objectAtIndex:indexPath.row];
	
	//cell.textLabel.text = [dateFormatter stringFromDate:[event creationDate]];
	//cell.textLabel.text = [NSString stringWithFormat:@"Lat: %d Long: %d", [event latitude],[event longitude]];
	static NSNumberFormatter *numberFormatter;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	NSString *coordinatesString = [[NSString alloc] initWithFormat:@"Lat:%@, Lon:%@",
								   [numberFormatter stringFromNumber:[event latitude]],
								   [numberFormatter stringFromNumber:[event longitude]]];
	
	cell.cellTitle.text = coordinatesString;
	[coordinatesString release];

	cell.cellDate.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[event createdAt]]];
	cell.cellName.text = event.name;
	//cell.detailTextLabel.numberOfLines = 2;
	//cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
	
	//cell.cellImage.image = event.thumbnail;
    
	return cell;
}

- (void)destroyRemoteGoalAtIndexPath:(NSIndexPath *)indexPath {
    //Event *event = [eventsArray objectAtIndex:indexPath.row];
    NSError *error = nil;
    BOOL destroyed = YES; //[event destroyRemoteWithResponse:&error];
    if (destroyed == YES) {
        [eventsArray removeObjectAtIndex:indexPath.row];
        [self performSelectorOnMainThread:@selector(deleteRowsAtIndexPaths:)
                               withObject:[NSArray arrayWithObject:indexPath]
                            waitUntilDone:NO];
    } else {
        [AppHelpers handleRemoteError:error];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)deleteRowsAtIndexPaths:(NSArray *)array {
    [self.tableView deleteRowsAtIndexPaths:array
                     withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	EventDetailViewController *inspector = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];
	inspector.event = [eventsArray objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:inspector animated:YES];
	[inspector release];
}


/**
 Handle deletion of an event.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        // Delete the managed object at the given index path.
		NSManagedObject *eventToDelete = [eventsArray objectAtIndex:indexPath.row];
		[managedObjectContext deleteObject:eventToDelete];
		
		// Update the array and table view.
        [eventsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		// Commit the change.
		NSError *error = nil;
		if (![managedObjectContext save:&error]) {
			// Handle the error.
		}
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

#pragma mark -
#pragma mark Actions

- (IBAction)add {
    Event *event = [[Event alloc] init];
    EventDetailViewController *controller =
	[[EventDetailViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    [event release];
}

- (IBAction)refresh {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self fetchRemoteEvents];
    //[[ConnectionManager sharedInstance] runJob:@selector(fetchRemoteEvents)
    //                                  onTarget:self];
}

#pragma mark -
#pragma mark Add an event

/**
 Add an event.
 */
- (void)addEvent {
	
	// If it's not possible to get a location, then return.
	CLLocation *location = [locationManager location];
	if (!location) {
		return;
	}
	
	/*
	 Create a new instance of the Event entity.
	 */
	Event *event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
	
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
	[event setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
	[event setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
	
	// Should be timestamp, but this will be constant for simulator.
	// [event setCreationDate:[location timestamp]];
	[event setCreationDate:[NSDate date]];
	
	// Commit the change.
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	/*
	 Since this is a new event, and events are displayed with most recent events at the top of the list,
	 add the new event to the beginning of the events array; then redisplay the table view.
	 */
    [eventsArray insertObject:event atIndex:0];
    [self.tableView reloadData];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    addButton.enabled = NO;
}

#pragma mark -
#pragma mark Private methods

- (void)fetchRemoteEvents {
	
    NSError *error = nil;
	
    //self.eventsArray = [Event findAllRemoteWithResponse:&error];
	//NSLog(@"^^^^^ %@", self.eventsArray);
    
	
	if (self.eventsArray == nil && error != nil) {
        [AppHelpers handleRemoteError:error];
    }
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	Event *anEvent = [eventsArray objectAtIndex:0];
	NSLog(@"Remote Name - %@", anEvent.name);
}


- (void)showEvent:(Event *)event {
	EventDetailViewController *controller =
	[[EventDetailViewController alloc] initWithEvent:event];
	[self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (UIBarButtonItem *)newAddButton {
    return [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
			target:self
			action:@selector(add)];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[managedObjectContext release];
	[eventsArray release];
    [locationManager release];
    [addButton release];
    [super dealloc];
}


@end

