//
//  UpdatesTableViewCell.m
//  UpdatesListView
//
//  Created by Tope on 10/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UpdatesTableViewCell.h"

@implementation UpdatesTableViewCell

@synthesize cellTitle, cellDate;
@synthesize cellImage, cellName;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
