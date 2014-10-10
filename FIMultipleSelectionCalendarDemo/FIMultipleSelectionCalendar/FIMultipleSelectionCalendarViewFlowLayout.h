//
//  FIMultipleSelectionCalendarViewFlowLayout.h
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 03.10.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIMultipleSelectionCalendarView.h"
@interface FIMultipleSelectionCalendarViewFlowLayout : UICollectionViewFlowLayout


-(instancetype)initWithCollectionViewSize:(CGSize)cvSize;
-(void)setCVSize:(CGSize)cvSize;
@end
