//
//  NIMInputView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputTextView.h"
#import "YSFInputProtocol.h"
#import "YSFSessionConfig.h"
#import <UIKit/UIKit.h>


@class YSFInputMoreContainerView;
@class YSFInputEmoticonContainerView;
@class YSFInputToolBar;

#define YSFTopInputViewHeight 50.0
#define YSFTopInputViewMaxHeight 82
#define YSFBottomInputViewHeight 216.0

typedef NS_ENUM(NSInteger, NIMInputType){
    InputTypeText = 1,
    InputTypeEmot = 2,
    InputTypeAudio = 3,
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
@end

@interface YSFInputView : UIView

@property (nonatomic, assign) NSInteger             maxTextLength;
@property (nonatomic, assign) NSInteger             maxInputLines;
@property (nonatomic, assign) CGFloat               inputBottomViewHeight;
@property (nonatomic, assign, readonly)             NIMInputType inputType;

@property (nonatomic,assign) BOOL    humanOrMachine;
@property (assign, nonatomic, getter=isRecording) BOOL recording;

@property (strong, nonatomic)  YSFInputToolBar *toolBar;
@property (strong, nonatomic)  YSFInputEmoticonContainerView *emoticonContainer;
@property (strong, nonatomic)  NSString *inputText;

@property (weak,nonatomic)UIViewController* containerController;

- (instancetype)initWithFrame:(CGRect)frame inputType:(NIMInputType)inputType;

- (void)addKeyboardObserver;
- (void)removeKeyboardObserver;

- (void)setInputDelegate:(id<YSFInputDelegate>)delegate;

//外部设置
- (void)setInputActionDelegate:(id<YSFInputActionDelegate>)actionDelegate;
- (void)setInputConfig:(id<YSFSessionConfig>)config;

- (void)setInputTextPlaceHolder:(NSString*)placeHolder;
- (void)updateAudioRecordTime:(NSTimeInterval)time;
- (void)updateVoicePower:(float)power;

- (void)setRecordPhase:(NIMAudioRecordPhase)recordPhase;

- (void)changeInputTypeToText;

- (void)inputBottomViewHeightToZero;

@end
