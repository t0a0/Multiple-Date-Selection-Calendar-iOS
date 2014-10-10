//
//  FIMultipleSelectionCalendarViewCell.m
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 30.09.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import "FIMultipleSelectionCalendarViewCell.h"
#import "FIMultipleSelectionCalendar.h"

@interface FIMultipleSelectionCalendarViewCell ()
@property (strong,nonatomic) UILabel* dayLabel;
@property (strong,nonatomic) UIView* markView;
@end
@implementation FIMultipleSelectionCalendarViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.contentView.backgroundColor = dayCell_BackgroundColor;
//        [self addConstrs];
    }
    return self;
}
-(UILabel*)dayLabel
{
    if(!_dayLabel)
    {
        _dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width*0.8f, self.contentView.frame.size.width*0.8f)];
        _dayLabel.center = CGPointMake(self.contentView.frame.size.width/2, (_dayLabel.frame.size.height/2)*1.2);
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = dayCell_LabelDefaultColor;
        _dayLabel.font = dayCell_labelFontDefault;
        _dayLabel.textColor = dayCell_labelTextColorDefault;
        _dayLabel.layer.masksToBounds = YES;
        _dayLabel.layer.shouldRasterize = YES;
        _dayLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:_dayLabel];
    }
    return _dayLabel;
}
-(UIView*)markView
{
    if(!_markView)
    {
        _markView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width*0.15, self.contentView.frame.size.width*0.15)];
        _markView.center = CGPointMake(self.contentView.frame.size.width/2, (self.dayLabel.frame.size.height/2)+self.dayLabel.center.y+self.markView.frame.size.height/2 + self.contentView.frame.size.height*0.1);
        _markView.layer.cornerRadius = self.markView.frame.size.width/2;
        _markView.layer.shouldRasterize = YES;
        _markView.layer.masksToBounds = YES;
        _markView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        [self.contentView addSubview:self.markView];
    }
    return _markView;
}
-(void)prepareForReuse
{
    self.dayLabel.text = nil;
    self.attachedDate = nil;
    [self setDateSelected:NO];
    [self setMarkType:FIMSCCellMarkTypeNone];
    [self setToday:NO];
}
-(void)setAttachedDate:(NSDate *)attachedDate
{
    _attachedDate = attachedDate;
    if(attachedDate)
    {
        static NSDateFormatter* dateFormatter = nil;
        if(!dateFormatter)
        {
            dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"d"];
        }
        self.dayLabel.text = [dateFormatter stringFromDate:attachedDate];
    }
    else
    {
        self.dayLabel.text = nil;
    }
}
-(void)setDateSelected:(BOOL)dateSelected
{
    _dateSelected = dateSelected;
    [self update];
}
-(void)setMarkType:(FIMSCCellMarkType)markType
{
    _markType = markType;
    if(_markType)
    {
        self.markView.backgroundColor = [self colorForMarkType:_markType];
    }
    else
    {
        [self.markView removeFromSuperview];
        self.markView = nil;
    }
}
-(void)setToday:(BOOL)today
{
    _today = today;
    [self update];
}
-(void)update
{
    if(self.dateSelected)
    {
        self.dayLabel.backgroundColor = dayCell_LabelSelectedColor;
        self.dayLabel.layer.cornerRadius = (self.dayLabel.frame.size.width/2);
        self.dayLabel.font = dayCell_labelFontSelected;
        self.dayLabel.textColor = dayCell_labelTextColorSelected;
    }
    else
    {
        if(self.today)
        {
            self.dayLabel.backgroundColor = dayCell_todayDateColor;
            self.dayLabel.layer.cornerRadius = (self.dayLabel.frame.size.width/2);
            self.dayLabel.textColor = dayCell_labelTextColorSelected;
            self.dayLabel.font = dayCell_labelFontSelected;
        }
        else
        {
            self.dayLabel.backgroundColor = dayCell_LabelDefaultColor;
            self.dayLabel.layer.cornerRadius = 0;
            self.dayLabel.textColor = dayCell_labelTextColorDefault;
            self.dayLabel.font = dayCell_labelFontDefault;
        }
    }
}
#pragma mark - Mark Colors
-(UIColor*)colorForMarkType:(FIMSCCellMarkType)markType
{
    switch (markType) {
        case FIMSCCellMarkType1:
            return [UIColor grayColor];
        case FIMSCCellMarkType2:
            return [UIColor redColor];
        default:
            return nil;
    }
}
#pragma mark - Constraints
-(void)addConstrs
{
    [self.dayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.dayLabel
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeTop
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.height*0.1]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.dayLabel
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0f
                                   constant:0]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.dayLabel
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.width*0.8]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.dayLabel
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.width*0.8]];
    
    [self.markView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.markView
                                  attribute:NSLayoutAttributeTop
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.dayLabel
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.height*0.1]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.markView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0f
                                   constant:0]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.markView
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.width*0.15]];
    [self.contentView addConstraint:
     [NSLayoutConstraint constraintWithItem:self.markView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0f
                                   constant:self.contentView.frame.size.width*0.15]];
}
@end
