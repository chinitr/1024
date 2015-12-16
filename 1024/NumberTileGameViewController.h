//
//  NumberTileGameViewController.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"

@interface NumberTileGameViewController : UIViewController<GameModelProtocol>

- (instancetype)init:(int)dimension threshold:(int)threshhold;

@end
