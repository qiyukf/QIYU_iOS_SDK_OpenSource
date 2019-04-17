//
//  YSFMessageFormFieldView.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/26.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat YSFMessageFormFieldVerticalSpace = 5.0f;
static CGFloat YSFMessageFormFieldHorizontalSpace = 16.0f;
static CGFloat YSFMessageFormFieldHeight = 48.0f;
static CGFloat YSFMessageFormFieldHeight_Message = 148.0f;

@class YSFMessageFormField;
@class YSFMessageFormFieldView;
@class YSFMenuModel;


@protocol YSFMessageFormFieldViewDelegate <NSObject>

- (void)onTapMessageFormFieldView:(YSFMessageFormFieldView *)fieldView;

@end


@interface YSFMessageFormFieldView : UIView

@property (nonatomic, weak) id<YSFMessageFormFieldViewDelegate> delegate;
@property (nonatomic, strong) YSFMessageFormField *fieldData;
@property (nonatomic, strong) NSArray<YSFMenuModel *> *options;

- (void)reload;
- (void)resignResponder;

@end

NS_ASSUME_NONNULL_END
