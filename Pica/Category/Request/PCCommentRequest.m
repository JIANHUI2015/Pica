//
//  PCCommentRequest.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCCommentRequest.h"
#import <YYModel/YYModel.h>

@interface PCCommentRequest ()
 
@end

@implementation PCCommentRequest

- (instancetype)initWithComicsId:(NSString *)comicsId {
    if (self = [super init]) {
        _comicsId = [comicsId copy];
        _page = 1;
    }
    return self;
}

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCComicsComment *comment = [PCComicsComment yy_modelWithJSON:request.responseJSONObject[@"data"]];
        
        !success ? : success(comment);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:PC_API_COMICS_COMMENTS, self.comicsId];
    [requestUrl appendFormat:@"?page=%@", @(self.page)];
    return requestUrl;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return [PCRequest headerWithUrl:[self requestUrl] method:@"GET" time:[NSDate date]];
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}


- (NSInteger)cacheTimeInSeconds {
    return 60 * 2;
}

- (BOOL)ignoreCache {
    return NO;
}

@end
