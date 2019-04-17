//
//  YSFMessageFormField.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSFMessageFormFieldType) {
    YSFMessageFormFieldTypeNone          = 0,    //非自定义
    YSFMessageFormFieldTypePhone         = 1,    //手机
    YSFMessageFormFieldTypeEmail         = 2,    //邮箱
    YSFMessageFormFieldTypeSingleInput   = 3,    //输入-单行文本
    YSFMessageFormFieldTypeMultipleInput = 4,    //输入-多行文本
    YSFMessageFormFieldTypeNumber        = 5,    //输入-数字
    YSFMessageFormFieldTypeSingleMenu    = 6,    //单选菜单
    YSFMessageFormFieldTypeMultipleMenu  = 7,    //多选菜单
    YSFMessageFormFieldTypeTime          = 8,    //时间选择
    YSFMessageFormFieldTypeMessage       = 9,    //留言
    YSFMessageFormFieldTypeAttachment    = 10,   //附件
};

@interface YSFMessageFormField : NSObject

@property (nonatomic, assign) long long fieldID;            //字段ID
@property (nonatomic, assign) YSFMessageFormFieldType type; //字段类型
@property (nonatomic, assign) BOOL required;           //是否必填：0-非必填 1-必填

@property (nonatomic, copy) NSString *name;     //字段名称
@property (nonatomic, copy) NSString *desc;     //字段描述：type是输入类型的情况下，该值表示字段详情（0单行文本，1数字，2多行文本）；其他类型则为内容

@property (nonatomic, assign) CGFloat nameWidth;    //字段名称所占宽度
@property (nonatomic, copy) NSString *value;        //结果值

+ (instancetype)dataByJson:(NSDictionary *)dict;
+ (instancetype)makeFieldWithType:(YSFMessageFormFieldType)type;
- (NSDictionary *)getResultDict;

@end

NS_ASSUME_NONNULL_END
