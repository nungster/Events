//
//  EventCD.m
//  fish
//
//  Created by Yoshi on 11/15/12.
//
//

#import "EventCD.h"
#import "Photo.h"

#import "UIImageToDataTransformer.h"

@implementation EventCD

@synthesize eventId;
@synthesize name;
@synthesize amount;
@synthesize updatedAt;
@synthesize createdAt;

@dynamic creationDate, latitude, longitude, thumbnail, photo;
@dynamic airTemp;


+ (void)initialize {
	if (self == [EventCD class]) {
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
	
	[super dealloc];
}

@end

