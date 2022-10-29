//
//  MLTestCController.m
//  MLeaksPing_Example
//
//  Created by tanxl on 2022/10/29.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

#import "MLTestCController.h"

@interface MLTestCView1: UIView

@property (nonatomic, weak) UIView *view;
@property (nonatomic, copy) void(^TestViewBlock)( );

@end

@interface MLTestCView2: UIView

@property (nonatomic, weak) UIView *view;
@property (nonatomic, copy) void(^TestViewBlock)( );

@end

@interface MLTestCController ()
{
    MLTestCView1 *_testView1;
    MLTestCView2 *_testView2;
}

@end

@implementation MLTestCController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    _testView1 = [[MLTestCView1 alloc] init];
    _testView2 = [[MLTestCView2 alloc] init];
    
    [self.view addSubview:_testView1];
    [self.view addSubview:_testView2];
    
    _testView1.TestViewBlock = ^{
        [_testView2 class];
    };
    _testView2.TestViewBlock = ^{
        [_testView1 class];
    };
    _testView1.TestViewBlock();
    _testView2.TestViewBlock();
}

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end

@implementation MLTestCView1

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end

@implementation MLTestCView2

- (void)dealloc {
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class));
}

@end
