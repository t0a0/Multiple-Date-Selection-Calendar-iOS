//
//  FIMultipleSelectionCalendarViewHeader.m
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 03.10.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import "FIMultipleSelectionCalendarViewHeader.h"
#import "FIMultipleSelectionCalendar.h"
@interface FIMultipleSelectionCalendarViewHeader ()
@property (strong,nonatomic) UILabel* monthNameLabel;
@property (strong,nonatomic) UIView* stripeView;
@end
@implementation FIMultipleSelectionCalendarViewHeader
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        if(!self.stripeView)
        {
            CGFloat stripeHeight = 0.5f;
            self.stripeView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height*0.9f-stripeHeight, frame.size.width, stripeHeight)];
            self.stripeView.backgroundColor = headerView_StripeColor;
            [self addSubview:self.stripeView];
        }
    }
    return self;
}

-(UILabel*)monthNameLabel
{
    if(!_monthNameLabel)
    {
        _monthNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width*0.98f, self.frame.size.height)];
        _monthNameLabel.backgroundColor = headerView_BackgroundColor;
        _monthNameLabel.textAlignment = NSTextAlignmentRight;
        _monthNameLabel.font = headerView_Font;
        _monthNameLabel.textColor = headerView_TextColor;
        [self addSubview:_monthNameLabel];
    }
    return _monthNameLabel;
}
-(void)prepareForReuse
{
    self.monthNameLabel.text = nil;
}
-(void)setHeaderTitle:(NSString *)headerTitle
{
    _headerTitle = headerTitle;
    self.monthNameLabel.text = headerTitle;
}
@end
