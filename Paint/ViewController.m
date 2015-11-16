//
//  ViewController.m
//  Paint
//
//  Created by Zhuoran Li on 11/16/15.
//  Copyright © 2015 Zhuoran Li. All rights reserved.
//

#import "ViewController.h"
#import "PaintView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PaintView *paintView = [[PaintView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:paintView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
