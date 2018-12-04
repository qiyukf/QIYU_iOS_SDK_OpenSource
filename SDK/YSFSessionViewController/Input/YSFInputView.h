//
//  NIMInputView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputTextView.h"
#import "YSFInputProtocol.h"
#import "YSFActionBar.h"
#import <UIKit/UIKit.h>


@class YSFInputMoreContainerView;
@class YSFInputEmoticonContainerView;
@class YSFInputToolBar;

#define YSFTopInputViewHeight 50.0
#define YSFTopInputViewMaxHeight 82
#define YSFBottomInputViewHeight 216.0

typedef NS_ENUM(NSInteger, YSFInputStatus){
    YSFInputStatusText,
    YSFInputStatusAudio,
    YSFInputStatusEmoticon,
    YSFInputStatusMore
};

typedef NS_ENUM(NSInteger, NIMAudioRecordPhase) {
    AudioRecordPhaseStart,
    AudioRecordPhaseRecording,
    AudioRecordPhaseCancelling,
    AudioRecordPhaseEnd
};


@protocol YSFInputDelegate <NSObject>

@required
- (void)showInputView;
- (void)hideInputView;
- (void)inputViewSizeToHeight:(CGFloat)toHeight
                showInputView:(BOOL)show;
- (void)changeInputTypeTo:(YSFInputStatus)inputStatus;

@end


@interface YSFInputView : UIView

@property (nonatomic, assign) NSInteger maxTextLength;
@property (nonatomic, assign) NSInteger maxInputLines;
@property (nonatomic, assign) CGFloat inputBottomViewHeight;
@property (nonatomic, assign) CGFloat actionBarHeight;
@property (nonatomic, assign) CGFloat bottomHeight;
@property (nonatomic, assign, readonly) YSFInputStatus inputStatus;

@property (nonatomic, assign) BOOL humanOrMachine;
@property (assign, nonatomic, getter = isRecording) BOOL recording;

@property (strong, nonatomic) YSFInputToolBar *toolBar;
@property (strong, nonatomic) YSFActionBar *actionBar;
@property (strong, nonatomic) YSFInputEmoticonContainerView *emoticonContainer;
@property (strong, nonatomic) NSString *inputText;

@property (weak, nonatomic) UIViewController *containerController;

+ (Class)actionBarClass;
+ (Class)toolBarClass;

- (instancetype)initWithFrame:(CGRect)frame inputType:(YSFInputStatus)inputStatus;

- (void)addKeyboardObserver;
- (void)removeKeyboardObserver;

- (void)setInputDelegate:(id<YSFInputDelegate>)delegate;

//外部设置
- (void)setActionInfoArray:(NSArray<YSFActionInfo *> *)actionInfoArray;
- (void)setActionCallback:(SelectActionCallback)callback;

- (void)setInputActionDelegate:(id<YSFInputActionDelegate>)actionDelegate;

- (void)setInputTextPlaceHolder:(NSString*)placeHolder;
- (void)updateAudioRecordTime:(NSTimeInterval)time;
- (void)updateVoicePower:(float)power;

- (void)setRecordPhase:(NIMAudioRecordPhase)recordPhase;

- (void)changeInputTypeToText;

- (void)inputBottomViewHeightToZero;

@end
