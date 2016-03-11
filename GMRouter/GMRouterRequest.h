//
//  GMRouterPathInfo.h
//  GMRouter
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMRouterRequest : NSObject

-(instancetype) initWithString:(NSString *)url;
-(instancetype) initWithURL:(NSURL *)url;

@property(strong, nonatomic, readonly) NSString *pathInfo;
@property(strong, nonatomic, readonly) NSDictionary *query;
@end
