//
//  MiscModel.m
//  1024
//
//  Created by bugme on 12/16/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "MiscModel.h"

@implementation CommandObject
-(instancetype)init:(MoveDirection)direction completion:(queueMoveCompletionBlock)block {
    self = [super init];
    if (self != nil) {
        _direction = direction;
        _block = block;
    }
    return self;
}
@end

@implementation MoveOrderCommand

-(instancetype)init:(int)source destionation:(int)dest Value:(int)value wasMerge:(BOOL)wasmerge {
    self = [super init];
    if (self != nil) {
        _eOrder = singleMoveOrder;
        _source = source;
        _destination = dest;
        _value = value;
        _wasMerge = wasmerge;
    }
    return self;
}

- (instancetype)init:(int)firstSource secondSource:(int)second destionation:(int)dest Value:(int)value {
    self = [super init];
    if (self != nil) {
        _eOrder = doubleMoveOrder;
        _firstSource = firstSource;
        _secondSource = second;
        _destination = dest;
        _value = value;
    }
    return self;
}

@end

@implementation TileObject

@end

@implementation ActionTokenCommand

- (instancetype)init:(ActionToken)eaction Source:(int)source Value:(int)value {
    self = [super init];
    if (self != nil) {
        _eAction = eaction;
        _source = source;
        _value = value;
    }
    return self;
}

- (instancetype)init:(ActionToken)action Source:(int)source Second:(int)second Value:(int)value {
    self = [super init];
    if (self != nil) {
        _eAction = action;
        _source = source;
        _second = second;
        _value = value;
    }
    return self;
}

@end

@implementation SquareGameboard

- (instancetype)init:(int)dimension initValue:(TileType)value {
    self = [super init];
    if (self != nil) {
        _dimension = dimension;
        _boardArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < dimension*dimension; ++i) {
            TileObject* item = [[TileObject alloc] init];
            item.eType = Empty;
            [_boardArray addObject:item];
        }
    }
    return self;
}

- (TileObject *)getItem:(int)x col:(int)y {
    return self.boardArray[x*self.dimension + y];
}

- (void)setItem:(int)x col:(int)y Value:(TileObject*)val {
    self.boardArray[x*self.dimension + y] = val;
}

- (void)setAll:(TileObject *)item {
    for (int i = 0; i < self.dimension; ++i) {
        for (int j = 0; j < self.dimension; ++j) {
            [self setItem:i col:j Value:item];
        }
    }
}

@end


