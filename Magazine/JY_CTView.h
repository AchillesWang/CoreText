//
//  JY_CTView.h
//  Magazine
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//
@import CoreText;
#import "JY_CTColumnView.h"


@interface JY_CTView : UIScrollView<UIScrollViewDelegate>{
    CGFloat _frameXOffset;
    CGFloat _frameYOffset;
}

@property(nonatomic,copy) NSAttributedString* attString;

@property(nonatomic,strong) NSMutableArray* frames;

@property(nonatomic,strong) NSArray* images;

-(void)setAttString:(NSAttributedString *)attString withImages:(NSArray*)imgs;

-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(JY_CTColumnView*)col;

-(void)buildFrames;

@end
