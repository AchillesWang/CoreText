//
//  JY_CTView.m
//  Magazine
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import "JY_CTView.h"
#import <CoreText/CoreText.h>
#import "JY_CTColumnView.h"
#import "UIImage+Des.h"



@implementation JY_CTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


-(void)setAttString:(NSAttributedString *)attString withImages:(NSArray *)imgs
{
    self.images = imgs;
    CTTextAlignment alignment = kCTJustifiedTextAlignment;
    
    CTParagraphStyleSetting settings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)paragraphStyle, (NSString*)kCTParagraphStyleAttributeName,
                                    nil];
    
    NSMutableAttributedString* stringCopy = [[NSMutableAttributedString alloc] initWithAttributedString:attString];
    [stringCopy addAttributes:attrDictionary range:NSMakeRange(0, [attString length])];
    self.attString = (NSAttributedString*)stringCopy;
}
#if 0
-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(JY_CTColumnView *)col
{
    //drawing image
    NSArray *lines = (__bridge NSArray*)CTFrameGetLines(f);//1
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins);//2
#if 0
    for (int i=0; i<lines.count; i++) {
        NSLog(@"%@",NSStringFromCGPoint(origins[i]));
    }
#endif
    
    int imgIndex = 0;
    NSDictionary* nextImage = [self.images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] integerValue];
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f);
    while (imgLocation<frameRange.location) {
        imgIndex++;
        if (imgIndex>=self.images.count) {
            return;
        }
        nextImage = [self.images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] integerValue];
    }
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) {
        
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (__bridge NSArray*)CTLineGetGlyphRuns(line)) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            if (runRange.location<=imgLocation&&runRange.location+runRange.length>imgLocation) {
                CGRect runBounds;
                CGFloat ascent;//height above the baseline
                CGFloat descent;//height below the baseline
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                runBounds.size.height = ascent+descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.x = origins[lineIndex].x+self.frame.origin.x+xOffset+_frameXOffset;
                runBounds.origin.y = origins[lineIndex].y+self.frame.origin.y+_frameYOffset;
                runBounds.origin.y -=descent;
                UIImage* image = [UIImage imageNamed:[nextImage objectForKey:@"fileName"]];
                CGPathRef pathRef = CTFrameGetPath(f);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x-_frameXOffset-self.contentOffset.x, colRect.origin.y-_frameYOffset-self.frame.origin.y);
                
                [col.images addObject:@[image,NSStringFromCGRect(imgBounds)]];
                imgIndex++;
                if (imgIndex<self.images.count) {
                    nextImage = [self.images objectAtIndex:imgIndex];
                    imgLocation = [[nextImage objectForKey:@"location"] intValue];
                }
            }
        }
        lineIndex++;
    }
    
}
#else
-(void)attachImagesWithFrame:(CTFrameRef)f inColumnView:(JY_CTColumnView*)col
{
    //drawing images
    NSArray *lines = (NSArray *)CTFrameGetLines(f); //1
    
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(f, CFRangeMake(0, 0), origins); //2
    
    int imgIndex = 0; //3
    NSDictionary* nextImage = [self.images objectAtIndex:imgIndex];
    int imgLocation = [[nextImage objectForKey:@"location"] intValue]; //图片在字符串中的位置
    //find images for the current column
    CFRange frameRange = CTFrameGetVisibleStringRange(f); //4
    while ( imgLocation < frameRange.location ) {
        imgIndex++;
        if (imgIndex>=[self.images count]) return; //quit if no images for this column
        nextImage = [self.images objectAtIndex:imgIndex];
        imgLocation = [[nextImage objectForKey:@"location"] intValue];
    }
//    NSLog(@"%d",imgLocation);
    NSUInteger lineIndex = 0;
    for (id lineObj in lines) { //5
        CTLineRef line = (__bridge CTLineRef)lineObj;
        
        for (id runObj in (NSArray *)CTLineGetGlyphRuns(line)) { //6
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange runRange = CTRunGetStringRange(run);
            
            if ( runRange.location <= imgLocation && runRange.location+runRange.length > imgLocation ) { //7
	            CGRect runBounds;
	            CGFloat ascent;//height above the baseline
	            CGFloat descent;//height below the baseline
	            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
	            runBounds.size.height = ascent + descent;
                
	            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
	            runBounds.origin.x = origins[lineIndex].x + self.frame.origin.x + xOffset + _frameXOffset;
	            runBounds.origin.y = origins[lineIndex].y + self.frame.origin.y + _frameYOffset;
	            runBounds.origin.y -= descent;
                
                UIImage *img = [UIImage imageNamed: [nextImage objectForKey:@"fileName"] ];
                CGPathRef pathRef = CTFrameGetPath(f); //10
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect imgBounds = CGRectOffset(runBounds, colRect.origin.x - _frameXOffset - self.contentOffset.x, colRect.origin.y - _frameYOffset - self.frame.origin.y);
                [col.images addObject: //11
                 [NSArray arrayWithObjects:img, NSStringFromCGRect(imgBounds) , nil]
                 ];
                //load the next image //12
                imgIndex++;
                if (imgIndex < [self.images count]) {
                    nextImage = [self.images objectAtIndex: imgIndex];
                    imgLocation = [[nextImage objectForKey: @"location"] intValue];
                }
                
            }
        }
        lineIndex++;
    }
}
#endif
-(void)buildFrames{
    self.backgroundColor = [UIColor whiteColor];
    _frameXOffset = 20; //1
    _frameYOffset = 20;
    self.pagingEnabled = YES;
    
    self.delegate = self;
    self.frames = [NSMutableArray array];

    CGMutablePathRef path = CGPathCreateMutable();//2
    CGRect textFrame = CGRectInset(self.bounds, _frameXOffset, _frameYOffset);
    CGPathAddRect(path, NULL, textFrame);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attString);
    
    int textPos = 0;//3
    int  columnIndex = 0;
    while (textPos<self.attString.length) {//4
        CGPoint colOffset = CGPointMake((columnIndex+1)*_frameXOffset+columnIndex*(textFrame.size.width/2),20);
        CGRect colRect = CGRectMake(0,
                                    0,
                                    textFrame.size.width/2-10,
                                    textFrame.size.height-40);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        
        //use the column path
        //计算出在指定大小的path中能显示多少字符
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);//5
        
        //create an empty column view
        JY_CTColumnView* content = [[JY_CTColumnView alloc]initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height);
        
        //set the column view contents and add it as subview
        [content setCTFrame:(__bridge id)frame];  //6
        [self attachImagesWithFrame:frame inColumnView:content];
        [self.frames addObject:(__bridge id)frame];
        [self addSubview:content];
        
        //prepare for next frame
        textPos += frameRange.length;
        //CFRelease(frame);
        CFRelease(path);
        columnIndex++;
    }
    
    //set the total width of the scroll view
    int totalPages = (columnIndex+1)/2;//7
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
//    NSLog(@"%@",NSStringFromCGSize(self.contentSize));
}

@end
