//
//  YSFInputProtocol.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFEmoticonItem;

@protocol YSFInputActionDelegate <NSObject>

@optional

- (void)onTextChanged:(id)sender;
- (BOOL)onSendText:(NSString *)text;

- (void)onMediaPicturePressed;
- (void)onSelectEmoticonGraphicItem:(YSFEmoticonItem *)selectItem;

- (void)onPasteImage:(UIImage *)image;

- (void)onStartRecording;
- (void)onCancelRecording;
- (void)onStopRecording;

@end

