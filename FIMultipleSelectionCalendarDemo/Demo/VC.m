//
//  VC.m
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 03.10.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import "VC.h"
#import "FIMultipleSelectionCalendarView.h"
@interface VC () <FIMultipleSelectionCalendarViewDelegate>
@end
@implementation VC
-(void)viewDidLoad
{
    [super viewDidLoad];
    NSCalendar* cal = [NSCalendar currentCalendar];
    FIMultipleSelectionCalendarView* view = [[FIMultipleSelectionCalendarView alloc]initWithFrame:self.view.frame calendar:cal singleSelectionOnly:YES];
    view.calViewDelegate = self;
    [self.view addSubview:view];
    
    NSDate* nowDate = [NSDate date];
//    [view markDate:[nowDate dateByAddingTimeInterval:24*60*60*3] withType:1];
//    [view markDate:[nowDate dateByAddingTimeInterval:24*60*60*7]withType:2];
//
//    [view markDate:[nowDate dateByAddingTimeInterval:24*60*60*9]withType:1];
//    
//    [view markDate:[nowDate dateByAddingTimeInterval:24*60*60*17]withType:2];
//    [view markDate:[nowDate dateByAddingTimeInterval:24*60*60*18]withType:1];

    NSMutableSet* ray = [NSMutableSet new];
    for (NSInteger i = 0; i < 500; i++)
    {
        [ray addObject:[nowDate dateByAddingTimeInterval:24*60*60*i]];
    }
    [view markDates:ray withType:1];

}
-(BOOL)calendarView:(FIMultipleSelectionCalendarView *)calView shouldSelectDate:(NSDate *)date
{
    return YES;
}
-(BOOL)calendarView:(FIMultipleSelectionCalendarView*)calView shouldDeselectDate:(NSDate*)date
{
    return YES;
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
