//
//  JYMarkParser.m
//  Magazine
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import "JYMarkParser.h"


#if 0
/* CallBacks */
static void deallocCallback(void* ref){
    ref = nil;
}
static CGFloat ascentCallback( void *ref ){
    return [(NSString *)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
     return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}
#else
/* Callbacks */
static void deallocCallback( void* ref ){
    ref =nil;
}
static CGFloat ascentCallback( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
    return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}
#endif


@implementation JYMarkParser
-(id)init
{
    self = [super init];
    if (self) {
        self.font = @"ArialMT";
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

-(NSAttributedString*)attrStringFromMark:(NSString*)mark
{
    if (!mark) {
        return nil;
    }
    NSMutableAttributedString* aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSError* error = nil;
    //(.*?).通配符 *？匹配上一个元素零次或多次，但次数尽可能少。
    //^匹配必须从字符串或一行的开头开始。
    //<>的位置
    NSRegularExpression* regex = [[NSRegularExpression alloc]initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                            error:&error];
    
    NSArray* chunks = [regex matchesInString:mark options:0 range:NSMakeRange(0, mark.length)];
    if (error) {
        NSLog(@"解析标签出现错误:%@\n%@",[error userInfo],error);
        //返回原来的字符串
        return [[NSAttributedString alloc] initWithString:mark];
    }
//    NSLog(@"%@",chunks);
    for (NSTextCheckingResult* result in chunks) {
        //字符串切割
        NSArray* parts = [[mark substringWithRange:result.range] componentsSeparatedByString:@"<"];//1;
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font, 24.0f, NULL);
        //apply the current text style //2
        NSDictionary* attrs = @{(id)kCTForegroundColorAttributeName: (id)self.color.CGColor,
                                (id)kCTFontAttributeName:(__bridge id)fontRef,
                                (id)kCTStrokeColorAttributeName:(__bridge id)self.strokeColor.CGColor,
                                (id)kCTStrokeWidthAttributeName:[NSNumber numberWithFloat:self.strokeWidth]};
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:parts[0] attributes:attrs]];
        CFRelease(fontRef);
        //是否带属性
        if (parts.count>1) {
            NSString* tag = parts[1];
            //文字修改
            if ([tag hasPrefix:@"font"]) {
                //stroke color
                NSRegularExpression* scReg = [[NSRegularExpression alloc]initWithPattern:@"(?<=strokeColor=\")\\w+"
                                                                                 options:0
                                                                                   error:nil];
                [scReg enumerateMatchesInString:tag
                                        options:0
                                          range:NSMakeRange(0, tag.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         if ([[tag substringWithRange:result.range] isEqualToString:@"none"]) {
                                             self.strokeWidth = 0.0;
                                         }else{
                                             self.strokeWidth = -3.0;
                                             SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[tag substringWithRange:result.range]]);
                                             self.strokeColor = [UIColor performSelector:colorSel];
                                         }
                                     }];
                //Color
                NSRegularExpression* colorReg = [[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")\\w+"
                                                                                     options:0
                                                                                       error:nil];
                [colorReg enumerateMatchesInString:tag options:0
                                          range:NSMakeRange(0, tag.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:result.range]]);
                                         self.color = [UIColor performSelector:colorSel];
                                     }];
                //face
                NSRegularExpression* faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:NULL];
                [faceRegex enumerateMatchesInString:tag
                                            options:0
                                              range:NSMakeRange(0, [tag length])
                                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                                             self.font = [tag substringWithRange:match.range];
                                         }];
                //end of font parsing 结束字体解析
            }
