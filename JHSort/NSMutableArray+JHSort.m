//
//  NSMutableArray+JHSort.m
//  JHSort
//
//  Created by Shenjinghao on 2017/5/2.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import "NSMutableArray+JHSort.h"

@implementation NSMutableArray (JHSort)

#pragma mark 交换元素，indexA的元素 > indexB的元素 就交换
- (void)jh_exchangeWithIndexA:(NSInteger)indexA indexB:(NSInteger)indexB didExchange:(JHSortExchangeBlock)exchangeBlock
{
    //使用系统的交换方法
    [self exchangeObjectAtIndex:indexA withObjectAtIndex:indexB];
    
    //将交换后的数值传出去(大的数据再前，方便出去后UI做交换)
    if (exchangeBlock) {
        exchangeBlock(self[indexB],self[indexA]);
    }
}

- (void)jh_bubbleSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    
    for (NSInteger i = 0; i < self.count - 1; i ++)
    {
        for (NSInteger j = 0; j < self.count - 1 - i; j ++)
        {
            if (comparisonResult(self[j],self[j + 1]) == NSOrderedDescending) {
                [self jh_exchangeWithIndexA:j indexB:j + 1 didExchange:exchangeBlock];
            }
        }
    }
}

#pragma mark 快排，分治法，分段排序
- (void)jh_quickSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    [self jh_quickSortWithLowIndex:0 highIndex:self.count - 1 ComparisonResult:comparisonResult didExchange:exchangeBlock];
}

- (void)jh_quickSortWithLowIndex:(NSInteger)lowIndex highIndex:(NSInteger)highIndex ComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    if (lowIndex >= highIndex) {
        return;
    }
    NSInteger i = lowIndex, j = highIndex;
    //选取
    id pivot = self[lowIndex];
    while (i < j) {
        while (i < j && comparisonResult(self[j], pivot) == NSOrderedDescending) {
            j --;
        }
        if (i < j) {
            [self jh_exchangeWithIndexA:i indexB:j didExchange:exchangeBlock];
            i ++;
        }
        
        while (i < j && comparisonResult(self[i], pivot) == NSOrderedAscending) {
            i ++;
        }
        if (i < j) {
            [self jh_exchangeWithIndexA:i indexB:j didExchange:exchangeBlock];
            j -- ;
        }
    }
    
    [self jh_quickSortWithLowIndex:lowIndex highIndex:i - 1 ComparisonResult:comparisonResult didExchange:exchangeBlock];
    [self jh_quickSortWithLowIndex:i + 1 highIndex:highIndex ComparisonResult:comparisonResult didExchange:exchangeBlock];
}

#pragma mark 选择
- (void)jh_selectionSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    NSInteger i, j, min;
    
    for (i = 0; i < self.count; i ++)
    {
        min = i;//记录下最小元素的位置
        for (j = i + 1; j < self.count; j ++)
        {
            if (comparisonResult(self[j] , self[min]) == NSOrderedAscending) {
                
                min = j;//找到最小的数据的位置并存储起来
            }
        }
        //判断如果有两个位置的数据相同情况出现，如果不同就交换
        if (i != min) {
            [self jh_exchangeWithIndexA:i indexB:min didExchange:exchangeBlock];
        }
    }
}

- (void)jh_insertionSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    NSInteger i, j;
    id temp;//存储需要插入的值，哨兵的作用
    for (i = 1; i < self.count; i ++)
    {
        if (comparisonResult(self[i], self[i - 1]) == NSOrderedAscending) {
            temp = self[i];//先从第二个开始插入，起到标记的作用
            
            for (j = i - 1; j >= 0 && comparisonResult(self[j], temp) == NSOrderedDescending; j --)
            {
                [self jh_exchangeWithIndexA:j indexB:j + 1 didExchange:exchangeBlock];//如果当前位置的数据比标记位置的数据大，就将当前位置数据赋给下一位
            }
            self[j + 1] = temp;//此时的j经过j--已经变为了(i-1)--
        }
    }
}

- (void)jh_shellSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    NSInteger i, j, gap;
    NSInteger count = self.count;
    
    for (gap = count / 2; gap > 0; gap /= 2)
    {
        for (i = gap; i < count; i ++)
        {
            for (j = i - gap; j >= 0 && comparisonResult(self[j], self[j + gap]) == NSOrderedDescending; j -= gap)
            {
                [self jh_exchangeWithIndexA:j indexB:j + gap didExchange:exchangeBlock];
            }
        }
    }
}

