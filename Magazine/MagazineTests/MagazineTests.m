//
//  MagazineTests.m
//  MagazineTests
//
//  Created by 汪潇翔 on 14-5-8.
//  Copyright (c) 2014年 JiaYuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JYMarkParser.h"

@interface MagazineTests : XCTestCase

@end

@implementation MagazineTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    JYMarkParser* parser = [[JYMarkParser alloc]init];
    [parser attrStringFromMark:@"These are <font color=\"red\">red<font color=\"black\"> and <font color=\"blue\">blue <font color=\"black\">words."];
}

@end
