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
- (GMRouterBlock) matchBlock:(NSString *)url;

+ (instancetype)shared;
@end
