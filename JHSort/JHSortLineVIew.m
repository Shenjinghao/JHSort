//
//  JHSortLineVIew.m
//  JHSort
//
//  Created by Shenjinghao on 2017/5/15.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import "JHSortLineVIew.h"

@implementation JHSortLineVIew

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setIsRight:(BOOL)isRight
{
    _isRight = isRight;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 1);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    
    CGFloat beginX = self.isRight ? 0 : CGRectGetWidth(rect);
    CGContextMoveToPoint(contextRef, beginX, 0);
    
    CGFloat endX = self.isRight ? CGRectGetWidth(rect) : 0;
    CGContextAddLineToPoint(contextRef, endX, CGRectGetHeight(rect));
    
    CGContextStrokePath(contextRef);
}

@end
