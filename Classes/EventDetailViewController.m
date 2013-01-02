
/*
     File: EventDetailViewController.m
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 

 
 */

#import "EventDetailViewController.h"
#import "Event.h"
#import "Photo.h"
#import "GDataXMLNode.h"

@implementation EventDetailViewController

@synthesize event, timeLabel, coordinatesLabel, deletePhotoButton, photoImageView;
@synthesize takePhoto;
@synthesize airTempTV;

#pragma mark -
#pragma mark Lifecycle
- (id)initWithEvent:(Event *)anEvent {
	if (self = [super init]) {
        self.event = anEvent;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"carbonfiber.jpg"]];
	
	// A date formatter for the creation date.
    static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	}
	
	static NSNumberFormatter *numberFormatter;
	if (numberFormatter == nil) {
		numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setMaximumFractionDigits:3];
	}
	
	timeLabel.text = [dateFormatter stringFromDate:[event createdAt]];
	
	NSString *coordinatesString = [[NSString alloc] initWithFormat:@"%@, %@",
							 [numberFormatter stringFromNumber:[event latitude]],
							 [numberFormatter stringFromNumber:[event longitude]]];
	coordinatesLabel.text = coordinatesString;
	[coordinatesString release];
	
	[self updatePhotoInfo];
	[self getWeatherData:@"lat/lon"];
}


- (void)viewDidUnload {
	
	self.timeLabel = nil;
	self.coordinatesLabel = nil;
	self.deletePhotoButton = nil;
	self.photoImageView = nil;
}

-(void)getWeatherData:(NSString *)text
{
	NSLog(@"getWeatherData ********************** %@", text);
	// Build the string to call the NWS
	NSString *urlString = [NSString stringWithFormat:@"http://www.weather.gov/xml/current_obs/KPIE.xml"];
	
	// Create NSURL string from formatted string
	NSURL *url = [NSURL URLWithString:urlString];
	
	// Setup and start async download
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection release];
	[request release];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	/* JSON method
	// Store incoming data into a string
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	// Create a dictionary from the JSON string
	NSDictionary *results = [jsonString JSONValue];
	
	NSLog(@"%@", results);
	*/
	// Store incoming data into a string
	NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	NSLog(@"xmlString ****************\n%@", xmlString);
	NSLog(@"\n\nEEEEEEEEEEEENNNNNNNNNNNNNNDDDDDDDDDDD");
	NSError *error;
	// Create a dictionary from the XML string
	GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:&error];
	if (doc == nil) { return; }
	
    NSLog(@"\n**** GDATAXMLDOC ****\n%@", doc.rootElement);
	
	//Start parsing
	//NSArray *weather = [doc nodesForXPath:@"//students/student" error:nil];

	NSArray *temperatureF = [doc nodesForXPath:@"//current_observation/temp_f" error:nil];
	NSLog(@"\n^^^^^ got airTemp out of xml = %@ ^^^^^^\n", [temperatureF objectAtIndex:0]);

	
	GDataXMLElement *tempF = (GDataXMLElement *) [temperatureF objectAtIndex:0];
	NSLog(@"**** %d", tempF.stringValue.intValue);

	[event setAirTemp:[NSNumber numberWithInt:tempF.stringValue.intValue]];
	airTempTV.text = [NSString  stringWithFormat:@"%@", event.airTemp];
	
	NSLog(@"\n^^^^^ airTemp = %@",event.airTemp);
	
    [doc release];
    [xmlString release];

	
	// Build an array from the dictionary for easy access to each entry
	//NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
	
	// Loop through each entry in the dictionary...
	//for (NSDictionary *photo in photos)
	//{
		// Get title of the image
	//	NSString *title = [photo objectForKey:@"title"];
		
		// Save the title to the photo titles array
		//[photoTitles addObject:(title.length > 0 ? title : @"Untitled")];
		
		//debug(@"photoURLsLareImage: %@\n\n", photoURLString); 
	//}
	
}

#pragma mark -
#pragma mark Editing the photo

- (IBAction)deletePhoto {
	
	/*
	 If the event already has a photo, delete the Photo object and dispose of the thumbnail.
	 Because the relationship was modeled in both directions, the event's relationship to the photo will automatically be set to nil.
	 */
	
	NSManagedObjectContext *context = event.managedObjectContext;
	[context deleteObject:event.photo];
	event.thumbnail = nil;
	
	// Commit the change.
	NSError *error = nil;
	if (![event.managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];
}


- (IBAction)choosePhoto {
	
	// Show an image picker to allow the user to choose a new photo.
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	[imagePicker release];
}



- (void)updatePhotoInfo {
	
	// Synchronize the photo image view and the text on the photo button with the event's photo.
	UIImage *image = event.photo.image;

	photoImageView.image = image;
	if (image) {
		deletePhotoButton.enabled = YES;
	}
	else {
		deletePhotoButton.enabled = NO;
	}
}

-(IBAction) getPhoto:(id) sender {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	
	if((UIButton *) sender == takePhoto) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}
	
	[self presentModalViewController:picker animated:YES];
}


#pragma mark -
#pragma mark Image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editingInfo {
	
	NSManagedObjectContext *context = event.managedObjectContext;

	// If the event already has a photo, delete it.
	if (event.photo) {
		[context deleteObject:event.photo];
	}
	
	// Create a new photo object and set the image.
	Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
	photo.image = [editingInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	// Associate the photo object with the event.
	event.photo = photo;	
	[self processImage:photo.image];
	
	// Create a thumbnail version of the image for the event object.
	CGSize size = photo.image.size;
	CGFloat ratio = 0;
	if (size.width > size.height) {
		ratio = 44.0 / size.width;
	}
	else {
		ratio = 44.0 / size.height;
	}
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	
	UIGraphicsBeginImageContext(rect.size);
	[photo.image drawInRect:rect];
	//event.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Commit the change.
	NSError *error = nil;
	if (![event.managedObjectContext save:&error]) {
		// Handle the error.
	}
	
	// Update the user interface appropriately.
	[self updatePhotoInfo];

    [self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

-(void)processImage:(UIImage *)image {
	[image retain];
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}


- (void)image:(UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
	NSLog(@"SAVE IMAGE COMPLETE");
	if(error != nil) {
		NSLog(@"ERROR SAVING:%@",[error localizedDescription]);
	}
	[image autorelease];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[event release];
	[timeLabel release];
	[coordinatesLabel release];
	[deletePhotoButton release];
	[photoImageView release];

    [super dealloc];
}


@end
