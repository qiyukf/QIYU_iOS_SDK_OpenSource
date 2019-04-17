//
//  YSFMessageFormField.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMessageFormField.h"
#import "YSFApiDefines.h"

@implementation YSFMessageFormField
+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFMessageFormField *field = [[YSFMessageFormField alloc] init];
    field.fieldID = [dict ysf_jsonLongLong:YSFApiKeyFieldId];
    
    NSInteger type = [dict ysf_jsonInteger:YSFApiKeyType];
    NSString *desc = [dict ysf_jsonString:YSFApiKeyDescription];
    if (field.fieldID == -2) {
        field.type = YSFMessageFormFieldTypePhone;
    } else if (field.fieldID == -3) {
        field.type = YSFMessageFormFieldTypeEmail;
    } else if (field.fieldID == -4) {
        field.type = YSFMessageFormFieldTypeAttachment;
    } else {
        if (type == 0) {
            if ([desc isEqualToString:@"0"]) {
                field.type = YSFMessageFormFieldTypeSingleInput;
            } else if ([desc isEqualToString:@"2"]) {
                field.type = YSFMessageFormFieldTypeMultipleInput;
            } else if ([desc isEqualToString:@"1"]) {
                field.type = YSFMessageFormFieldTypeNumber;
            } else {
                field.type = YSFMessageFormFieldTypeNone;
            }
        } else if (type == 1) {
            field.type = YSFMessageFormFieldTypeSingleMenu;
        } else if (type == 2) {
            field.type = YSFMessageFormFieldTypeMultipleMenu;
        } else if (type == 3) {
            field.type = YSFMessageFormFieldTypeTime;
        } else {
            field.type = YSFMessageFormFieldTypeNone;
        }
    }
    field.required = [dict ysf_jsonBool:YSFApiKeyRequired];
    field.name = [dict ysf_jsonString:YSFApiKeyName];
    field.desc = desc;
    
    if (field.type == YSFMessageFormFieldTypeAttachment) {
        return nil;
    }
    
    return field;
}

+ (instancetype)makeFieldWithType:(YSFMessageFormFieldType)type {
    YSFMessageFormField *field = [[YSFMessageFormField alloc] init];
    field.type = type;
    return field;
}

- (void)setName:(NSString *)name {
    _name = name;
    if (name.length) {
        NSString *nameStr = name;
        NSDictionary *dict = @{ NSFontAttributeName : [UIFont systemFontOfSize:14.0] };
        CGSize nameSize = [nameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:dict
                                                context:nil].size;
        _nameWidth = nameSize.width + 2;
    } else {
        _nameWidth = 0;
    }
}

- (NSDictionary *)getResultDict {
    return @{
             @"fieldId" : [NSString stringWithFormat:@"%lld", _fieldID],
             @"fieldValue" : YSFStrParam(_value),
             @"fieldName" : YSFStrParam(_name),
             };
}

@end
