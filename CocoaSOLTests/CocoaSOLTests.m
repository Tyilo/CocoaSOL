//
//  CocoaSOLTests.m
//  CocoaSOLTests
//
//  Created by Asger Hautop Drewsen on 26/08/14.
//  Copyright (c) 2014 Tyilo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CocoaSOL.h"

@interface CocoaSOLTests : XCTestCase

@end

@implementation CocoaSOLTests

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
	NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"myApp3.sol" ofType:@""];
	
	NSString *solName;
	NSDictionary *dict = [SOLUnarchiver dictionaryFromFile:testPath SOLName:&solName];
	
	[SOLArchiver writeDictionary:dict toFile:@"/tmp/cocoasol-test" SOLName:solName encoding:3];
	
	NSDictionary *dict2 = [SOLUnarchiver dictionaryFromFile:@"/tmp/cocoasol-test" SOLName:NULL];
	
	XCTAssertEqualObjects(dict2, dict, "top");
}

@end
