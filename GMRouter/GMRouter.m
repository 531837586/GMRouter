//
//  GMRouter.m
//  GMRouter
//
//  Created by 温盛章 on 16/3/11.
//  Copyright © 2016年 Gemini. All rights reserved.
//

#import "GMRouter.h"
#import "GMRouterRequest.h"
#import <objc/runtime.h>

#pragma mark - UIViewController Category

@implementation UIViewController (GMRouter)

static char kAssociatedParamsObjectKey;

- (void)setParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey);
}
@end

#define kRegisterUrl @"__origin_url"


@interface GMRouter()
@property (strong, nonatomic) NSMutableDictionary<NSString *, GMRouterBlock> *blockStore;
@property (strong, nonatomic) NSMutableDictionary<NSString *, Class> *controllerClassStore;
@property (nonatomic, weak) UINavigationController *navigationController;
@end

@implementation GMRouter

- (instancetype) init {
    self = [super init];
    if (self) {
        self.blockStore = [NSMutableDictionary dictionary];
        self.controllerClassStore = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void) map:(NSString *) url toBlock:(GMRouterBlock) block {
    self.blockStore[url] = block;
}

- (void) map:(NSString *) url toControllerClass:(Class)controllerClass {
    self.controllerClassStore[url] = controllerClass;
}

-(UIViewController *) matchViewController:(NSString *)pendingUrl {
    NSDictionary *parameters = [self parseParameters:pendingUrl andKeys:self.controllerClassStore.allKeys];
    
    if (parameters){
        Class class = self.controllerClassStore[parameters[kRegisterUrl]];
        UIViewController *viewController = [[class alloc] init];
        
        if ([viewController respondsToSelector:@selector(setParams:)]) {
            [viewController performSelector:@selector(setParams:)
                                 withObject:[parameters copy]];
        }
        return viewController;
    }
    return nil;
};

- (GMRouterBlock) matchBlock:(NSString *)pendingUrl {
    NSDictionary *parameters = [self parseParameters:pendingUrl andKeys:self.blockStore.allKeys];

    if (parameters){
        GMRouterBlock block = [self.blockStore[parameters[kRegisterUrl]] copy];
        
        return ^id(NSDictionary *params) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:parameters];
            return block([dic copy]);
        };
    } else {
        return ^id(NSDictionary *params) { return nil; };
    }
 
}

-(NSMutableDictionary *) parseParameters:(NSString *) pendingUrl andKeys:(NSArray *)allKeys {
    
    GMRouterRequest *request = [[GMRouterRequest alloc] initWithString:pendingUrl];
    NSMutableDictionary *returnParams = nil;
    
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
       
        returnParams = [NSMutableDictionary dictionary];
        
        NSUInteger paramsLength = [paramsKeys count];
        for(NSUInteger i = 0; i < paramsLength; i ++) {
            returnParams[paramsKeys[i]] = paramsValues[i];
        }
        
        [returnParams addEntriesFromDictionary:request.query];
        returnParams[kRegisterUrl] = url;
        break;
    }
    return returnParams;
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




