//
//  UIImage+Des.m
//  Magazine
//
//  Created by 汪潇翔 on 14-5-13.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import "UIImage+Des.h"

@implementation UIImage (Des)
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",NSStringFromCGSize(self.size)];
}
@end
