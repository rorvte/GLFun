//
//  ViewController.m
//  GLFun
//
//  Created by yolanda yuan on 7/3/2017.
//  Copyright © 2017 yolanda yuan. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    OpenGLView *cv = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:cv];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
