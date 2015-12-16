//
//  MiscModel.h
//  1024
//
//  Created by bugme on 12/16/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MoveDirectionUp,
    MoveDirectionDown,
    MoveDirectionLeft,
    MoveDirectionRight,
} MoveDirection;

typedef void(^queueMoveCompletionBlock)(BOOL);

typedef enum {
    direction = 0,
    completion,
} MoveCommand;

@interface CommandObject : NSObject
- (instancetype)init:(MoveDirection)direction completion:(queueMoveCompletionBlock)block;

@property (nonatomic, readonly)MoveDirection direction;
@property (nonatomic, readonly)queueMoveCompletionBlock block;
@end

typedef enum {
    singleMoveOrder = 0,
    doubleMoveOrder,
} MoveOrder;

@interface MoveOrderCommand : NSObject
- (instancetype)init:(int)source destionation:(int)dest Value:(int)value wasMerge:(BOOL)wasmerge;
- (instancetype)init:(int)firstSource secondSource:(int)second destionation:(int)dest Value:(int)value;

@property (nonatomic)MoveOrder eOrder;
@property (nonatomic)int value;
@property (nonatomic)int destination;

@property (nonatomic)int source;
@property (nonatomic)int wasMerge;

@property (nonatomic)int firstSource;
@property (nonatomic)int secondSource;
@end

typedef enum {
    Empty = 0,
    Tile,
} TileType;

@interface TileObject : NSObject
@property (nonatomic)TileType eType;
@property (nonatomic)int value;
@end

typedef enum{
    NoAction = 0,
    Move,
    SingleCombine,
    DoubleCombine,
} ActionToken;

@interface ActionTokenCommand : NSObject
- (instancetype)init:(ActionToken)eaction Source:(int)source Value:(int)value;
- (instancetype)init:(ActionToken)action Source:(int)source Second:(int)second Value:(int)value;
@property (nonatomic)ActionToken eAction;
@property (nonatomic)int source;
@property (nonatomic)int second;
@property (nonatomic)int value;
@end

@interface SquareGameboard : NSObject

- (instancetype)init:(int)dimension initValue:(TileType)value;
- (TileObject*)getItem:(int)x col:(int)y;
- (void)setItem:(int)x col:(int)y Value:(TileObject*)val;
- (void)setAll:(TileObject*)item;
@property (nonatomic)int dimension;
@property (nonatomic)NSMutableArray* boardArray;

@end

