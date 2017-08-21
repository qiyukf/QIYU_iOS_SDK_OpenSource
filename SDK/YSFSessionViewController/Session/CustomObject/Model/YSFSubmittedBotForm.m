#import "YSFSubmittedBotForm.h"
#import "NSDictionary+YSFJson.h"




@implementation YSFSubmittedBotFormCell

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyLabel]               = YSFStrParam(_label);
    dict[YSFApiKeyType]            = YSFStrParam(_type);
    if ([_type isEqualToString:@"image"]) {
        if (_imageValue) {
            dict[YSFApiKeyValue]            = _imageValue;
        }
    }
    else {
        dict[YSFApiKeyValue]            = YSFStrParam(_value);
    }
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFSubmittedBotFormCell *instance = [[YSFSubmittedBotFormCell alloc] init];
    instance.label           = [dict ysf_jsonString:YSFApiKeyLabel];
    instance.type            = [dict ysf_jsonString:YSFApiKeyType];
    if ([instance.type isEqualToString:@"image"]) {
        instance.imageValue = [dict ysf_jsonDict:YSFApiKeyValue];
    }
    else {
        instance.value = [dict ysf_jsonString:YSFApiKeyValue];
    }
    
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


@interface YSFSubmittedBotForm()

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFSubmittedBotForm

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict   = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd]               = @(_command);
    dict[YSFApiKeyParams]            = YSFStrParam(_params);
    NSMutableArray *mutableArray = [NSMutableArray new];
    for (YSFSubmittedBotFormCell *form in _forms) {
        NSDictionary *dict = [form encodeAttachment];
        [mutableArray addObject:dict];
    }
    
    NSDictionary *template = @{@"id":@"qiyu_template_botForm", @"forms":mutableArray};
    dict[YSFApiKeyTemplate] = template;
    
    return dict;
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFSubmittedBotForm *instance = [[YSFSubmittedBotForm alloc] init];
    instance.imageUrlStringArray = [NSMutableArray new];
    instance.command           = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.params            = [dict ysf_jsonString:YSFApiKeyParams];
    NSDictionary *template     = [dict ysf_jsonDict:YSFApiKeyTemplate];

    NSMutableArray *mutableArray = [NSMutableArray new];
    NSArray *formsArray           = [template ysf_jsonArray:YSFApiKeyForms];
    for (NSDictionary *formDict in formsArray) {
        YSFSubmittedBotFormCell *cell = [YSFSubmittedBotFormCell objectByDict:formDict];
        if (cell.imageUrl.length > 0) {
            [instance.imageUrlStringArray addObject:cell.imageUrl];
        }
        [mutableArray addObject:cell];
    }
    instance.forms = mutableArray;
    
    return instance;
}

- (void)setImageUrlString:(NSArray *)forms
{
    _imageUrlStringArray = [NSMutableArray new];
    for (YSFSubmittedBotFormCell *cell in forms) {
        if (cell.imageUrl.length > 0) {
            [_imageUrlStringArray addObject:cell.imageUrl];
        }
    }
}
@end
