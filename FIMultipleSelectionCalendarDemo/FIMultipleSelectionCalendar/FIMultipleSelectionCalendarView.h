//
//  FIMultipleSelectionCalendarView.h
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 30.09.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIMultipleSelectionCalendarViewCell.h"
@class FIMultipleSelectionCalendarView;
@protocol FIMultipleSelectionCalendarViewDelegate <NSObject>

@optional
//return YES if you want selected date to be added to selected dates
//return NO if you want to manually process it
-(BOOL)calendarView:(FIMultipleSelectionCalendarView*)calView shouldSelectDate:(NSDate*)date;
-(BOOL)calendarView:(FIMultipleSelectionCalendarView*)calView shouldDeselectDate:(NSDate*)date;


//-(void)calendarView:(FIMultipleSelectionCalendarView*)calView didSelectDate:(NSDate*)date successfully:(BOOL)success;
//-(void)calendarView:(FIMultipleSelectionCalendarView*)calView didUnselectDate:(NSDate*)date;
//
//-(void)calendarView:(FIMultipleSelectionCalendarView*)calView didMarkDate:(NSDate*)date successfully:(BOOL)success;
//
//-(void)calendarView:(FIMultipleSelectionCalendarView*)calView didUnmarkDate:(NSDate*)date;

@end


@interface FIMultipleSelectionCalendarView : UICollectionView

-(instancetype)initWithFrame:(CGRect)frame
                    calendar:(NSCalendar*)calendar
         singleSelectionOnly:(BOOL)singleSelection;

@property (weak,nonatomic) id <FIMultipleSelectionCalendarViewDelegate> calViewDelegate;

@property (nonatomic, getter=isSingleSelection) BOOL singleSelection;
-(NSDate*)currentFirstDate;
-(NSDate*)currentLastDate;

-(void)scrollToTodayAnimated:(BOOL)animate;

#pragma mark - select
-(void)selectDate:(NSDate*)date;
-(void)selectDates:(NSSet*)dates;
-(void)unselectDate:(NSDate*)date;
-(void)unselectDates:(NSSet*)dates;

#pragma mark - mark
-(void)markDate:(NSDate*)date withType:(FIMSCCellMarkType)markType;
-(void)markDates:(NSSet*)dates withType:(FIMSCCellMarkType)markType;
-(void)unmarkDate:(NSDate*)date;
-(void)unmarkDates:(NSSet*)dates;
-(void)unmarkAllDates;


@property (strong,nonatomic) NSMutableSet* selectedDates;
@property (strong,nonatomic) NSMutableDictionary* markedDates;//keys: 0,1,2,3 - mark types, values - mutable sets of dates

-(NSDate*)clearDateFromhhmmss:(NSDate*)date;

@end

