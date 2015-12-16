//
//  GameModel.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MiscModel.h"

@protocol GameModelProtocol <NSObject>

- (void)scoreChanged:(int)score;
- (void)moveOneTile:(int)fromX fromY:(int)fromy toX:(int)tox toY:(int)toy Value:(int)value;
- (void)moveTwoTiles:(int)fromAX fromAY:(int)fromay frombX:(int)frombx fromby:(int)fromby toX:(int)tox toY:(int)toy Value:(int)value;
- (void)insertTile:(int)locationX locationY:(int)locationy Value:(int)value;

@end

@interface GameModel : NSObject

- (instancetype)init:(int)dimension threshhold:(int)t Delegate:(id<GameModelProtocol>)delegate;

- (NSArray*)userHasWon;
- (BOOL)userHasLost;

- (void)queueMove:(MoveDirection)direction completion:(queueMoveCompletionBlock)block;
- (void)reset;
- (void)insertTileAtRandomLocation:(int)val;

@end
