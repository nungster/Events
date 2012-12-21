//
//  EventCD.h
//  fish
//
//  Created by Yoshi on 11/15/12.
//
//


@class Photo;

@interface EventCD : NSManagedObject  {
	
    NSString *eventId;
    NSString *name;
    NSString *amount;
    NSDate   *updatedAt;
    NSDate   *createdAt;
	NSNumber	*latitude;
	NSNumber	*longitude;
	NSNumber	*airTemp;
}

@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *airTemp;

@property (nonatomic, retain) UIImage *thumbnail;

@property (nonatomic, retain) Photo *photo;


@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *createdAt;


@end
