//
//  UpdatesTableViewCell.h
//  UpdatesListView
//
//  Created by Tope on 10/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatesTableViewCell : UITableViewCell {
	IBOutlet UILabel *cellTitle;
	IBOutlet UILabel *cellDate;
	IBOutlet UITextView *cellName;
	IBOutlet UIImageView *cellImage;
}

@property(nonatomic, retain) IBOutlet UILabel *cellTitle;
@property(nonatomic, retain) IBOutlet UILabel *cellDate;
@property(nonatomic, retain) IBOutlet UITextView *cellName;

@property(nonatomic, retain) IBOutlet UIImageView *cellImage;

@end
