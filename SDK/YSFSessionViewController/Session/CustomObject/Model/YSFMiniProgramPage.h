//
//  YSFMiniProgramPage.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFCustomAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFMiniProgramPage : NSObject <YSFCustomAttachment>

@property (nonatomic, copy) NSString *headImgURL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *coverImgURL;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