#if 0
            if ([tag hasPrefix:@"img"]) {
                __block NSNumber* width     = @(0);
                __block NSNumber* height    = @(0);
                __block NSString* fileName  = nil;
                //width
                NSRegularExpression* widthRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+"
                                                                                       options:0
                                                                                         error:nil];
                [widthRegex enumerateMatchesInString:tag
                                             options:0
                                               range:NSMakeRange(0, tag.length)
                                          usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                              width = [NSNumber numberWithFloat:[[tag substringWithRange:result.range] floatValue]];
                                          }];
                //height
                NSRegularExpression* heightRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+"
                                                                                        options:0
                                                                                          error:nil];
                [heightRegex enumerateMatchesInString:tag
                                              options:0
                                                range:NSMakeRange(0, tag.length)
                                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                               height = [NSNumber numberWithFloat:[[tag substringWithRange:result.range] floatValue]];
                                           }];
                
                //fileName
                NSRegularExpression* srcRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=src=\")[^\"]+"
                                                                                     options:0
                                                                                       error:nil];
                [srcRegex enumerateMatchesInString:tag
                                           options:0
                                             range:NSMakeRange(0, tag.length)
                                        usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                            fileName = [tag substringWithRange:result.range];
                                        }];
                //add the image for drawing
                [self.images addObject:@{@"width": width,
                                         @"height":height,
                                         @"fileName":fileName,
                                         @"location":@(aString.length)}];
                NSLog(@"%@",@{@"width": width,
                               @"height":height,
                               @"fileName":fileName,
                               @"location":@(aString.length)});
                
                //render empty space for drawing the image in the text //1
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                NSDictionary* imgAttr = @{@"width": width,@"height":height};//2
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imgAttr));//3
                NSDictionary* attrDictionaryDelegate =  @{(__bridge NSString *)kCTRunDelegateAttributeName: (__bridge id)delegate};
                //add a space to the text so that it can call the delegate
                [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:attrDictionaryDelegate]];
            }
#else
    if ([tag hasPrefix:@"img"]) {
        
        __block NSNumber* width = [NSNumber numberWithInt:0];
        __block NSNumber* height = [NSNumber numberWithInt:0];
        __block NSString* fileName = @"";
        
        //width
        NSRegularExpression* widthRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+" options:0 error:NULL] ;
        [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            width = [NSNumber numberWithInt: [[tag substringWithRange: match.range] intValue] ];
        }];
        
        //height
        NSRegularExpression* faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+" options:0 error:NULL] ;
        [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            height = [NSNumber numberWithInt: [[tag substringWithRange:match.range] intValue]];
        }];
        
        //image
        NSRegularExpression* srcRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=src=\")[^\"]+" options:0 error:NULL];
        [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            fileName = [tag substringWithRange: match.range];
        }];
        
        //add the image for drawing
        [self.images addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:
          width, @"width",
          height, @"height",
          fileName, @"fileName",
          [NSNumber numberWithInt: [aString length]], @"location",
          nil]
         ];
//        NSLog(@"%@", [NSDictionary dictionaryWithObjectsAndKeys:
//                      width, @"width",
//                      height, @"height",
//                      fileName, @"fileName",
//                      [NSNumber numberWithInt: [aString length]], @"location",
//                      nil]);
        
        //render empty space for drawing the image in the text //1
        CTRunDelegateCallbacks callbacks;
        callbacks.version = kCTRunDelegateVersion1;
        callbacks.getAscent = ascentCallback;
        callbacks.getDescent = descentCallback;
        callbacks.getWidth = widthCallback;
        callbacks.dealloc = deallocCallback;
        
        NSDictionary* imgAttr = [NSDictionary dictionaryWithObjectsAndKeys: //2
                                  width, @"width",
                                  height, @"height",
                                  nil];
        
        CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imgAttr)); //3
        NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:
                                                //set the delegate
                                                (__bridge id)delegate, (NSString*)kCTRunDelegateAttributeName,
                                                nil];
        
        //add a space to the text so that it can call the delegate
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate]];
    }
#endif
        }
    }
    return aString;
}

-(void)dealloc
{
    self.font = nil;
    self.color = nil;
    self.strokeColor = nil;
    self.images = nil;
}
@end
