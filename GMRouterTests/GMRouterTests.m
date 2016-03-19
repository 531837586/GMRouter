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
    GMRouterBlock block = ^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[@"uid"], @"123");
        XCTAssertEqualObjects(params[@"pid"], @"23423");
        XCTAssertEqualObjects(params[@"hello"], @"world");
        dispatch_semaphore_signal(semaphore);
        return nil;
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


- (void) testChineseLanguage {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    GMRouter *router = [GMRouter shared];
    GMRouterBlock block = ^id(NSDictionary *params) {
        XCTAssertEqualObjects(params[@"uid"], @"前端");
        dispatch_semaphore_signal(semaphore);
        return nil;
    };
    
    
    [router map:@"/chinese/[uid]" toBlock:block];
    GMRouterBlock newBlock = [router matchBlock:@"/chinese/前端"];
    newBlock(nil);
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop]
         runMode:NSDefaultRunLoopMode
         beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIME_OUT]];
    }
 
}

- (void) testControllerClass {
    GMRouter *router = [GMRouter shared];
    [router map:@"/q/[questionId]" toControllerClass:[UIViewController class]];
    UIViewController *controller = [router matchViewController:@"/q/1000010000?__ea=111"];
    XCTAssertEqualObjects(controller.params[@"questionId"], @"1000010000");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
