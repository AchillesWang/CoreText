//
//  JY_CTColumnView.m
//  Magazine
//
//  Created by 汪潇翔 on 14-5-12.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import "JY_CTColumnView.h"
@import CoreText;

@implementation JY_CTColumnView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.images = [NSMutableArray array];
    }
    return self;
}
-(void)setCTFrame:(id)f
{
    _ctFrame = f;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef conRef = UIGraphicsGetCurrentContext();
    //flip the coordinate system
    CGContextSetTextMatrix(conRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(conRef, 0, self.bounds.size.height);
    CGContextScaleCTM(conRef, 1.0, -1.0);
    
    CTFrameDraw((__bridge CTFrameRef)_ctFrame, conRef);
    
    for (NSArray* imageData in self.images) {
        UIImage* img = [imageData objectAtIndex:0];
        CGRect imgBounds = CGRectFromString([imageData objectAtIndex:1]);
//        NSLog(@"%@",NSStringFromCGRect(imgBounds));
        
        CGContextDrawImage(conRef, imgBounds, img.CGImage);
    }
}

@end
