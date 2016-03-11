//
//  GMRouter.m
//  GMRouter
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import "GMRouter.h"
#import "GMRouterRequest.h"

@interface GMRouter()
@property (strong, nonatomic) NSMutableDictionary<NSString *, GMRouterBlock> *blockStore;
@property (strong, nonatomic) NSMutableDictionary<NSString *, UIViewController *> *viewControllerStore;
@end

@implementation GMRouter

- (instancetype) init {
    self = [super init];
    if (self) {
        self.blockStore = [NSMutableDictionary dictionary];
        self.viewControllerStore = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void) map:(NSString *) url toBlock:(GMRouterBlock) block {
    self.blockStore[url] = block;
}

- (GMRouterBlock) matchBlock:(NSString *)pendingUrl {
    NSArray *allKeys = self.blockStore.allKeys;

    GMRouterRequest *request = [[GMRouterRequest alloc] initWithString:pendingUrl];
    
    for (NSString *url in allKeys) {
        NSMutableString *mutableUrl = [url mutableCopy];
        NSUInteger urlLength = [url length];
        
        NSMutableArray *paramsKeys = [NSMutableArray array];
        NSMutableArray *paramsValues = [NSMutableArray array];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                      @"\\[([_a-z0-9]+)\\]" options:NSRegularExpressionCaseInsensitive error:nil];
        
        /** add keys **/
        [regex enumerateMatchesInString:mutableUrl options:NSMatchingReportCompletion range:NSMakeRange(0, [mutableUrl length])
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                                 if (match) {
                                     [paramsKeys addObject:[mutableUrl substringWithRange:[match rangeAtIndex:1]]];
                                 }
                             }];
        
        [regex replaceMatchesInString:mutableUrl
                              options:0
                                range:NSMakeRange(0, urlLength) withTemplate:@"%"];
       
        [NSRegularExpression escapedPatternForString:mutableUrl];
        [mutableUrl replaceOccurrencesOfString:@"%"
                                    withString:@"([^\\/]+)" options:NSCaseInsensitiveSearch
                                         range:NSMakeRange(0, [mutableUrl length])];
        

        regex = [NSRegularExpression regularExpressionWithPattern:mutableUrl
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
        
        NSString *pathInfo = request.pathInfo;
        
        NSTextCheckingResult *checkResult = [regex firstMatchInString:pathInfo
                                                              options:NSMatchingReportCompletion range:NSMakeRange(0, [pathInfo length])];
        
        if (!checkResult) {
            continue;
        }
        
        NSUInteger rangeNumber = [checkResult numberOfRanges];
        for(NSUInteger i = 1; i < rangeNumber; i ++) {
            NSRange range = [checkResult rangeAtIndex:i];
            NSString *param = [pathInfo substringWithRange:range];
            [paramsValues addObject:param];
        }
        
        NSMutableDictionary *returnParams = [NSMutableDictionary dictionary];
        
        NSUInteger paramsLength = [paramsKeys count];
        for(NSUInteger i = 0; i < paramsLength; i ++) {
            returnParams[paramsKeys[i]] = paramsValues[i];
        }
        
        [returnParams addEntriesFromDictionary:request.query];
        
        GMRouterBlock block = [self.blockStore[url] copy];
        
        return ^(NSDictionary *params) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:returnParams];
            return block([dic copy]);
        };
    }
    return ^(NSDictionary *params) {
        return [NSNull null];
    };
}


+ (instancetype)shared
{
    static GMRouter *router = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[self alloc] init];
        }
    });
    return router;
}

@end
