//
//  MLTestBController.m
//  MLeaksPing_Example
//
//  Created by tanxl on 2022/10/29.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "MLTestBController.h"

@interface MLTestBController ()

@property (nonatomic, copy) void(^Block)(UIViewController *controller);

@end

@implementation MLTestBController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.Block = ^(UIViewController *controller) {
        self.title = @"gg返回";
    };
    
    self.Block(self);
}

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end
