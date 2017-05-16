//
//  NSMutableArray+JHSort.h
//  JHSort
//
//  Created by Shenjinghao on 2017/5/2.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import <Foundation/Foundation.h>

//比较
typedef NSComparisonResult(^JHComparisonResult)(id obj1, id obj2);
//交换
typedef void(^JHSortExchangeBlock)(id obj1, id obj2);
//堆排序
typedef void(^JHHeapSortCutBlock)(id obj, NSInteger index);



@interface NSMutableArray (JHSort)

//交换并将交换后的数据通过block返回
- (void)jh_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExchange:(JHSortExchangeBlock)exchangeBlock;

//冒泡
- (void)jh_bubbleSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//选择
- (void)jh_selectionSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//插入
- (void)jh_insertionSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//快速
- (void)jh_quickSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//希尔
- (void)jh_shellSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//堆排序
- (void)jh_heapSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock;

//堆排序新
- (void)jh_heapSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock didCut:(JHHeapSortCutBlock)cutBlock;


@end
