//
//  PCComicRequest.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCComic.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicRequest : PCRequest

//page: 分页，从1开始
@property (nonatomic, assign) NSUInteger page;
//c: 分区名字，categories里面的title，如"嗶咔漢化"
@property (nonatomic, copy)   NSString *c;
//t: 标签的名字，由info返回数据里面的"tags"获得
@property (nonatomic, copy)   NSString *t;
//默认 dd: 新到旧 da: 旧到新 ld: 最多爱心 vd: 最多指名
@property (nonatomic, copy)   NSString *s;

//未使用
@property (nonatomic, copy)    NSString *a;//author
@property (nonatomic, copy)    NSString *f;//finished
@property (nonatomic, copy)    NSString *ct;//translate
@property (nonatomic, copy)    NSString *ca;//creatorId

@end

NS_ASSUME_NONNULL_END
