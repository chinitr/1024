//
//  ScoreView.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "ScoreView.h"

@interface ScoreView ()

@property (nonatomic)CGRect defaultFrame;
@property (nonatomic)UILabel* label;

@end

@implementation ScoreView

- (instancetype)init:(UIColor *)bgcolor textColor:(UIColor *)tcolor font:(UIFont *)f radius:(CGFloat)r {
    self = [super initWithFrame:CGRectMake(0, 0, 140, 40)];
    if (self != nil) {
        _defaultFrame = CGRectMake(0, 0, 140, 40);
        
        _label = [[UILabel alloc] initWithFrame:_defaultFrame];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = tcolor;
        _label.font = f;
        
        self.backgroundColor = bgcolor;
        self.layer.cornerRadius = r;
        [self addSubview:_label];
    }
    return self;
}

- (void)setScore:(int)score {
    _score = score;
    self.label.text = [NSString stringWithFormat:@"SCORE:%d", score];
}

- (void)scoreChanged:(int)newScore {
    [self setScore:newScore];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
