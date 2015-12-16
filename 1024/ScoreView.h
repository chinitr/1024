//
//  ScoreView.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScoreViewProtocol <NSObject>

- (void)scoreChanged:(int)newScore;

@end

@interface ScoreView : UIView<ScoreViewProtocol>

- (instancetype)init:(UIColor*)bgcolor textColor:(UIColor*)tcolor font:(UIFont*)f radius:(CGFloat)r;

@property (nonatomic)int score;

@end
