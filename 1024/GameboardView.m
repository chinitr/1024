//
//  GameboardView.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "GameboardView.h"
#import "AppearanceProvider.h"
#import "TileView.h"

@interface GameboardView ()

@property (nonatomic)int dimension;
@property (nonatomic)CGFloat tileWidth;
@property (nonatomic)CGFloat tilePadding;
@property (nonatomic)CGFloat cornerRadius;
@property (nonatomic)NSMutableDictionary* tiles;

@property (nonatomic)AppearanceProvider* provider;

@property (nonatomic)CGFloat tilePopStartScale;
@property (nonatomic)CGFloat tilePopMaxScale;
@property (nonatomic)NSTimeInterval tilePopdelay;
@property (nonatomic)NSTimeInterval tileExpandTime;
@property (nonatomic)NSTimeInterval tileContractTime;

@property (nonatomic)CGFloat tileMergeStartScale;
@property (nonatomic)NSTimeInterval tileMergeExpandTime;
@property (nonatomic)NSTimeInterval tileMergeContractTime;

@property (nonatomic)NSTimeInterval perSquareSlideDuration;

@end

@implementation GameboardView

- (instancetype)init:(int)dimension tileWidth:(CGFloat)width tilePadding:(CGFloat)padding cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgcolor foregroundColor:(UIColor *)fgcolor {
    
    CGFloat sideLength = padding + dimension*(width + padding);
    self = [super initWithFrame:CGRectMake(0, 0, sideLength, sideLength)];
    if (self != nil) {
        _tilePopStartScale = 0.1;
        _tilePopMaxScale = 1.1;
        _tilePopdelay = 0.05;
        _tileExpandTime = 0.18;
        _tileContractTime = 0.08;
        
        _tileMergeStartScale = 1.0;
        _tileMergeExpandTime = 0.08;
        _tileMergeContractTime = 0.08;
        
        _perSquareSlideDuration = 0.08;
        _provider = [[AppearanceProvider alloc] init];
        
        _dimension = dimension;
        _tileWidth = width;
        _tilePadding = padding;
        _cornerRadius = radius;
        _tiles = [[NSMutableDictionary alloc] init];
        self.layer.cornerRadius = radius;
        [self setupBackground:bgcolor tileColor:fgcolor];
    }
    return self;
}

- (void)reset {
    [self.tiles enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        TileView* view = obj;
        [view removeFromSuperview];
    }];
}

- (BOOL)positionIsValid:(int)x posY:(int)y {
    return (x >= 0 && x < self.dimension && y >= 0 && y < self.dimension);
}

- (void)setupBackground:(UIColor*)bgColor tileColor:(UIColor*)tcolor {
    self.backgroundColor = bgColor;
    CGFloat xCursor = self.tilePadding;
    CGFloat yCursor = 0.0;
    CGFloat bgRadius = (self.cornerRadius >= 2) ? self.cornerRadius - 2 : 0;
    for (int i = 0; i < self.dimension; ++i) {
        yCursor = self.tilePadding;
        for (int j = 0; j < self.dimension; ++j) {
            UIView* background = [[UIView alloc] initWithFrame:CGRectMake(xCursor, yCursor, self.tileWidth, self.tileWidth)];
            background.layer.cornerRadius = bgRadius;
            background.backgroundColor = tcolor;
            [self addSubview:background];
            yCursor += self.tilePadding + self.tileWidth;
        }
        xCursor += self.tilePadding + self.tileWidth;
    }
}

