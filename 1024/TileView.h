//
//  TileView.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppearanceProvider.h"

@interface TileView : UIView

- (instancetype)init:(CGPoint)position width:(CGFloat)width Value:(int)value radius:(int)radius Delegate:(id<AppearanceProviderProtocol>) delegate;

@property (weak, nonatomic)id<AppearanceProviderProtocol> delegate;

@property (nonatomic)int value;
@property (nonatomic)UILabel* numberLabel;

@end
