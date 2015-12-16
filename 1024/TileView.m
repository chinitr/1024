//
//  TileView.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "TileView.h"

@implementation TileView

-(void)setValue:(int)value {
    _value = value;
    self.backgroundColor = [self.delegate tileColor:value];
    self.numberLabel.textColor = [self.delegate numberColor:value];
    self.numberLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (instancetype)init:(CGPoint)position width:(CGFloat)width Value:(int)value radius:(int)radius Delegate:(id<AppearanceProviderProtocol>)delegate {
    self = [super initWithFrame:CGRectMake(position.x, position.y, width, width)];
    if (self != nil) {
        _value = value;
        _delegate = delegate;
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, width)];;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.minimumScaleFactor = 0.5;
        _numberLabel.font = [_delegate fontForNumbers];
        
        [self addSubview:_numberLabel];
        self.layer.cornerRadius = radius;
        
        [self setValue:_value];
        self.backgroundColor = [_delegate tileColor:_value];
        _numberLabel.textColor = [_delegate numberColor:_value];
        _numberLabel.text = [NSString stringWithFormat:@"%d", _value];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
