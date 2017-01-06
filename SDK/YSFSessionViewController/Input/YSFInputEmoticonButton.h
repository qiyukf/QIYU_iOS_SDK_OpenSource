//
//  NIMInputEmoticonButton.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//


@class YSFInputEmoticon;

@protocol YSFEmoticonButtonTouchDelegate <NSObject>

- (void)selectedEmoticon:(YSFInputEmoticon*)emoticon catalogID:(NSString*)catalogID;

@end



@interface YSFInputEmoticonButton : UIButton

@property (nonatomic, strong) YSFInputEmoticon *emoticonData;

@property (nonatomic, copy)   NSString         *catalogID;

@property (nonatomic, weak)   id<YSFEmoticonButtonTouchDelegate> delegate;

+ (YSFInputEmoticonButton*)iconButtonWithData:(YSFInputEmoticon*)data catalogID:(NSString*)catalogID delegate:( id<YSFEmoticonButtonTouchDelegate>)delegate;

- (void)onIconSelected:(id)sender;

@end