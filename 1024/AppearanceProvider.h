//
//  AppearanceProvider.h
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AppearanceProviderProtocol <NSObject>

- (UIColor*)tileColor:(int)value;
- (UIColor*)numberColor:(int)value;
- (UIFont*)fontForNumbers;

@end

@interface AppearanceProvider : NSObject <AppearanceProviderProtocol>

@end
