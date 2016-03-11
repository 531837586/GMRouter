//
//  GMRouterTests.m
//  GMRouterTests
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GMRouter.h"
#define TIME_OUT 5

@interface GMRouterTests : XCTestCase

@end

@implementation GMRouterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testSingleton {
    GMRouter *router = [GMRouter shared];
    XCTAssertEqualObjects(router, [GMRouter shared]);
}


- (void)testMatchBlock {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    GMRouter *router = [GMRouter shared];
    GMRouterBlock block = ^(NSDictionary *params) {
        XCTAssertEqualObjects(params[@"uid"], @"123");
        XCTAssertEqualObjects(params[@"pid"], @"23423");
        XCTAssertEqualObjects(params[@"hello"], @"world");
        dispatch_semaphore_signal(semaphore);
        return [NSNull null];
    };
    
    
    [router map:@"/gemini/[uid]/[pid]" toBlock:block];
    GMRouterBlock newBlock = [router matchBlock:@"/gemini/123/23423?hello=world"];
    newBlock(nil);
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
         runMode:NSDefaultRunLoopMode
         beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIME_OUT]];
    }
}

- (void) testConflictBlock {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    GMRouter *router = [GMRouter shared];
    GMRouterBlock block1 = ^(NSDictionary *params) {
        XCTAssertFalse(YES);
        return [NSNull null];
    };
    
    GMRouterBlock block2 = ^(NSDictionary *params) {
        XCTAssertEqualObjects(params[@"uid"], @"2");
        XCTAssertEqualObjects(params[@"hello"], @"world2");
        dispatch_semaphore_signal(semaphore);
        return [NSNull null];
    };
    
    [router map:@"/gemini/[uid]/pic" toBlock:block2];
    [router map:@"/gemini/[uid]/[pid]" toBlock:block1];
    GMRouterBlock newBlock = [router matchBlock:@"/gemini/2/pic?hello=world2"];
    newBlock(nil);
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
         runMode:NSDefaultRunLoopMode
         beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIME_OUT]];
    }
 
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
