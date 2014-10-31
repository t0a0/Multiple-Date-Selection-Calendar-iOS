//
//  FIMultipleSelectionCalendarView.m
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 30.09.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import "FIMultipleSelectionCalendarView.h"
#import "FIMultipleSelectionCalendar.h"

//constants
const NSInteger sectionLimitBeforeLoadingMoreSections = 5; //meaning if we scroll up to that section we load more items at the beginning, and if we scroll down to numOfSections-thatNumber we load more items at the end.
const NSInteger numberOfSectionsToLoadUponReachingTheLimit = 10;
const NSCalendarUnit calendarUnitComponents = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday;

//KEYS
static NSString* monthSectionDictKey_NumOfDays = @"dk_numberOfDays";
static NSString* monthSectionDictKey_WeekDayOfTheFirstDay = @"dk_weekDayOf1Day";
static NSString* monthSectionDictKey_NumberOfItemsInSection = @"dk_numOfItemsInSection";
static NSString* monthSectionDictKey_RefDate = @"dk_refDate";

//Cells
static NSString* cellReuseID_DayCell = @"dayCell";

//ReusableViews
static NSString* viewReuseID_Header = @"headerReuseID";

@interface FIMultipleSelectionCalendarView () < UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong,nonatomic) NSCalendar* calendar;
@property (strong,nonatomic) NSMutableArray* monthsSections;
@property (strong,nonatomic) NSDateFormatter* monthHeaderFormatter;
@property (strong,nonatomic) NSDate* todayDate;

@property (nonatomic) BOOL isLoading;
@end

