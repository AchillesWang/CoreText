//
//  JY_CTColumnView.h
//  Magazine
//
//  Created by 汪潇翔 on 14-5-12.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JY_CTColumnView : UIView
{
    id _ctFrame;
}
-(void)setCTFrame:(id)f;

@property(nonatomic,strong) NSMutableArray *images;



@end