- (void)jh_heapSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock
{
    // copy一份副本，对副本排序。增加的此步与排序无关，仅为增强程序健壮性，防止在排序过程中被中断而影响到原数组。如果点击重置会crash
    NSMutableArray *array = [self mutableCopy];
    
    //排序过程中不使用第0位
    [array insertObject:[NSNull null] atIndex:0];
    
    // 构造大顶堆
    // 遍历所有非终结点，把以它们为根结点的子树调整成大顶堆
    // 最后一个非终结点位置在本队列长度的一半处
    for (NSInteger i = self.count / 2; i > 0 ; i --)
    {
        [array sinkIndex:i bottomIndex:self.count - 1 usingComparator:comparisonResult didExchange:exchangeBlock];
    }
    
    // 完全排序
    // 从整棵二叉树开始，逐渐剪枝
    for (NSInteger i = self.count - 1; i > 1; i --)
    {
        // 每次把根结点放在列尾，下一次循环时将会剪掉
        [array jh_exchangeWithIndexA:1 indexB:i didExchange:exchangeBlock];
        // 下沉根结点，重新调整为大顶堆
        [array sinkIndex:1 bottomIndex:i - 1 usingComparator:comparisonResult didExchange:exchangeBlock];
    }
    
    // 排序完成后删除占位元素
    [array removeObjectAtIndex:0];
    
    // 用排好序的副本代替自己
    [self removeAllObjects];
    [self addObjectsFromArray:array];
}

//下沉，传入需要下沉的元素位置，以及允许下沉的最底位置
- (void)sinkIndex:(NSInteger)index bottomIndex:(NSInteger)bottomIndex usingComparator:(JHComparisonResult)comparator didExchange:(JHSortExchangeBlock)exchangeCallback
{
    
    for (NSInteger maxChildIndex = index * 2; maxChildIndex <= bottomIndex; maxChildIndex *= 2) {
        // 如果存在右子结点，并且左子结点比右子结点小
        if (maxChildIndex < bottomIndex && (comparator(self[maxChildIndex], self[maxChildIndex + 1]) == NSOrderedAscending)) {
            // 指向右子结点
            ++ maxChildIndex;
        }
        // 如果最大的子结点元素小于本元素，则本元素不必下沉了
        if (comparator(self[maxChildIndex], self[index]) == NSOrderedAscending) {
            break;
        }
        // 否则
        // 把最大子结点元素上游到本元素位置
        [self jh_exchangeWithIndexA:index indexB:maxChildIndex didExchange:exchangeCallback];
        // 标记本元素需要下沉的目标位置，为最大子结点原位置
        index = maxChildIndex;
    }
    
}

- (void)jh_heapSortWithComparisonResult:(JHComparisonResult)comparisonResult didExchange:(JHSortExchangeBlock)exchangeBlock didCut:(JHHeapSortCutBlock)cutBlock
{
    // 排序过程中不使用第0位
    [self insertObject:[NSNull null] atIndex:0];
    
    // 构造大顶堆
    // 遍历所有非终结点，把以它们为根结点的子树调整成大顶堆
    // 最后一个非终结点位置在本队列长度的一半处
    for (NSInteger index = self.count / 2; index > 0; index --) {
        // 根结点下沉到合适位置
        [self sinkIndex:index bottomIndex:self.count - 1 usingComparator:comparisonResult didExchange:exchangeBlock];
    }
    
    // 完全排序
    // 从整棵二叉树开始，逐渐剪枝
    for (NSInteger index = self.count - 1; index > 1; index --) {
        // 每次把根结点放在列尾，下一次循环时将会剪掉
        [self jh_exchangeWithIndexA:1 indexB:index didExchange:exchangeBlock];
        if (cutBlock) {
            cutBlock(self[index], index - 1);
        }
        // 下沉根结点，重新调整为大顶堆
        [self sinkIndex:1 bottomIndex:index - 1 usingComparator:comparisonResult didExchange:exchangeBlock];
    }
    
    // 排序完成后删除占位元素
    [self removeObjectAtIndex:0];
}

@end