@implementation FIMultipleSelectionCalendarView

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(self.collectionViewLayout)
    {
        [((FIMultipleSelectionCalendarViewFlowLayout*)self.collectionViewLayout) setCVSize:frame.size];
    }
}
-(instancetype)initWithFrame:(CGRect)frame
                    calendar:(NSCalendar*)calendar
         singleSelectionOnly:(BOOL)singleSelection
{
    FIMultipleSelectionCalendarViewFlowLayout* flow =[[FIMultipleSelectionCalendarViewFlowLayout alloc]initWithCollectionViewSize:frame.size];
    if(self = [self initWithFrame:frame collectionViewLayout:flow])
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = calendar_BackgroundColor;
        [self registerClass:[FIMultipleSelectionCalendarViewCell class] forCellWithReuseIdentifier:cellReuseID_DayCell];
        [self registerClass:[FIMultipleSelectionCalendarViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:viewReuseID_Header];
        self.singleSelection = singleSelection;
        self.selectedDates = [NSMutableSet new];
        self.markedDates = [NSMutableDictionary new];
        self.calendar = calendar;
        self.monthsSections = [NSMutableArray new];
        NSDate* nowDate = [NSDate date];
        NSDateComponents* nowDateComponents = [calendar components:calendarUnitComponents fromDate:nowDate];
        self.todayDate = [self clearDateFromhhmmss:nowDate];
        NSDateComponents* comps = [[NSDateComponents alloc]init];
        [comps setYear:nowDateComponents.year];
        NSInteger todayWeekday = 1;
        for (NSInteger i = nowDateComponents.month ; i < nowDateComponents.month + 1; i ++)
        {
            [comps setMonth:i];
            [comps setDay:1];
            
            NSDate* date = [calendar dateFromComponents:comps];
            NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            NSDateComponents* weekDayComp = [calendar components:calendarUnitComponents fromDate:date];
            NSInteger weekDay = [self convertWeekDay:weekDayComp.weekday];
            
            if(nowDateComponents.year == weekDayComp.year && nowDateComponents.month == weekDayComp.month)
            {
                todayWeekday = weekDay;
            }
            
            NSInteger numberOfItemsInSection = range.length - 1 + weekDay;
            NSInteger mod = numberOfItemsInSection % 7;
            if(mod)
            {
                numberOfItemsInSection +=  7 - mod;
            }
            
            [self.monthsSections addObject:
             [NSDictionary dictionaryWithObjects:
              @[[NSNumber numberWithInteger:range.length],
                [NSNumber numberWithInteger:weekDay],
                [NSNumber numberWithInteger:numberOfItemsInSection],
                date]
                                         forKeys:
              @[monthSectionDictKey_NumOfDays,
                monthSectionDictKey_WeekDayOfTheFirstDay,
                monthSectionDictKey_NumberOfItemsInSection,
                monthSectionDictKey_RefDate]]];
        }
        
        [self loadNewMonthsAtTheBeginning:numberOfSectionsToLoadUponReachingTheLimit];
        [self loadNewMonthsAtTheEnd:numberOfSectionsToLoadUponReachingTheLimit];
        
        self.dataSource = self;
        self.delegate = self;
        
        NSInteger todayDayNumberInSection = nowDateComponents.day - 1 + [self convertWeekDay:todayWeekday]-1;
        NSIndexPath* scrollToIP = [NSIndexPath indexPathForItem:todayDayNumberInSection inSection:self.monthsSections.count/2];
        @try
        {
            [self scrollToItemAtIndexPath:scrollToIP atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
        @catch (NSException *exception)
        {
//            DLog(@"Caught an exception: %@",exception);
//            [Flurry logError:@"Calendar exception" message:@"In init : scrollToItem" exception:exception];
        }
        @finally
        {
            
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(significantTimeChangedOccured:) name:UIApplicationSignificantTimeChangeNotification object:nil];
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
}
#pragma mark - Time change notification
-(void)significantTimeChangedOccured:(NSNotification*)sender
{
    NSIndexPath* path1 = [self indexPathForDate:self.todayDate];
    self.todayDate = [self clearDateFromhhmmss:[NSDate date]];
    NSIndexPath* path2 = [self indexPathForDate:self.todayDate];
    NSMutableArray* array = [NSMutableArray new];
    if(path1)
    {
        [array addObject:path1];
    }
    if(path2)
    {
        [array addObject:path2];
    }
    [self reloadItemsAtIndexPaths:array];
}
#pragma mark - Date Formatters
-(NSDateFormatter*)monthHeaderFormatter
{
    if(!_monthHeaderFormatter)
    {
        _monthHeaderFormatter = [[NSDateFormatter alloc]init];
        [_monthHeaderFormatter setCalendar:self.calendar];
        [_monthHeaderFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy LLLL" options:0 locale:self.calendar.locale]];
    }
    return _monthHeaderFormatter;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.monthsSections.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary* sectionInfo = [self.monthsSections objectAtIndex:section];
    NSInteger numOfItems = [[sectionInfo objectForKey:monthSectionDictKey_NumberOfItemsInSection]integerValue];
    return numOfItems;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FIMultipleSelectionCalendarViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseID_DayCell forIndexPath:indexPath];
    NSDictionary* sectionInfo = [self.monthsSections objectAtIndex:indexPath.section];
    NSInteger numOfDays = [[sectionInfo objectForKey:monthSectionDictKey_NumOfDays]integerValue];
    NSInteger weekDay = [[sectionInfo objectForKey:monthSectionDictKey_WeekDayOfTheFirstDay]integerValue];
    NSDate* refDate = [sectionInfo objectForKeyedSubscript:monthSectionDictKey_RefDate];
    if(indexPath.row + 1 >= weekDay && indexPath.row + 1 <= weekDay-1 + numOfDays)
    {
        NSDateComponents* comps = [self.calendar components:calendarUnitComponents fromDate:refDate];
        [comps setDay:indexPath.row + 2 - weekDay];
        [cell setAttachedDate:[self.calendar dateFromComponents:comps]];
        if([self.selectedDates containsObject:cell.attachedDate])
        {
            [cell setDateSelected:YES];
        }
        for(NSString* key in self.markedDates.allKeys)
        {
            NSMutableSet* set = self.markedDates[key];
            if([set containsObject:cell.attachedDate])
            {
                [cell setMarkType:key.integerValue];
            }
        }
        if([self.todayDate isEqualToDate:cell.attachedDate])
        {
            [cell setToday:YES];
        }
    }
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        FIMultipleSelectionCalendarViewHeader* view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:viewReuseID_Header forIndexPath:indexPath];
        NSDictionary* sectionInfo = [self.monthsSections objectAtIndex:indexPath.section];
        NSDate* refDate = [sectionInfo objectForKey:monthSectionDictKey_RefDate];
        [view setHeaderTitle:[[self.monthHeaderFormatter stringFromDate:refDate]uppercaseString]];
        return view;
    }
    return nil;
}
#pragma mark - Collection View Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate* selectedDate = [self dateForItemAtIndexPath:indexPath];
    DLog(@"User did tap on date: %@",[selectedDate descriptionWithLocale:[NSLocale currentLocale]]);
    if(selectedDate)
    {
        if([self.selectedDates containsObject:selectedDate])
        {
            if([self.calViewDelegate respondsToSelector:@selector(calendarView:shouldDeselectDate:)])
            {
                BOOL deselect = [self.calViewDelegate calendarView:self shouldDeselectDate:selectedDate];
                if(deselect)
                {
                    [self.selectedDates removeObject:selectedDate];
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }
        }
        else
        {
            if([self.calViewDelegate respondsToSelector:@selector(calendarView:shouldSelectDate:)])
            {
                BOOL select = [self.calViewDelegate calendarView:self shouldSelectDate:selectedDate];
                if(select)
                {
                    if(self.singleSelection)
                    {
                        [self unselectDates:self.selectedDates];
                    }
                    [self.selectedDates addObject:selectedDate];
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }
        }
    }
}
-(void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(!self.isLoading)
        {
            if(indexPath.section < sectionLimitBeforeLoadingMoreSections) // load @ beginning
            {
                self.isLoading = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self loadNewMonthsAtTheBeginning:numberOfSectionsToLoadUponReachingTheLimit];
                    NSIndexPath *oldIndexPath = self.indexPathsForVisibleItems[0];
                    CGRect before = [self layoutAttributesForItemAtIndexPath:oldIndexPath].frame;
                    CGPoint contentOffset = [self contentOffset];
                    [self reloadData];
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:oldIndexPath.row inSection:oldIndexPath.section + numberOfSectionsToLoadUponReachingTheLimit];
                    CGRect after = [self layoutAttributesForItemAtIndexPath:newIndexPath].frame;
                    contentOffset.y += (after.origin.y - before.origin.y);
                    
                    self.contentOffset = contentOffset;
                    self.isLoading = NO;
                });
            }
            else if(indexPath.section > collectionView.numberOfSections - sectionLimitBeforeLoadingMoreSections) // load @ end
            {
                self.isLoading = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self loadNewMonthsAtTheEnd:numberOfSectionsToLoadUponReachingTheLimit];
                    [self reloadData];
                    
                    self.isLoading = NO;
                });
                
            }
        }
    });
}
#pragma mark - UICollectionViewFlowLayoutDelegate
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat itemWidth = floorf(CGRectGetWidth(self.bounds) / 7);
//
//    return CGSizeMake(itemWidth, itemWidth*1.25);
//}
#pragma mark - Scroll View delegate

