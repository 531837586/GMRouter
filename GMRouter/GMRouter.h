//
//  GMRouter.h
//  GMRouter
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef id (^GMRouterBlock) (NSDictionary *params);

@interface GMRouter : NSObject

- (void) map:(NSString *) url toBlock:(GMRouterBlock) block;
- (void) map:(NSString *) url toControllerClass:(Class)controllerClass;

- (GMRouterBlock) matchBlock:(NSString *)url;

- (UIViewController *) matchViewController:(NSString *)url;


+ (instancetype)shared;
@end

@interface UIViewController (GMRouter)

@property (nonatomic, strong) NSDictionary *params;


@end
