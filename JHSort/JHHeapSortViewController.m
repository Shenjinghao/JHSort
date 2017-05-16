//
//  JHHeapSortViewController.m
//  JHSort
//
//  Created by Shenjinghao on 2017/5/15.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import "JHHeapSortViewController.h"
#import "JHSortLineVIew.h"
#import "NSMutableArray+JHSort.h"

static const CGFloat kNodeSize = 34;

@interface JHHeapSortViewController ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *nodeArray;

@property (nonatomic, strong) NSMutableArray<JHSortLineVIew *> *lineArray;

@property (nonatomic, assign) BOOL hasSignal;

@end

@implementation JHHeapSortViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.nodeArray = [NSMutableArray array];
        self.lineArray = [NSMutableArray array];
        
        //绘制
        [self resetClicked];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    
}

- (void)createNavigationBar
{
    UIBarButtonItem *right1 = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(resetClicked)];
    UIBarButtonItem *right2 = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(sortClicked)];
    self.navigationItem.rightBarButtonItems = @[right1, right2];
}

#pragma mark 排序
- (void)sortClicked
{
    if (self.hasSignal) {
        return;
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.6 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self.hasSignal) {
            dispatch_semaphore_signal(sema);
        }    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.hasSignal = YES;
        
        [self.nodeArray jh_heapSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
            //比较
            return [self compareWithNodeA:obj1 nodeB:obj2];
        } didExchange:^(id obj1, id obj2) {
            //交换两结点
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            [self exchangeNodeA:obj1 nodeB:obj2];
        } didCut:^(id obj, NSInteger index) {
            //剪枝
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            [self cutNode:obj index:index];
        }];
        
        [timer invalidate];
        self.hasSignal = NO;
        
    });
}

#pragma mark 重置
- (void)resetClicked
{
    if (self.hasSignal) {
        return;
    }
    
    [self.nodeArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.nodeArray removeAllObjects];
    
    [self.lineArray enumerateObjectsUsingBlock:^(JHSortLineVIew * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.lineArray removeAllObjects];
    
    NSArray<NSNumber *> *data = @[@50, @10, @80, @30, @70, @20, @90, @40, @100, @60];
    [data enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self nodeWithIndex:idx].text = [NSString stringWithFormat:@"%@",obj];
    }];
    
    [self reloadData];
    
}

- (void)reloadData {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat nodeSpaceHeight = 80;
    for (NSInteger index = 1; index <= self.nodeArray.count; index ++) {
        // 从0开始
        NSInteger level = log2f(index);
        // 本层最多有多少个结点
        NSInteger count = powf(2, level);
        // 给本层的结点编号，从0开始
        NSInteger sequence = index % count;
        // 一个结点所属的空间宽度
        CGFloat nodeSpaceWidth = width / (2 * count);
        CGFloat centerX = (1 + sequence * 2) * nodeSpaceWidth;
        CGFloat centerY = (1 + level) * nodeSpaceHeight;
        
        // 画结点
        UILabel *node = self.nodeArray[index - 1];
        node.center = CGPointMake(centerX, centerY);
        node.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:node];
        
        // 画线
        if (index > 1) {
            UILabel *parentNode = [self nodeWithIndex:index / 2 - 1];
            JHSortLineVIew *line = [self lineViewWithIndex:index - 1];
            line.isRight = sequence % 2 == 1;
            CGFloat lineX = line.isRight ? parentNode.center.x : node.center.x;
            line.frame = CGRectMake(lineX,
                                    parentNode.center.y,
                                    ABS(node.center.x - parentNode.center.x),
                                    ABS(node.center.y - parentNode.center.y));
            [self.view insertSubview:line atIndex:0];
        }
    }
}

- (NSComparisonResult)compareWithNodeA:(UILabel *)nodeA nodeB:(UILabel *)nodeB {
    NSInteger num1 = [nodeA.text integerValue];
    NSInteger num2 = [nodeB.text integerValue];
    if (num1 == num2) {
        return NSOrderedSame;
    }
    return num1 < num2 ? NSOrderedAscending : NSOrderedDescending;
}

- (void)exchangeNodeA:(UILabel *)nodeA nodeB:(UILabel *)nodeB
{
    dispatch_async(dispatch_get_main_queue(), ^{
        nodeA.backgroundColor = [UIColor yellowColor];
        nodeB.backgroundColor = [UIColor yellowColor];
        
        [UIView animateWithDuration:0.4 animations:^{
            CGRect temp = nodeA.frame;
            nodeA.frame = nodeB.frame;
            nodeB.frame = temp;
        } completion:^(BOOL finished) {
            nodeA.backgroundColor = [UIColor whiteColor];
            nodeB.backgroundColor = [UIColor whiteColor];
        }];
    });
}

- (void)cutNode:(UILabel *)node index:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        node.backgroundColor = [UIColor lightGrayColor];
        [self.lineArray[index - 1] removeFromSuperview];
    });
}

- (UILabel *)createNodeLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kNodeSize, kNodeSize)];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = kNodeSize / 2;
    label.layer.masksToBounds = YES;
    [self.nodeArray addObject:label];
    return label;
}

- (UILabel *)nodeWithIndex:(NSInteger)index
{
    if (self.nodeArray.count < index + 1) {
        return [self createNodeLabel];
    }
    return self.nodeArray[index];
}

- (JHSortLineVIew *)createLineView
{
    JHSortLineVIew *view = [[JHSortLineVIew alloc] init];
    [self.lineArray addObject:view];
    return view;
}

- (JHSortLineVIew *)lineViewWithIndex:(NSInteger)index
{
    if (self.lineArray.count < index + 1) {
        return [self createLineView];
    }
    return self.lineArray[index];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
