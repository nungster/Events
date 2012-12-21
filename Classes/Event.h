
/*
     File: Event.h
 Abstract: A Core Data managed object class to represent an event containing geographical coordinates, a time stamp, and a thumbnail image. An event has a to-one relationship to Photograph. The thumbnail image is stored as a transformable attribute using UIImageToDataTransformer. 
 
 
 
 */

@class Photo;
@class RKManagedObjectMapping;

@interface Event : NSManagedObject  {

    NSNumber *eventId;
    NSString *name;
    NSString *amount;
    NSDate   *updatedAt;
    NSDate   *createdAt;
	NSNumber	*latitude;
	NSNumber	*longitude;
	NSNumber	*airTemp;
	NSNumber	*length;
	UIImage *thumbnail;
}

@property (nonatomic, retain) UIImage *thumbnail;
//@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) Photo *photo;


@property (nonatomic, retain) NSNumber *eventId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *airTemp;
@property (nonatomic, retain) NSNumber *length;

@end

