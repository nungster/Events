
/*
     File: Event.m
 Abstract: A Core Data managed object class to represent an event containing geographical coordinates, a time stamp, and a thumbnail image. An event has a to-one relationship to Photograph. The thumbnail image is stored as a transformable attribute using UIImageToDataTransformer. 
 

 
 */

#import "Event.h"
#import "Photo.h"

#import "UIImageToDataTransformer.h"

@implementation Event 

@dynamic eventId;
@dynamic name;
@dynamic amount;
@dynamic updatedAt;
@dynamic createdAt;
@dynamic latitude, longitude, airTemp, length;
@dynamic thumbnail, photo;


+ (void)initialize {
	if (self == [Event class]) {
		UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [eventId release];
    [name release];
    [amount release];
    [updatedAt release];
    [createdAt release];
	[longitude release];
	[latitude release];
	[airTemp release];
	[length release];
	[thumbnail release];
	
	[super dealloc];
}

@end

