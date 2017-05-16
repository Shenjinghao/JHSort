//
//  ViewController.m
//  JHSort
//
//  Created by Shenjinghao on 2017/4/14.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+JHSort.h"
#import "JHHeapSortViewController.h"

static const NSInteger kBarCount = 100;

@interface ViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSMutableArray *barArray;  //存储100个高低不同的bar view

@property (nonatomic, assign) NSTimeInterval nowTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_semaphore_t sema;
@property (nonatomic, strong) UIButton *bottomButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNavigationBar];
    
    [self createSegmentControl];
    
    [self createTimeLabel];
    
    [self createBottomButton];
    
    //先初始化好
    [self resetClicked:nil];
    
    
}

- (void)createNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(resetClicked:)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor redColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(sortClicked:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor redColor]];
}

- (void)createSegmentControl
{
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"冒泡", @"选择", @"插入", @"快速", @"希尔", @"堆排序"]];
        _segmentControl.frame = CGRectMake(15, 64 + 10, CGRectGetWidth(self.view.bounds) - 30, 30);
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(onSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_segmentControl];
    }
}

- (void)createTimeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        self.timeLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * 0.5 - 50,
                                          CGRectGetHeight(self.view.bounds) * 0.8, 120, 40);
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor darkTextColor];
        [self.view addSubview:_timeLabel];
    }
}

- (void)createBottomButton
{
    if (!_bottomButton) {
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.frame = CGRectMake(15, self.view.bounds.size.height * 0.9, self.view.bounds.size.width - 30, 45);
        [_bottomButton addTarget:self action:@selector(bottomButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _bottomButton.backgroundColor = RGBCOLOR_HEX(0x39D167);
        [_bottomButton setTitle:@"堆排序另类图" forState:UIControlStateNormal];
        [self.view addSubview:_bottomButton];
    }
}

- (void)bottomButtonClicked
{
    JHHeapSortViewController *controller = [[JHHeapSortViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSMutableArray *)barArray
{
    if (!_barArray) {
        _barArray = [NSMutableArray arrayWithCapacity:kBarCount];
        
        for (NSInteger i = 0; i < kBarCount; i ++)
        {
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = RGBCOLOR_HEX(0x39D167);
            [self.view addSubview:view];
            [_barArray addObject:view];
        }
    }
    return _barArray;
}

- (void)resetClicked:(id)sender
{
    [self invalidateTimer];
    
    self.timeLabel.text = nil;
    self.bottomButton = nil;
    
    //Example:如何值是3.4的话，则
    //3.4 -- round 3.000000
    //    -- ceil 4.000000
    //    -- floor 3.00000
    //width：屏幕宽度   barMargin：bar的空隙宽度 barX barY :xy坐标  spaceY spaceHeight：排序空间的y和height
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat barMargin = 1;
    CGFloat barWidth = floorf((width - barMargin * (kBarCount + 1)) / kBarCount);
    CGFloat barX = roundf((width - (barMargin + barWidth) * kBarCount + barMargin) / 2.0);
    CGFloat spaceY = 64 + 10 + 30 + 10;
    CGFloat barBottom = CGRectGetHeight(self.view.bounds) * 0.8;
    CGFloat spaceHeight = barBottom - spaceY;
    
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //创建20~~spaceHeight-20之间的随机数作为bar的高度
        CGFloat barHeight = arc4random_uniform(spaceHeight - 20) + 20;
        //若需要制造高概率重复数据请打开此行，令数值为10的整数倍(或修改为其它倍数)
        //barHeight = roundf(barHeight / 10) * 10;
        
        obj.frame = CGRectMake(barX + (barMargin + barWidth) * idx, barBottom - barHeight, barWidth, barHeight);
        
    }];
    
    NSLog(@"重置成功!");
    [self printBarArray];
}

- (void)sortClicked:(id)sender
{
    if (self.timer) {
        return;
    }
    //设置开始时间
    self.nowTime = [[NSDate date] timeIntervalSince1970];
    //创建semaphore，我们传入一个参数0 ，表示没有资源，非0 表示是有资源，
    self.sema = dispatch_semaphore_create(0);
    //创建计时器,没过0.002秒更新时间和发信号更新UI
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.002 target:self selector:@selector(fireTimerAction) userInfo:nil repeats:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        switch (self.segmentControl.selectedSegmentIndex) {
            case 0:
                [self bubbleSort];
                break;
            case 1:
                [self selectionSort];
                break;
            case 2:
                [self insertionSort];
                break;
            case 3:
                [self quickSort];
                break;
            case 4: {
                [self shellSort];
                break;
            }
            case 5: {
                [self heapSort];
                break;
            }
            default:
                break;
        }
        [self invalidateTimer];
        [self printBarArray];
    });
}

- (void)printBarArray {
#if 1
    NSMutableString *str = [NSMutableString string];
    [self.barArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@ ", @(CGRectGetHeight(obj.frame))];
    }];
    NSLog(@"数组：%@", str);
#endif
}

- (void)onSegmentControlChanged:(id)sender
{
    [self resetClicked:nil];
}

- (void)fireTimerAction {
    //发出信号量，唤醒排序线程，发送信号，信号量  管理资源数+1
    dispatch_semaphore_signal(self.sema);
    //更新计时
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - self.nowTime;
    self.timeLabel.text = [NSString stringWithFormat:@"耗时(秒):%2.3f", interval];
}

- (void)invalidateTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.sema = nil;
}

- (void)bubbleSort
{
    [self.barArray jh_bubbleSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
        
    } didExchange:^(id obj1, id obj2) {
        
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
        
    }];
}

- (void)quickSort
{
    [self.barArray jh_quickSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
    }];
}

- (void)selectionSort
{
    [self.barArray jh_selectionSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
    }];
}

- (void)insertionSort
{
    [self.barArray jh_insertionSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
    }];
}

- (void)shellSort
{
    [self.barArray jh_shellSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
    }];
}

- (void)heapSort
{
    [self createBottomButton];
    [self.barArray jh_heapSortWithComparisonResult:^NSComparisonResult(id obj1, id obj2) {
        return [self comparisonResultWithBarViewA:obj1 andBarViewB:obj2];
    } didExchange:^(id obj1, id obj2) {
        [self exchangeBarViewA:obj1 andBarViewB:obj2];
    }];
}

#pragma mark 等待接收信号，获取比较结果
- (NSComparisonResult)comparisonResultWithBarViewA:(UIView *)barViewA andBarViewB:(UIView *)barViewB
{
    //等待接收信号，信号等待 时，资源数 -1  阻塞当前线程
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    
    CGFloat barAHeight = CGRectGetHeight(barViewA.frame);
    CGFloat barBHeight = CGRectGetHeight(barViewB.frame);
    
    if (barAHeight == barBHeight) {
        return NSOrderedSame;
    }
    
    return barAHeight < barBHeight ? NSOrderedAscending : NSOrderedDescending;
    
}

#pragma mark 交换view，必须要再主线程更新UI
- (void)exchangeBarViewA:(UIView *)barViewA andBarViewB:(UIView *)barViewB
{
    //异步，如果用sync回出现奔溃
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect barA = barViewA.frame;
        CGRect barB = barViewB.frame;
        
        barA.origin.x = barViewB.frame.origin.x;
        barB.origin.x = barViewA.frame.origin.x;
        
        barViewA.frame = barA;
        barViewB.frame = barB;
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
