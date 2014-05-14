//
//  JYViewController.m
//  Magazine
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import "JYViewController.h"
#import "JY_CTView.h"
#import "JYMarkParser.h"

@interface JYViewController()

@property (weak, nonatomic) IBOutlet JY_CTView *contentView;

@end

@implementation JYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"zombies" ofType:@"txt"]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    JYMarkParser* mp = [[JYMarkParser alloc]init];
    NSAttributedString* attString =[mp attrStringFromMark:string];
    
    [_contentView setAttString:attString withImages:mp.images];
    [_contentView buildFrames];
	// Do any additional setup after loading the view, typically from a nib.
}

@end
