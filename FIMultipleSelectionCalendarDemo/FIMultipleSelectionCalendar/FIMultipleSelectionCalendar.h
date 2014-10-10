//
//  FIMultipleSelectionCalendar.h
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 04.10.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#ifndef FIMultipleSelectionCalendarView_FIMultipleSelectionCalendar_h
#define FIMultipleSelectionCalendarView_FIMultipleSelectionCalendar_h
#import "FIMultipleSelectionCalendarView.h"
#import "FIMultipleSelectionCalendarViewCell.h"
#import "FIMultipleSelectionCalendarViewFlowLayout.h"
#import "FIMultipleSelectionCalendarViewHeader.h"


#pragma mark - DEFINES

//Day cells
#define dayCell_BackgroundColor [UIColor clearColor]
#define dayCell_LabelDefaultColor [UIColor clearColor]
#define dayCell_LabelSelectedColor [UIColor redColor]
#define dayCell_labelFontDefault [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f]
#define dayCell_labelFontSelected [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f]
#define dayCell_labelTextColorDefault [UIColor blackColor]
#define dayCell_labelTextColorSelected [UIColor whiteColor]
#define dayCell_markViewColorSelected [UIColor redColor]
#define dayCell_markViewColorNonSelected [UIColor grayColor]
//#define dayCell_superMarkViewColor [UIColor redColor]



#define dayCell_todayDateColor [[UIColor greenColor]colorWithAlphaComponent:0.5f]

//Calendar
#define calendar_BackgroundColor [UIColor whiteColor]

//Header
#define headerView_BackgroundColor [UIColor clearColor]
#define headerView_Font [UIFont fontWithName:@"HelveticaNeue-Light" size:19]
#define headerView_TextColor [UIColor orangeColor]
#define headerView_StripeColor [UIColor orangeColor]






#pragma mark - DEBUG

#if DEBUG
    #define DLog( s, ... ) NSLog( @"<%@> %@",  [[NSString stringWithUTF8String:__FILE__] lastPathComponent], [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
    #define DLog( s, ... )
#endif

#warning TO DO TransitionLayouts, animated bounds change
#endif
