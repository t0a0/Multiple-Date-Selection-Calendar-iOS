//
//  FIMultipleSelectionCalendarViewCell.h
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 30.09.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FIMSCCellMarkType)
{
    FIMSCCellMarkTypeNone,
    FIMSCCellMarkType1,
    FIMSCCellMarkType2
};

@interface FIMultipleSelectionCalendarViewCell : UICollectionViewCell

@property (nonatomic, getter=isDateSelected) BOOL dateSelected;

@property (nonatomic, strong) NSDate* attachedDate;

@property (nonatomic, getter=isToday) BOOL today;

@property (nonatomic) FIMSCCellMarkType markType;
@end
