//
//  PostListCell.m
//  quanmeiti
//
//  Created by Chen Dong on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CDPostListTableViewCell.h"

static const CGFloat THUMBNAIL_VIEW_WIDTH = 65.0;
static const CGFloat THUMBNAIL_VIEW_HEIGHT = 50.0;
static const CGFloat CELL_PADDING = 5.0;
static const CGFloat TITLE_LABEL_HEIGHT = 26.0;
static const CGFloat DATE_LABEL_HEIGHT = 24.0;
static const CGFloat COUNT_LABEL_WIDTH = 80.0;

@implementation CDPostListTableViewCell

@synthesize titleLabel;
@synthesize dateLabel;
@synthesize countLabel;
@synthesize thumbnailView;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        self.dateLabel = [[[UILabel alloc] init] autorelease];
        self.countLabel = [[[UILabel alloc] init] autorelease];
        self.thumbnailView = [[[UIImageView alloc] init] autorelease];
        
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:countLabel];
        [self.contentView addSubview:thumbnailView];
        
        
        
    }
    return self;
}

- (void) dealloc
{
    [titleLabel release];
    [dateLabel release];
    [countLabel release];
    [thumbnailView release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.1];
    
    CGFloat cellWidth = self.contentView.frame.size.width;
    
    CGFloat titleLabelWidth = cellWidth - CELL_PADDING * 2;
    if (thumbnailView.image != nil) {
        CGFloat thumbnailViewX = cellWidth - CELL_PADDING - THUMBNAIL_VIEW_WIDTH;
        thumbnailView.frame = CGRectMake(thumbnailViewX, CELL_PADDING, THUMBNAIL_VIEW_WIDTH, THUMBNAIL_VIEW_HEIGHT);
        titleLabelWidth = cellWidth - THUMBNAIL_VIEW_WIDTH - CELL_PADDING * 2;
    }
    
    titleLabel.frame = CGRectMake(CELL_PADDING, CELL_PADDING, titleLabelWidth, TITLE_LABEL_HEIGHT);
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat dateLabelWidth = titleLabelWidth - COUNT_LABEL_WIDTH - CELL_PADDING;
    CGFloat dateLabelY = self.contentView.frame.size.height - DATE_LABEL_HEIGHT;
    dateLabel.frame = CGRectMake(CELL_PADDING, dateLabelY,  dateLabelWidth, DATE_LABEL_HEIGHT);
    dateLabel.font = [UIFont systemFontOfSize:14.0];
    dateLabel.textColor = [UIColor lightGrayColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat countLabelX = dateLabelWidth + CELL_PADDING;
    countLabel.frame = CGRectMake(countLabelX, dateLabelY,  COUNT_LABEL_WIDTH, DATE_LABEL_HEIGHT);
    countLabel.font = [UIFont systemFontOfSize:14.0];
    countLabel.textColor = [UIColor lightGrayColor];
    countLabel.textAlignment = UITextAlignmentRight;
    countLabel.backgroundColor = [UIColor clearColor];
    
    
    thumbnailView.contentMode = UIViewContentModeScaleToFill;
    thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

@end


