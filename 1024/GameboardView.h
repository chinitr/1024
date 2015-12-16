//
//  GameboardView.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameboardView : UIView

- (instancetype)init:(int)dimension tileWidth:(CGFloat)width tilePadding:(CGFloat)padding cornerRadius:(CGFloat)radius backgroundColor:(UIColor*)bgcolor foregroundColor:(UIColor*)fgcolor;

- (void)insertTile:(int)x toY:(int)y Value:(int)value;
- (void)moveOneTile:(int)fromx fromY:(int)fromy toX:(int)tox toY:(int)toy value:(int)val;
- (void)moveTwoTiles:(int)fromRowA fromColA:(int)fromColA fromColB:(int)fromRowB fromby:(int)fromColB toX:(int)toRow toY:(int)toCol Value:(int)value;
- (void)reset;

@end
