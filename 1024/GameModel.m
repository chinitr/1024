//
//  GameModel.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "GameModel.h"

@interface GameModel()

@property (nonatomic)int dimension;
@property (nonatomic)int threshold;

@property (nonatomic)int score;

@property (nonatomic)SquareGameboard* gameboard;
@property (weak, nonatomic)id<GameModelProtocol> delegate;

@property (nonatomic)NSMutableArray* queue;
@property (nonatomic)NSTimer* timer;

@property (nonatomic)int maxCommands;
@property (nonatomic)float queueDelay;

@end

@implementation GameModel

- (void)setScore:(int)score {
    _score = score;
    [self.delegate scoreChanged:score];
}

- (instancetype)init:(int)dimension threshhold:(int)t Delegate:(id<GameModelProtocol>)delegate {
    self = [super init];
    if (self != nil) {
        _maxCommands = 100;
        _queueDelay = 0.3;
        _dimension = dimension;
        _threshold = t;
        _delegate = delegate;
        _queue = [[NSMutableArray alloc] init];
        _timer = [[NSTimer alloc] init];
        _gameboard = [[SquareGameboard alloc] init:dimension initValue:Empty];
        
    }
    return self;
}

- (void)reset {
    self.score = 0;
    [self.gameboard setAll:Empty];
    [self.queue removeAllObjects];
    [self.timer invalidate];
}

- (void)queueMove:(MoveDirection)direction completion:(queueMoveCompletionBlock)block {
    if (self.queue.count <= self.maxCommands) {
        CommandObject* item = [[CommandObject alloc]init:direction completion:block];
        [self.queue addObject:item];
        if (!self.timer.valid) {
            [self timerFired:self.timer];
        }
    }
}

- (void)timerFired:(NSTimer*)timer {
    if (self.queue.count == 0)
        return;
    
    BOOL changed = NO;
    while (self.queue.count > 0) {
        CommandObject* item = self.queue[0];
        [self.queue removeObjectAtIndex:0];
        changed = [self performMove:item.direction];
        item.block(changed);
        if (changed)
            break;
    }
    if (changed) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.queueDelay
                                                      target:self
                                                    selector:@selector(timerFired:)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)insertTile:(int)x col:(int)y Value:(int)value {
    TileObject* item = [self.gameboard getItem:x col:y];
    if (item.eType == Empty) {
        TileObject* obj = [[TileObject alloc] init];
        obj.eType = Tile;
        obj.value = value;
        [self.gameboard setItem:x col:y Value:obj];
        [self.delegate insertTile:x locationY:y Value:value];
    }
}

- (void)insertTileAtRandomLocation:(int)val {
    NSArray* openSpots = [self gameboardEmptySpots];
    if (openSpots.count == 0)
        return;
    
    int idx = arc4random_uniform((UInt32)openSpots.count - 1);
    NSArray* pos = openSpots[idx];
    NSNumber* x = pos[0];
    NSNumber* y = pos[1];
    [self insertTile:[x intValue] col:[y intValue] Value:val];
}

- (NSArray*)gameboardEmptySpots {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.dimension; ++i) {
        for (int j = 0; j < self.dimension; ++j) {
            TileObject* item = [self.gameboard getItem:i col:j];;
            if (item.eType == Empty) {
                NSNumber* x = [NSNumber numberWithInt:i];
                NSNumber* y = [NSNumber numberWithInt:j];
                NSArray* pos = @[x, y];
                [array addObject:pos];
            }
        }
    }
    return array;
}

- (BOOL)tileBelowHasSameValue:(int)x col:(int)y Value:(int)value {
    if (y == self.dimension - 1)
        return NO;
    
    TileObject* item = [self.gameboard getItem:x col:y + 1];
    if (item.eType == Tile && item.value == value)
        return YES;
    return NO;
}

- (BOOL)tileToRightHasSameValue:(int)x col:(int)y Value:(int)value {
    if (x == self.dimension - 1)
        return NO;
    
    TileObject* item = [self.gameboard getItem:x+1 col:y];
    if (item.eType == Tile && item.value == value)
        return YES;
    return NO;
}

- (BOOL)userHasLost {
    NSArray* array = [self gameboardEmptySpots];
    if (array.count != 0)
        return NO;
    
    for (int i = 0; i < self.dimension; ++i) {
        for (int j = 0; j < self.dimension; ++j) {
            TileObject* item = [self.gameboard getItem:i col:j];
            if (item.eType == Tile) {
                if ([self tileBelowHasSameValue:i col:j Value:item.value] ||
                    [self tileToRightHasSameValue:i col:j Value:item.value])
                    return NO;
            }
        }
    }
    return YES;
}

