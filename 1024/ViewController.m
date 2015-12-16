//
//  ViewController.m
//  1024
//
//  Created by bugme on 12/12/15.
//  Copyright © 2015 bugme. All rights reserved.
//

#import "ViewController.h"
#import "NumberTileGameViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStartGame:(id)sender {
    NumberTileGameViewController* vc = [[NumberTileGameViewController alloc] init:4 threshold:128];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
