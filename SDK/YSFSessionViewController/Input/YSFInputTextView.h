//
//  NIMInputTextView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

typedef void (^PasteImageCallback)(UIImage *image);

@interface YSFInputTextView : UITextView

@property (nonatomic, weak) UIResponder *overrideNextResponder;

@property (nonatomic, strong) NSString *placeHolder;

@property (nonatomic, copy) PasteImageCallback pasteImageCallback;

- (void)setCustomUI;

@end
