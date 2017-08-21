#import "YSFBotForm.h"
#import "NSDictionary+YSFJson.h"

@implementation YSFBotFormCell

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyLabel]               = YSFStrParam(_label);
    if ([_type isEqualToString:@"image"]) {
        if (_imageValue) {
            dict[YSFApiKeyValue]            = _imageValue;
        }
    }
    else {
        dict[YSFApiKeyValue]            = YSFStrParam(_value);
    }
    dict[YSFApiKeyRequired]            = @(_required);
    dict[YSFApiKeyType]            = YSFStrParam(_type);
    dict[YSFApiKeyId]            = YSFStrParam(_id);
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFBotFormCell *instance = [[YSFBotFormCell alloc] init];
    instance.label           = [dict ysf_jsonString:YSFApiKeyLabel];
    if ([instance.type isEqualToString:@"image"]) {
        instance.imageValue = [dict ysf_jsonDict:YSFApiKeyValue];
    }
    else {
        instance.value = [dict ysf_jsonString:YSFApiKeyValue];
    }
    instance.required        = [dict ysf_jsonBool:YSFApiKeyRequired];
    instance.type            = [dict ysf_jsonString:YSFApiKeyType];
    instance.id         = [dict ysf_jsonString:YSFApiKeyId];
    
    return instance;
}

- (NSString *)imageUrl
{
    return [_imageValue ysf_jsonString:YSFApiKeyUrl];
}

- (NSString *)imageName
{
    return [_imageValue ysf_jsonString:YSFApiKeyName];
}

- (long long)imageFileSize
{
    return [_imageValue ysf_jsonLongLong:YSFApiKeySize];
}


@end


@implementation YSFBotForm

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyId]               = @"bot_form";
    dict[YSFApiKeyVersion]               = YSFStrParam(_version);
    dict[YSFApiKeyTarget]               = YSFStrParam(_target);
    dict[YSFApiKeyLabel]            = YSFStrParam(_label);
    dict[YSFApiKeyParams]            = YSFStrParam(_params);
    dict[YSFApiKeySubmitted]            = @(_submitted);
    
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (YSFBotFormCell *form in _forms) {
        NSDictionary *dict = [form encodeAttachment];
        [mutableArray addObject:dict];
    }
    dict[YSFApiKeyForms] = mutableArray;
    
    NSMutableDictionary *botForm   = [NSMutableDictionary dictionary];
    botForm[YSFApiKeyCmd] = @(YSFCommandBotReceive);
    botForm[YSFApiKeyType] = @"11";
    botForm[YSFApiKeyTemplate] = dict;
    
    return botForm;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFBotForm *instance = [[YSFBotForm alloc] init];
    instance.version            = [dict ysf_jsonString:YSFApiKeyVersion];
    instance.target            = [dict ysf_jsonString:YSFApiKeyTarget];
    instance.label            = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.params            = [dict ysf_jsonString:YSFApiKeyParams];
    instance.submitted            = [dict ysf_jsonBool:YSFApiKeySubmitted];
    
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSArray *formsArray           = [dict ysf_jsonArray:YSFApiKeyForms];
    for (NSDictionary *formDict in formsArray) {
        YSFBotFormCell *form = [YSFBotFormCell objectByDict:formDict];
        [mutableArray addObject:form];
    }
    instance.forms = mutableArray;
    
    return instance;
}

@end



