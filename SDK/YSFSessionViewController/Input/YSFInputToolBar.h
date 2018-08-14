//
//  NIMInputToolBar.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFInputTextView;
@interface YSFInputToolBar : UIView

@property (nonatomic,assign) BOOL    humanOrMachine;

@property (nonatomic,strong) UIButton    *voiceBtn;

@property (nonatomic,strong) UIButton    *emoticonBtn;

@property (nonatomic,strong) UIButton    *recordButton;
@property (nonatomic,strong) UILabel     *recordLabel;

@property (nonatomic,strong) UIImageView *inputTextBkgImage;

@property (nonatomic,strong) YSFInputTextView *inputTextView;

@property (nonatomic,strong) UIButton    *imageButton;
@property (nonatomic,strong) UIButton    *moreMediaBtn;

@end