#pragma mark - Load months
-(void)loadNewMonthsAtTheBeginning:(NSInteger)count
{
    if(self.monthsSections.count)
    {
        NSDateComponents* nowDateComponents = [self.calendar components:calendarUnitComponents fromDate:[[self.monthsSections objectAtIndex:0]objectForKey:monthSectionDictKey_RefDate]];
        NSDateComponents* comps = [[NSDateComponents alloc]init];
        [comps setYear:nowDateComponents.year];
        for (NSInteger i = nowDateComponents.month-1; i >= nowDateComponents.month - count; i --)
        {
            [comps setMonth:i];
            [comps setDay:1];
            
            NSDate* date = [self.calendar dateFromComponents:comps];
            NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            NSDateComponents* weekDayComp = [self.calendar components:calendarUnitComponents fromDate:date];
            NSInteger weekDay = [self convertWeekDay:weekDayComp.weekday];
            
            NSInteger numberOfItemsInSection = range.length - 1 + weekDay;
            NSInteger mod = numberOfItemsInSection % 7;
            if(mod)
            {
                numberOfItemsInSection +=  7 - mod;
            }
            
            [self.monthsSections insertObject:
             [NSDictionary dictionaryWithObjects:
              @[[NSNumber numberWithInteger:range.length],
                [NSNumber numberWithInteger:weekDay],
                [NSNumber numberWithInteger:numberOfItemsInSection],
                date]
                                         forKeys:
              @[monthSectionDictKey_NumOfDays,
                monthSectionDictKey_WeekDayOfTheFirstDay,
                monthSectionDictKey_NumberOfItemsInSection,
                monthSectionDictKey_RefDate]]
                                      atIndex:0];
        }
    }
}
-(void)loadNewMonthsAtTheEnd:(NSInteger)count
{
    if(self.monthsSections.count)
    {
        NSDateComponents* nowDateComponents = [self.calendar components:calendarUnitComponents fromDate:[[self.monthsSections objectAtIndex:self.monthsSections.count-1]objectForKey:monthSectionDictKey_RefDate]];
        NSDateComponents* comps = [[NSDateComponents alloc]init];
        [comps setYear:nowDateComponents.year];
        for (NSInteger i = nowDateComponents.month+1; i <= nowDateComponents.month + count; i ++)
        {
            [comps setMonth:i];
            [comps setDay:1];
            
            NSDate* date = [self.calendar dateFromComponents:comps];
            NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
            NSDateComponents* weekDayComp = [self.calendar components:calendarUnitComponents fromDate:date];
            NSInteger weekDay = [self convertWeekDay:weekDayComp.weekday];
            
            NSInteger numberOfItemsInSection = range.length - 1 + weekDay;
            NSInteger mod = numberOfItemsInSection % 7;
            if(mod)
            {
                numberOfItemsInSection +=  7 - mod;
            }
            
            [self.monthsSections addObject:
             [NSDictionary dictionaryWithObjects:
              @[[NSNumber numberWithInteger:range.length],
                [NSNumber numberWithInteger:weekDay],
                [NSNumber numberWithInteger:numberOfItemsInSection],
                date]
                                         forKeys:
              @[monthSectionDictKey_NumOfDays,
                monthSectionDictKey_WeekDayOfTheFirstDay,
                monthSectionDictKey_NumberOfItemsInSection,
                monthSectionDictKey_RefDate]]];
        }
    }
}

