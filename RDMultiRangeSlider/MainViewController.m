//
//  RDViewController.m
//  RDMultiRangeSlider
//
//  Created by Richard Das on 18/3/13.
//  Copyright (c) 2013 RNA Productions, Ltd. All rights reserved.
//

#import "MainViewController.h"

#import "RDMultiRangeSlider.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    RDMultiRangeSlider *rangeSlider = [[RDMultiRangeSlider alloc] initWithFrame:CGRectInset( self.view.frame, 15, 0 )];
    [self.view addSubview:rangeSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
