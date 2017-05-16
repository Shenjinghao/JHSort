//
//  LearnSort.m
//  JHSort
//
//  Created by Shenjinghao on 2017/4/28.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import "LearnSort.h"

@implementation LearnSort

+ (void)load
{
    [self bubbleSortWithArray:[[self class] createArrays]];
    
    [self simpleSelectionSortWithArray:[self createArrays]];
    
    [self StraightInsertionSortWithArray:[self createArrays]];
    
    [self shellSortWithArray:[self createArrays]];
    
    [self quickSortWithArray:[self createArrays]];
    
    [self heapSortWithArray:[self createArrays]];
}

#pragma mark 初始化一个数组元素
+ (NSMutableArray *)createArrays
{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@(9),@(1),@(3),@(6),@(4),@(7),@(5),@(2),@(8), nil];
    return array;
}

#pragma mark 冒泡排序
+ (void)bubbleSortWithArray:(NSMutableArray *)array
{
    long count = array.count;
    int runCounts = 0;//记录运行次数
    
    for (NSInteger i = 0; i < count; i ++)
    {
        BOOL isExchange = NO;//哨兵，如果后面排序没有移动，直接返回
        
        
        for (NSInteger j = 0; j < count - i - 1; j ++)
        {
            if (array[j] > array[j + 1]) {
                
                [array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                
                isExchange = YES;
            }
            runCounts ++;
        }
        
        runCounts ++;
        //通过哨兵进行的优化
        if (isExchange == NO) {
            NSLog(@"\n冒泡排序后的数组：%@   共运行了%d",array, runCounts);
            return;
        }
    }
    //优化后的算法比原来的算法runCounts少很多
    NSLog(@"\n冒泡排序后的数组：%@   运行了%d",array, runCounts);
}

#pragma mark 简单选择排序(直接选择排序)
+ (void)simpleSelectionSortWithArray:(NSMutableArray *)array
{
    long count = array.count;
    int runCounts = 0;//记录运行次数
    NSInteger i, j, min;
    
    for (i = 0; i < count; i ++)
    {
        min = i;//记录下最小元素的位置
        for (j = i + 1; j < count; j ++)
        {
            if (array[j] < array[min]) {
                
                min = j;//找到最小的数据的位置并存储起来
            }
            runCounts ++;
        }
        //判断如果有两个位置的数据相同情况出现，如果不同就交换
        if (i != min) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:min];
        }
        runCounts ++;
    }
    //次数和冒泡没有优化前一样，优化后的冒泡性能要比简单选择排序要好
    NSLog(@"\n简单选择排序后的数组：%@   共运行了%d",array, runCounts);
    
}

#pragma mark 直接插入排序
+ (void)StraightInsertionSortWithArray:(NSMutableArray *)array
{
    NSInteger count = array.count;
    NSInteger i, j;
    NSNumber *temp;//存储需要插入的值，哨兵的作用
    int runCounts = 0;//记录运行次数
    
    for (i = 1; i < count; i ++)
    {
        if (array[i] < array[i - 1]) {
            
            temp = array[i];//先从第二个开始插入，起到标记的作用
            
            for (j = i - 1; j >= 0 && array[j] > temp; j --)
            {
                array[j + 1] = array[j];//如果当前位置的数据比标记位置的数据大，就将当前位置数据赋给下一位
                runCounts ++;
            }
            
            array[j + 1] = temp;//此时的j经过j--已经变为了(i-1)--
            
        }
        runCounts ++;
    }
    //直接插入排序要优于冒泡和简单选择
    NSLog(@"\n直接插入排序后的数组：%@   共运行了%d",array, runCounts);
}

#pragma mark 希尔排序
+ (void)shellSortWithArray:(NSMutableArray *)array
{
    NSInteger i, j, gap;
    NSInteger count = array.count;
    int runCounts = 0;//记录运行次数
    
    for (gap = count / 2; gap > 0; gap /= 2)
    {
        for (i = gap; i < count; i ++)
        {
            for (j = i - gap; j >= 0 && array[j] > array[j + gap]; j -= gap)
            {
                [array exchangeObjectAtIndex:j withObjectAtIndex:j + gap];
            }
            runCounts ++;
        }
        runCounts ++;
    }
    //直接插入排序要优于冒泡和简单选择
    NSLog(@"\n希尔排序后的数组：%@   共运行了%d",array, runCounts);
}

#pragma mark 快速排序
+ (void)quickSortWithArray:(NSMutableArray *)array
{
    //http://blog.csdn.net/morewindows/article/details/6684558
    if (array.count == 0) {
        return;
    }
    NSInteger i = 0, j = array.count - 1;
    
    [self quickSortWithArray:array lowIndex:i highIndex:j];
    

}

static int runCounts = 0;//记录运行次数
+ (void)quickSortWithArray:(NSMutableArray *)array lowIndex:(NSInteger)lowIndex highIndex:(NSInteger)highIndex
{
    NSInteger i = lowIndex, j = highIndex;
    if (i >= j) {
        return;
    }
    id pivot = array[i];
    
    while (i < j) {
        
        //从右向左找小于pivot的数来填array[i]
        while (i < j && array[j] >= pivot) {
            j --;
        }
        //将array[j]填到array[i]中，array[j]就形成了一个新的坑
        if (i < j) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            i ++;
            runCounts ++;
        }
        //从左向右找大于等于pivot的数来填array[j]
        while (i < j && array[i] < pivot) {
            i ++;
        }
        //将array[j]填到array[i]中，array[j]就形成了一个新的坑
        if (i < j) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:j];
            j --;
            runCounts ++;
        }
        runCounts ++;
    }
//    array[i] = pivot;
    
    
    [self quickSortWithArray:array lowIndex:lowIndex highIndex:i - 1];
    [self quickSortWithArray:array lowIndex:i + 1 highIndex:highIndex];
    
    NSLog(@"\n快速排序后的数组：%@   共运行了%d",array, runCounts);
}


#pragma mark 堆排序
+ (void)heapSortWithArray:(NSMutableArray *)array
{
    
}



@end
