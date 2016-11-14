//
//  ViewController.m
//  TestLogger
//
//  Created by Radha on 14/11/16.
//  Copyright © 2016 Rapid. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)checkLogTapped:(id)sender;

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


- (IBAction)checkLogTapped:(id)sender {
    NSLog(@"checkLogTapped called");
}
@end