- (NSArray *)userHasWon {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.dimension; ++i) {
        for (int j = 0; j < self.dimension; ++j) {
            TileObject* item = [self.gameboard getItem:i col:j];
            if (item.eType == Tile && item.value >= self.threshold) {
                NSNumber* ok = [NSNumber numberWithBool:YES];
                NSArray* pos = @[[NSNumber numberWithInt:i], [NSNumber numberWithInt:j]];
                [array addObject:ok];
                [array addObject: pos];
                return array;
            }
        }
    }
    
    NSNumber* no = [NSNumber numberWithBool:NO];
    [array addObject:no];
    return array;
}

/*
 [self.model queueMove:MoveDirectionLeft completion:^(BOOL changed) {
 if (changed) {
 [self followUp];
 }
 }];

 */
- (BOOL)performMove:(MoveDirection)direction {
    typedef NSArray*(^coordinateGeneratorBlock)(int);
    
    coordinateGeneratorBlock coordinateGenerator = ^ NSArray*(int iteration) {
        NSMutableArray* buffer = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.dimension; ++i) {
            NSArray* item = @[[NSNumber numberWithInt:0], [NSNumber numberWithInt:0]];
            [buffer addObject:item];
        }
        
        for (int i = 0; i < self.dimension; ++i) {
            switch (direction) {
                case MoveDirectionUp:
                {
                    NSArray* item = @[[NSNumber numberWithInt:i], [NSNumber numberWithInt:iteration]];
                    buffer[i] = item;
                }
                    break;
                case MoveDirectionDown:
                {
                    NSArray* item = @[[NSNumber numberWithInt:self.dimension - i - 1], [NSNumber numberWithInt:iteration]];
                    buffer[i] = item;
                }
                    break;
                case MoveDirectionLeft:
                {
                    NSArray* item = @[[NSNumber numberWithInt:iteration], [NSNumber numberWithInt:i]];
                    buffer[i] = item;
                }
                    break;
                case MoveDirectionRight:
                {
                    NSArray* item = @[[NSNumber numberWithInt:iteration], [NSNumber numberWithInt:self.dimension - i - 1]];
                    buffer[i] = item;
                }
                    break;
            }
        }
        return buffer;
    };
 
    BOOL atLeastOneMove = NO;
    for (int i = 0; i < self.dimension; ++i) {
        NSArray* coords = coordinateGenerator(i);
        
        NSMutableArray* tiles = [[NSMutableArray alloc] init];
        for (NSArray* item in coords) {
            NSNumber* x = item[0];
            NSNumber* y = item[1];
            TileObject* obj = [self.gameboard getItem:x.intValue col:y.intValue];
            [tiles addObject:obj];
        }
        
        NSArray* orders = [self merge:tiles];
        atLeastOneMove = orders.count > 0 ? YES : atLeastOneMove;
        
        for (int i = 0; i < orders.count; ++i) {
            MoveOrderCommand* object = orders[i];
            if (object.eOrder == singleMoveOrder) {
                NSArray* sitem = coords[object.source];
                NSNumber* sx = sitem[0];
                NSNumber* sy = sitem[1];
                NSArray* ditem = coords[object.destination];
                NSNumber* dx = ditem[0];
                NSNumber* dy = ditem[1];
                if (object.wasMerge) {
                    [self setScore:self.score + object.value];
                }
                
                TileObject* tile =  [[TileObject alloc] init];
                tile.eType = Empty;
                [self.gameboard setItem:sx.intValue col:sy.intValue Value:tile];
                TileObject* vtile = [[TileObject alloc] init];
                vtile.eType = Tile;
                vtile.value = object.value;
                [self.gameboard setItem:dx.intValue col:dy.intValue Value:vtile];
                [self.delegate moveOneTile:sx.intValue fromY:sy.intValue toX:dx.intValue toY:dy.intValue Value:object.value];
            } else if (object.eOrder == doubleMoveOrder) {
                NSArray* s1item = coords[object.firstSource];
                NSNumber* s1x = s1item[0];
                NSNumber* s1y = s1item[1];
                NSArray* s2item = coords[object.secondSource];
                NSNumber* s2x = s2item[0];
                NSNumber* s2y = s2item[1];
                NSArray* dest = coords[object.destination];
                NSNumber* dx = dest[0];
                NSNumber* dy = dest[1];
                [self setScore:self.score + object.value];
                
                TileObject* t1 = [[TileObject alloc] init];
                t1.eType = Empty;
                [self.gameboard setItem:s1x.intValue col:s1y.intValue Value:t1];
                
                TileObject* t2 = [[TileObject alloc] init];
                t2.eType = Empty;
                [self.gameboard setItem:s2x.intValue col:s2y.intValue Value:t2];
                
                TileObject* tv = [[TileObject alloc] init];
                tv.eType = Tile;
                tv.value = object.value;
                [self.gameboard setItem:dx.intValue col:dy.intValue Value:tv];
                
                [self.delegate moveTwoTiles:s1x.intValue fromAY:s1y.intValue frombX:s2x.intValue fromby:s2y.intValue toX:dx.intValue toY:dy.intValue Value:object.value];
            }
        }
    }
    
    return atLeastOneMove;
}

