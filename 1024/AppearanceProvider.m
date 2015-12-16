//
//  AppearanceProvider.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "AppearanceProvider.h"

@implementation AppearanceProvider

- (UIColor *)tileColor:(int)value {
    switch (value) {
        case 2:
            return [UIColor colorWithRed:238.0/255.0 green:228.0/255.0 blue:218.0/255.0 alpha:1.0];
            break;
        case 4:
            return [UIColor colorWithRed:237.0/255.0 green:224.0/255.0 blue:200.0/255.0 alpha:1.0];
            break;
        case 8:
            return [UIColor colorWithRed:242.0/255.0 green:177.0/255.0 blue:121.0/255.0 alpha:1.0];
            break;
        case 16:
            return [UIColor colorWithRed:245.0/255.0 green:149.0/255.0 blue:99.0/255.0 alpha:1.0];
            break;
        case 32:
            return [UIColor colorWithRed:246.0/255.0 green:124.0/255.0 blue:95.0/255.0 alpha:1.0];
            break;
        case 64:
            return [UIColor colorWithRed:246.0/255.0 green:94.0/255.0 blue:59.0/255.0 alpha:1.0];
            break;
        case 128:
        case 256:
        case 512:
        case 1024:
            return [UIColor colorWithRed:237.0/255.0 green:207.0/255.0 blue:114.0/255.0 alpha:1.0];
            break;
        default:
            return [UIColor whiteColor];
            break;
    }
}

- (UIColor *)numberColor:(int)value {
    switch (value) {
        case 2:
        case 4:
            return [UIColor colorWithRed:119.0/255.0 green:110.0/255.0 blue:101.0/255.0 alpha:1.0];
            break;
        default:
            return [UIColor whiteColor];
            break;
    }
}

- (UIFont *)fontForNumbers {
    return [UIFont systemFontOfSize:20];
}

@end