- (void)insertTile:(int)posx toY:(int)posy Value:(int)value {
    int row = posx;
    int col = posy;
    CGFloat x = self.tilePadding + (self.tileWidth + self.tilePadding)*col;
    CGFloat y = self.tilePadding + (self.tileWidth + self.tilePadding)*row;
    CGFloat r = (self.cornerRadius >= 2) ? self.cornerRadius - 2 : 0;
    TileView* tile = [[TileView alloc] init:CGPointMake(x, y) width:self.tileWidth Value:value radius:r Delegate:self.provider];
    [tile.layer setAffineTransform:CGAffineTransformMakeScale(self.tilePopStartScale, self.tilePopStartScale)];
    
    [self addSubview:tile];
    [self bringSubviewToFront:tile];
    self.tiles[[NSIndexPath indexPathForRow:row inSection:col]] = tile;
    
    [UIView animateWithDuration:self.tileExpandTime delay:self.tilePopdelay options:UIViewAnimationOptionTransitionNone animations:^{
        [tile.layer setAffineTransform:CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:self.tileContractTime animations:^{
            [tile.layer setAffineTransform:CGAffineTransformIdentity];
        }];
    }];
}

- (void)moveOneTile:(int)fromx fromY:(int)fromy toX:(int)tox toY:(int)toy value:(int)val {
    NSIndexPath* fromkey = [NSIndexPath indexPathForRow:fromx inSection:fromy];
    NSIndexPath* tokey = [NSIndexPath indexPathForRow:tox inSection:toy];
    
    TileView* tile = self.tiles[fromkey];
    TileView* endTile = self.tiles[tokey];
    
    CGRect finalFrame = tile.frame;
    finalFrame.origin.x = self.tilePadding + (self.tileWidth + self.tilePadding)*toy;
    finalFrame.origin.y = self.tilePadding + (self.tileWidth + self.tilePadding)*tox;
    
    [self.tiles removeObjectForKey:fromkey];
    self.tiles[tokey] = tile;
    
    BOOL shouldPop = endTile != nil;
    [UIView animateWithDuration:self.perSquareSlideDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        tile.frame = finalFrame;
    } completion:^(BOOL finished){
        [tile setValue:val];
        if (endTile != nil) {
            [endTile removeFromSuperview];
        }
        if (!shouldPop || !finished)
            return;
        
        [tile.layer setAffineTransform:CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale)];
        [UIView animateWithDuration:self.tileMergeExpandTime animations:^{
            [tile.layer setAffineTransform:CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale)];
        } completion:^(BOOL fin) {
            [UIView animateWithDuration:self.tileMergeContractTime animations:^{
                [tile.layer setAffineTransform:CGAffineTransformIdentity];
            }];
        }];
    }];
}

- (void)moveTwoTiles:(int)fromRowA fromColA:(int)fromColA fromColB:(int)fromRowB fromby:(int)fromColB toX:(int)toRow toY:(int)toCol Value:(int)value {
    NSIndexPath* fromkeya = [NSIndexPath indexPathForRow:fromRowA inSection:fromColA];
    NSIndexPath* fromkeyb = [NSIndexPath indexPathForRow:fromRowB inSection:fromColB];
    NSIndexPath* tokey = [NSIndexPath indexPathForRow:toRow inSection:toCol];
    
    TileView* tilea = self.tiles[fromkeya];
    TileView* tileb = self.tiles[fromkeyb];
    
    CGRect finalFrame = tilea.frame;
    finalFrame.origin.x = self.tilePadding + (self.tileWidth + self.tilePadding)*toCol;
    finalFrame.origin.y = self.tilePadding + (self.tileWidth + self.tilePadding)*toRow;
    
    TileView* oldTile = self.tiles[tokey];
    if (oldTile != nil) {
        [oldTile removeFromSuperview];
    }
    [self.tiles removeObjectForKey:fromkeya];
    [self.tiles removeObjectForKey:fromkeyb];
    [self.tiles setObject:tilea forKey:tokey];
    
    [UIView animateWithDuration:self.perSquareSlideDuration delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        tilea.frame = finalFrame;
        tileb.frame = finalFrame;
    } completion:^(BOOL finished) {
        [tilea setValue:value];
        [tileb removeFromSuperview];
        if (!finished)
            return;
        
        [tilea.layer setAffineTransform:CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale)];
        [UIView animateWithDuration:self.tileMergeExpandTime animations:^{
            [tilea.layer setAffineTransform:CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:self.tileMergeContractTime animations:^{
                [tilea.layer setAffineTransform:CGAffineTransformIdentity];
            }];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