- (NSArray*)condense:(NSArray*)group {
    NSMutableArray* tokenBuffer = [[NSMutableArray alloc] init];
    for (int i = 0; i < group.count; ++i) {
        TileObject* tile = group[i];
        if (tile.eType == Tile && tokenBuffer.count == i) {
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:NoAction Source:i Value:tile.value]];
        } else if (tile.eType == Tile) {
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:Move Source:i Value:tile.value]];
        }
    }
    return tokenBuffer;
}

- (NSArray*)collapse:(NSArray*)group {
    NSMutableArray* tokenBuffer = [[NSMutableArray alloc] init];
    BOOL skipNext = NO;
    for (int i = 0; i < group.count; ++i) {
        if (skipNext) {
            skipNext = NO;
            continue;
        }
        ActionTokenCommand* token = group[i];
        if (token.eAction == SingleCombine) {
        } else if (token.eAction == DoubleCombine) {
        } else if (token.eAction == NoAction &&
                   i < group.count - 1 &&
                   token.value == ((ActionTokenCommand*)(group[i + 1])).value &&
                   [self quiescentTileStillQuiescent:i outputLength:tokenBuffer.count originalPosition:token.source]) {
            ActionTokenCommand* next = group[i + 1];
            int nv = token.value + next.value;
            skipNext = YES;
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:SingleCombine Source:next.source Value:nv]];
        } else if (i < group.count - 1 && token.value == ((ActionTokenCommand*)(group[i + 1])).value) {
            ActionTokenCommand* next = group[i + 1];
            int nv = token.value + next.value;
            skipNext = YES;
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:DoubleCombine Source:token.source Second:next.source Value:nv]];
        } else if (token.eAction == NoAction && ![self quiescentTileStillQuiescent:i outputLength:tokenBuffer.count originalPosition:token.source]) {
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:Move Source:token.source Value:token.value]];
        } else if (token.eAction == NoAction) {
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:NoAction Source:token.source Value:token.value]];
        } else if (token.eAction == Move) {
            [tokenBuffer addObject:[[ActionTokenCommand alloc] init:Move Source:token.source Value:token.value]];
        }
    }
    
    return tokenBuffer;
}

- (NSArray*)convert:(NSArray*)group {
    NSMutableArray* moveBuffer = [[NSMutableArray alloc] init];
    for (int i = 0; i < group.count; ++i) {
        ActionTokenCommand* cmd = group[i];
        if (cmd.eAction == Move) {
            [moveBuffer addObject:[[MoveOrderCommand alloc] init:cmd.source destionation:i Value:cmd.value wasMerge:NO]];
        } else if (cmd.eAction == SingleCombine) {
            [moveBuffer addObject:[[MoveOrderCommand alloc] init:cmd.source destionation:i Value:cmd.value wasMerge:YES]];
        } else if (cmd.eAction == DoubleCombine) {
            [moveBuffer addObject:[[MoveOrderCommand alloc] init:cmd.source secondSource:cmd.second destionation:i Value:cmd.value]];
        }
    }
    
    return moveBuffer;
}

- (NSArray*)merge:(NSArray*)group {
    return [self convert:[self collapse:[self condense:group]]];
}

- (BOOL)quiescentTileStillQuiescent:(int)inputPosition outputLength:(int)outputLength originalPosition:(int)originalPosition {
    return (inputPosition == outputLength) && (originalPosition == inputPosition);
}

@end