#pragma mark - public methods
-(NSDate*)clearDateFromhhmmss:(NSDate *)date
{
    NSDateComponents* dateToSelectComps = [self.calendar components:calendarUnitComponents fromDate:date];
    return [self.calendar dateFromComponents:dateToSelectComps];
}
#pragma mark - Select dates
-(void)selectDate:(NSDate*)date
{
    if(self.singleSelection)
    {
        [self unselectDates:self.selectedDates];
    }
    NSDate* dateToSelect = [self clearDateFromhhmmss:date];
    [self.selectedDates addObject:dateToSelect];
    [self reloadItemsWithDates:@[dateToSelect]];
}
-(void)selectDates:(NSSet*)dates
{
    NSMutableArray* datesToUpdate = [NSMutableArray new];
    if(self.singleSelection)
    {
        [self unselectDates:self.selectedDates];
        NSDate* dateToUPD = dates.anyObject;
        [self selectDate:dateToUPD];
        [datesToUpdate addObject:dateToUPD];
    }
    else
    {
        for (NSDate* date in dates.allObjects)
        {
            NSDate* dateToSelect = [self clearDateFromhhmmss:date];
            [self.selectedDates addObject:dateToSelect];
            [datesToUpdate addObject:dateToSelect];
        }
    }
    [self reloadItemsWithDates:datesToUpdate];
}
-(void)unselectDate:(NSDate*)date
{
    NSDate* dateFromComps = [self clearDateFromhhmmss:date];
    [self.selectedDates removeObject:dateFromComps];
    [self reloadItemsWithDates:@[dateFromComps]];
}
-(void)unselectDates:(NSSet*)dates
{
    NSMutableArray* datesToUpdate = [NSMutableArray new];
    for (NSDate* date in dates.allObjects)
    {
        NSDate* dateToSelect = [self clearDateFromhhmmss:date];
        [self.selectedDates removeObject:dateToSelect];
        [datesToUpdate addObject:dateToSelect];
    }
    [self reloadItemsWithDates:datesToUpdate];
}
#pragma mark - mark dates
-(void)markDate:(NSDate*)date withType:(FIMSCCellMarkType)markType
{
    
    NSDate* dateFromComps = [self clearDateFromhhmmss:date];
    for(NSString* key in self.markedDates.allKeys)
    {
        NSMutableSet* set = self.markedDates[key];
        [set removeObject:dateFromComps];
    }
    NSMutableSet* newSet = [self.markedDates objectForKey:[self stringKeyForMarkType:markType]];
    if(!newSet)
    {
        newSet = [NSMutableSet new];
        [self.markedDates setObject:newSet forKey:[self stringKeyForMarkType:markType]];
    }
    NSDate* dateToSelect = [self clearDateFromhhmmss:date];
    [newSet addObject:dateToSelect];
    
    [self reloadItemsWithDates:@[dateToSelect]];
    
}
-(void)markDates:(NSSet*)dates withType:(FIMSCCellMarkType)markType
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSDate* date in dates.allObjects)
        {
            NSDate* dateToSelect = [self clearDateFromhhmmss:date];
            for(NSString* key in self.markedDates.allKeys)
            {
                NSMutableSet* set = self.markedDates[key];
                [set removeObject:dateToSelect];
            }
        }
        NSMutableSet* newSet = [self.markedDates objectForKey:[self stringKeyForMarkType:markType]];
        if(!newSet)
        {
            newSet = [NSMutableSet new];
#warning тут ошибка, переделать на operation queue?
            [self.markedDates setObject:newSet forKey:[self stringKeyForMarkType:markType]];
        }
        for (NSDate* date in dates.allObjects)
        {
            NSDate* dateToSelect = [self clearDateFromhhmmss:date];
            [newSet addObject:dateToSelect];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    });
    
}
-(void)unmarkDate:(NSDate *)date
{
    NSDate* dateFromComps = [self clearDateFromhhmmss:date];
    for(NSString* key in self.markedDates.allKeys)
    {
        NSMutableSet* set = self.markedDates[key];
        [set removeObject:dateFromComps];
    }
    
    [self reloadItemsWithDates:@[dateFromComps]];
}
-(void)unmarkDates:(NSSet *)dates
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* datesToUpdate = [NSMutableArray new];
        for (NSDate* date in dates.allObjects)
        {
            NSDate* dateToSelect = [self clearDateFromhhmmss:date];
            for(NSString* key in self.markedDates.allKeys)
            {
                NSMutableSet* set = self.markedDates[key];
                [set removeObject:dateToSelect];
            }
            [datesToUpdate addObject:dateToSelect];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadItemsWithDates:datesToUpdate];
        });
    });
}
-(void)unmarkAllDates
{
    for(NSString* key in self.markedDates.allKeys)
    {
        NSMutableSet* set = [self.markedDates objectForKey:key];
        [set removeAllObjects];
    }
    [self reloadData];
}
#pragma mark - Scroll to today
-(void)scrollToTodayAnimated:(BOOL)animate
{
    NSIndexPath* index = [self indexPathForDate:self.todayDate];
    if(index)
    {
        [self scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animate];
    }
}
#pragma mark - Get current calendar bounds
-(NSDate*)currentFirstDate
{
    if(self.monthsSections.count)
    {
        NSDictionary* monthInfo = [self.monthsSections firstObject];
        return [monthInfo objectForKey:monthSectionDictKey_RefDate];
    }
    return nil;
}
-(NSDate*)currentLastDate
{
    if(self.monthsSections.count)
    {
        NSDictionary* monthInfo = [self.monthsSections lastObject];
        NSDate* refDate = [monthInfo objectForKey:monthSectionDictKey_RefDate];
        NSInteger numOfDays = [[monthInfo objectForKey:monthSectionDictKey_NumOfDays]integerValue];
        NSDateComponents* comps = [self.calendar components:calendarUnitComponents fromDate:refDate];
        [comps setDay:numOfDays];
        return [self.calendar dateFromComponents:comps];
    }
    return nil;
}
#pragma mark - Helper Methods
-(NSDate*)dateForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* monthInfo = [self.monthsSections objectAtIndex:indexPath.section];
    if(monthInfo)
    {
        NSDate* refDate = [monthInfo objectForKey:monthSectionDictKey_RefDate];
        NSInteger firstDay = [[monthInfo objectForKey:monthSectionDictKey_WeekDayOfTheFirstDay]integerValue];
        NSInteger day = indexPath.row + 2 - firstDay;
        if(day > 0)
        {
            NSDateComponents* dateComps = [self.calendar components:calendarUnitComponents fromDate:refDate];
            [dateComps setDay:day];
            return [self.calendar dateFromComponents:dateComps];
        }
    }
    return nil;
}
-(NSIndexPath*)indexPathForDate:(NSDate*)date
{
    if(self.monthsSections.count)
    {
        NSDate* firstDate = [self currentFirstDate];
        NSDate* lastDate = [self currentLastDate];
        if([date timeIntervalSinceDate:firstDate]>=0 && [date timeIntervalSinceDate:lastDate]<=0)
        {
            NSDateComponents* components = [self.calendar components:calendarUnitComponents fromDate:date];
            for (NSInteger i = 0; i < self.monthsSections.count; i ++)
            {
                NSDictionary* monthInfo = [self.monthsSections objectAtIndex:i];
                NSDate* refDate = [monthInfo objectForKey:monthSectionDictKey_RefDate];
                NSDateComponents* refDateComps = [self.calendar components:calendarUnitComponents fromDate:refDate];
                if(refDateComps.year == components.year && refDateComps.month == components.month)
                {
                    NSInteger weekDay = [[monthInfo objectForKey:monthSectionDictKey_WeekDayOfTheFirstDay]integerValue];
                    NSInteger item = weekDay - 1 + components.day - 1;
                    return [NSIndexPath indexPathForItem:item inSection:i];
                }
            }
        }
    }
    return nil;
}
-(NSInteger)sectionForDate:(NSDate*)date
{
    if(self.monthsSections.count)
    {
        NSDate* firstDate = [self currentFirstDate];
        NSDate* lastDate = [self currentLastDate];
        if([date timeIntervalSinceDate:firstDate]>=0 && [date timeIntervalSinceDate:lastDate]<=0)
        {
            NSDateComponents* components = [self.calendar components:calendarUnitComponents fromDate:date];
            for (NSInteger i = 0; i < self.monthsSections.count; i ++)
            {
                NSDictionary* monthInfo = [self.monthsSections objectAtIndex:i];
                NSDate* refDate = [monthInfo objectForKey:monthSectionDictKey_RefDate];
                NSDateComponents* refDateComps = [self.calendar components:calendarUnitComponents fromDate:refDate];
                if(refDateComps.year == components.year && refDateComps.month == components.month)
                {
                    return i;
                }
            }
        }
    }
    return NSNotFound;
}
-(void)reloadItemsWithDates:(NSArray*)dates
{
    NSMutableArray* array = [NSMutableArray new];
    for (NSDate* date in dates)
    {
        NSIndexPath* pathForCellToUpdate = [self indexPathForDate:date];
        if(pathForCellToUpdate)
        {
            [array addObject:pathForCellToUpdate];
        }
    }
    if(array.count)
    {
        [self reloadItemsAtIndexPaths:array];
    }
}
-(NSInteger)convertWeekDay:(NSInteger)weekDay
{
    NSInteger firstWeekday = self.calendar.firstWeekday;
    weekDay -= firstWeekday - 1;
    while (weekDay<=0)
    {
        weekDay+=7;
    }
    return weekDay;
}
-(NSString*)stringKeyForMarkType:(FIMSCCellMarkType)markType
{
    return [NSString stringWithFormat:@"%ld",(long)markType];
}

@end
