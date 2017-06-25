//
//  NIMMessageMaker.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageMaker.h"
#import "QYCustomUIConfig+Private.h"

@implementation YSFMessageMaker

+ (YSF_NIMMessage*)msgWithText:(NSString*)text
{
    YSF_NIMMessage *textMessage = [[YSF_NIMMessage alloc] init];
    textMessage.text        = text;
    return textMessage;
}

+ (YSF_NIMMessage*)msgWithImage:(UIImage*)image
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    YSF_NIMImageObject * imageObject = [[YSF_NIMImageObject alloc] initWithImage:image];
    imageObject.displayName = [NSString stringWithFormat:@"图片发送于%@",dateString];
    YSF_NIMImageOption *option = [[YSF_NIMImageOption alloc] init];
    option.compressQuality = [QYCustomUIConfig sharedInstance].compressQuality;
    imageObject.option = option;
    YSF_NIMMessage *message          = [[YSF_NIMMessage alloc] init];
    message.messageObject        = imageObject;
    message.text = @"发来了一张图片";
    return message;
}

+ (YSF_NIMMessage*)msgWithAudio:(NSString*)filePath
{
    YSF_NIMAudioObject *audioObject = [[YSF_NIMAudioObject alloc] initWithSourcePath:filePath];
    YSF_NIMMessage *message = [[YSF_NIMMessage alloc] init];
    message.messageObject = audioObject;
    message.text = @"发来了一段语音";
    return message;
}

+ (YSF_NIMMessage*)msgWithCustom:(id<YSF_NIMCustomAttachment>) attachment
{
    YSF_NIMCustomObject *customObject = [[YSF_NIMCustomObject alloc] init];
    customObject.attachment = attachment;
    YSF_NIMMessage *message = [[YSF_NIMMessage alloc] init];
    message.messageObject = customObject;
    return message;
}

@end
