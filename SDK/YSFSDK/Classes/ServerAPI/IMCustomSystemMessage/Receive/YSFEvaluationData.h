//
//  YSFEvaluationData.h
//  YSFSDK
//
//  Created by liaosipei on 2018/11/20.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSFEvaluationTagType) {
    YSFEvaluationTagTypeNone = 1000,         //none
    YSFEvaluationTagTypeVerySatisfied,       //非常满意
    YSFEvaluationTagTypeSatisfied,           //满意
    YSFEvaluationTagTypeOrdinary,            //一般
    YSFEvaluationTagTypeDissatisfied,        //不满意
    YSFEvaluationTagTypeVeryDissatisfied,    //非常不满意
};

@interface YSFEvaluationTag : NSObject

@property (nonatomic, assign) YSFEvaluationTagType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) NSArray *tagList;
@property (nonatomic, assign) BOOL tagRequired;
@property (nonatomic, assign) BOOL commentRequired;

+ (instancetype)dataByDict:(NSDictionary *)dict;

@end

@interface YSFEvaluationData : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger scoreType;
@property (nonatomic, assign) BOOL webAppSort;
@property (nonatomic, assign) BOOL wxwbSort;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *inviteText;
@property (nonatomic, copy) NSString *thanksText;
@property (nonatomic, strong) NSArray<YSFEvaluationTag *> *tagArray;

+ (instancetype)dataByDict:(NSDictionary *)dict;
+ (instancetype)makeDefaultData;

@end

NS_ASSUME_NONNULL_END
