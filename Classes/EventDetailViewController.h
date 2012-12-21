
/*
     File: EventDetailViewController.h
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
 
 */

@class Event;

@interface EventDetailViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	Event *event;
	UILabel *timeLabel;
	UILabel *coordinatesLabel;
	UITextField *airTempTV;
	UIButton *deletePhotoButton;
	UIButton *takePhoto;
	UIImageView *photoImageView;
}

@property (nonatomic, retain) Event *event;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *coordinatesLabel;
@property (nonatomic, retain) IBOutlet UITextField *airTempTV;
@property (nonatomic, retain) IBOutlet UIButton *deletePhotoButton;
@property (nonatomic, retain) IBOutlet UIButton *takePhoto;
@property (nonatomic, retain) IBOutlet UIImageView *photoImageView;

- (IBAction) choosePhoto;
- (IBAction) deletePhoto;
- (void) updatePhotoInfo;
- (IBAction) getPhoto:(id) sender;

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void) getWeatherData:(NSString *)text;
- (void) processImage:(UIImage *)image;

- (id)initWithEvent:(Event *)event;


@end
