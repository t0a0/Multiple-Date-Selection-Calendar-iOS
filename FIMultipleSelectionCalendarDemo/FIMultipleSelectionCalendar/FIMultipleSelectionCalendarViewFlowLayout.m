//
//  FIMultipleSelectionCalendarViewFlowLayout.m
//  FIMultipleSelectionCalendarView
//
//  Created by Igor on 03.10.14.
//  Copyright (c) 2014 Fedotov.Igor. All rights reserved.
//

#import "FIMultipleSelectionCalendarViewFlowLayout.h"
@interface FIMultipleSelectionCalendarViewFlowLayout () <UICollectionViewDelegateFlowLayout>


@end

@implementation FIMultipleSelectionCalendarViewFlowLayout
-(instancetype)initWithCollectionViewSize:(CGSize)cvSize
{
    if(self = [super init])
    {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self setCVSize:cvSize];
    }
    return self;
}
-(void)setCVSize:(CGSize)cvSize
{
    CGFloat cellSize = cvSize.width/7;
    self.itemSize = CGSizeMake(cellSize, cellSize*1.25);
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.headerReferenceSize = CGSizeMake(cvSize.width, 35);

}


@end
