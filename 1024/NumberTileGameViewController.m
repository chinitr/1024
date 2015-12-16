//
//  NumberTileGameViewController.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "NumberTileGameViewController.h"
#import "GameboardView.h"
#import "GameModel.h"
#import "ScoreView.h"

@interface NumberTileGameViewController ()

@property (nonatomic) int dimension;
@property (nonatomic) int threshold;

@property (nonatomic) GameboardView* board;
@property (nonatomic) GameModel* model;

@property (nonatomic) ScoreView* scoreView;/////

@property (nonatomic) CGFloat boardWidth;
@property (nonatomic) CGFloat thinPadding;
@property (nonatomic) CGFloat thickPadding;

@property (nonatomic) CGFloat viewPadding;

@property (nonatomic) CGFloat verticalViewOffset;

@end

@implementation NumberTileGameViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)init:(int)dimension threshold:(int)threshhold {
    self = [super init];
    if (self != nil) {
        _boardWidth = 230.0;
        _thinPadding = 3.0;
        _thickPadding = 6.0;
        _viewPadding = 10.0;
        _verticalViewOffset = 0.0;
        
        _dimension = dimension > 2 ? dimension : 2;
        _threshold = threshhold > 8 ? threshhold : 8;
        _model = [[GameModel alloc] init:dimension threshhold:threshhold Delegate:self];
        self.view.backgroundColor = [UIColor whiteColor];
        [self setupSwipeControls];
        
    }
    return self;
}

- (void)setupSwipeControls {
    UISwipeGestureRecognizer* up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(up:)];
    up.numberOfTouchesRequired = 1;
    up.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:up];
    
    UISwipeGestureRecognizer* down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(down:)];
    down.numberOfTouchesRequired = 1;
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:down];
    
    UISwipeGestureRecognizer* left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(left:)];
    left.numberOfTouchesRequired = 1;
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:left];
    
    UISwipeGestureRecognizer* right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(right:)];
    right.numberOfTouchesRequired = 1;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:right];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGame];
}

- (void)reset {
    if (self.board != nil) {
        [self.board reset];
    }
    if (self.model != nil) {
        [self.model reset];
        [self.model insertTileAtRandomLocation:2];
        [self.model insertTileAtRandomLocation:2];
    }    
}

- (void)setupGame {
    CGFloat vcHeight = self.view.bounds.size.height;
    CGFloat vcWidth = self.view.bounds.size.width;

    CGFloat(^xPositionToCenterView)(UIView*) = ^CGFloat(UIView* v) {
        CGFloat viewWidth = v.bounds.size.width;
        CGFloat tentativeX = 0.5*(vcWidth - viewWidth);
        return tentativeX >= 0 ? tentativeX : 0;
    };
    
    CGFloat(^yPositionForViewAtPosition)(int, NSArray*) = ^CGFloat(int order, NSArray* views) {
        CGFloat totalHeight = (views.count - 1)*self.viewPadding;
        totalHeight += self.verticalViewOffset;
        for (UIView* v in views) {
            totalHeight += v.bounds.size.height;
        }
        CGFloat viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0;
        CGFloat acc = 0.0;
        for (int i = 0; i < order; ++i) {
            UIView* view = views[i];
            acc += self.viewPadding + view.bounds.size.height;
        }
        return viewsTop + acc;
    };
    
    ScoreView* scoreView = [[ScoreView alloc] init:[UIColor blackColor] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16.0] radius:6];
    [scoreView setScore:0];
    
    CGFloat padding = self.dimension > 5 ? self.thinPadding : self.thickPadding;
    CGFloat v1 = self.boardWidth - padding*(self.dimension + 1);
    CGFloat width =  floorf(v1)/self.dimension;
    GameboardView* gameboard = [[GameboardView alloc] init:self.dimension tileWidth:width tilePadding:padding cornerRadius:6 backgroundColor:[UIColor blackColor] foregroundColor:[UIColor darkGrayColor]];
    
    NSArray* views = @[scoreView, gameboard];
    CGRect f = scoreView.frame;
    f.origin.x = xPositionToCenterView(scoreView);
    f.origin.y = yPositionForViewAtPosition(0, views);
    scoreView.frame = f;
    
    f = gameboard.frame;
    f.origin.x = xPositionToCenterView(gameboard);
    f.origin.y = yPositionForViewAtPosition(1, views);
    gameboard.frame = f;
    
    [self.view addSubview:gameboard];
    self.board = gameboard;
    [self.view addSubview:scoreView];
    self.scoreView = scoreView;
    
    [self.model insertTileAtRandomLocation:2];
    [self.model insertTileAtRandomLocation:2];
}

- (void)followUp {
//    if (self.model != nil) {
    NSArray* win = [self.model userHasWon];
    if (win.count == 2) {
            UIAlertView* view = [[UIAlertView alloc] init];
            view.title = @"victory";
            view.message = @"you won";
            [view addButtonWithTitle:@"calcel"];
            [view show];
        }
    
    int randomVal = arc4random_uniform(10);
    [self.model insertTileAtRandomLocation:randomVal == 1 ? 4 : 2];
    
    if ([self.model userHasLost]) {
        UIAlertView* view = [[UIAlertView alloc] init];
        view.title = @"defeat";
        view.message = @"you lost...";
        [view addButtonWithTitle:@"cancel"];
        [view show];
    }
 //   }
}

- (void)up:(UIGestureRecognizer*)ges {
    if (self.model != nil) {
        [self.model queueMove:MoveDirectionUp completion:^(BOOL changed) {
            if (changed) {
                [self followUp];
            }
        }];
    }
}

- (void)down:(UIGestureRecognizer*)ges {
    if (self.model != nil) {
        [self.model queueMove:MoveDirectionDown completion:^(BOOL changed) {
            if (changed) {
                [self followUp];
            }
        }];
    }
}

- (void)left:(UIGestureRecognizer*)ges {
    if (self.model != nil) {
        [self.model queueMove:MoveDirectionLeft completion:^(BOOL changed) {
            if (changed) {
                [self followUp];
            }
        }];
    }
}

- (void)right:(UISwipeGestureRecognizer*)ges {
    if (self.model != nil) {
        [self.model queueMove:MoveDirectionRight completion:^(BOOL changed) {
            if (changed) {
                [self followUp];
            }
        }];
    }
}

- (void)scoreChanged:(int)score {
    if (self.scoreView != nil) {
        [self.scoreView scoreChanged:score];
    }
}

- (void)moveOneTile:(int)fromX fromY:(int)fromy toX:(int)tox toY:(int)toy Value:(int)value {
    if (self.board != nil) {
        [self.board moveOneTile:fromX fromY:fromy toX:tox toY:toy value:value];
    }
}

- (void)moveTwoTiles:(int)fromAX fromAY:(int)fromay frombX:(int)frombx fromby:(int)fromby toX:(int)tox toY:(int)toy Value:(int)value {
    if (self.board != nil) {
        [self.board moveTwoTiles:fromAX fromColA:fromay fromColB:frombx fromby:fromby toX:tox toY:toy Value:value];
    }
}

- (void)insertTile:(int)locationX locationY:(int)locationy Value:(int)value {
    if (self.board != nil) {
        [self.board insertTile:locationX toY:locationy Value:value];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
