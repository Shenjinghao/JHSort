//
//  ViewController.h
//  JHSort
//
//  Created by Shenjinghao on 2017/4/14.
//  Copyright © 2017年 SJH. All rights reserved.
//

#import <UIKit/UIKit.h>


#define RGBCOLOR_HEX(hexColor) rgbaFromHex(hexColor, 1)

@interface ViewController : UIViewController



@end

UIColor *rgba(int r, int g, int b, float alpha) {
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:alpha];
}

UIColor *rgbaFromHex(NSInteger hexColor, CGFloat alpha) {
    return rgba((hexColor >> 16) & 0xFF, (hexColor >> 8) & 0xFF, hexColor & 0xFF, alpha);
}

