//
//  GMRouterPathInfo.m
//  GMRouter
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import "GMRouterRequest.h"

@implementation GMRouterRequest

- (instancetype) initWithString:(NSString *)url {
    self = [super init];
    if (self) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:url];
        [self parse:components];
    }
    return self;
}

- (instancetype) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
        [self parse:components];
    }
    return self;
}

- (void) parse:(NSURLComponents *) components {
    _pathInfo = components.path;
    NSArray *queryItems = components.queryItems;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in queryItems) {
        params[item.name] = item.value;
    }
    _query = params;
}
@end
