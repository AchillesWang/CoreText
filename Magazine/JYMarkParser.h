//
//  JYMarkParser.h
//  Magazine
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface JYMarkParser : NSObject

@property(strong,nonatomic) NSString* font;
@property(strong,nonatomic) UIColor* color;
@property(strong,nonatomic) UIColor* strokeColor;
@property(assign,readwrite) float strokeWidth;
@property(strong,nonatomic) NSMutableArray* images;

-(NSAttributedString*)attrStringFromMark:(NSString*)html;
@end
