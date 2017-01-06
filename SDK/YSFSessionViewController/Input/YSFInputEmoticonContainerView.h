//
//  NIMInputEmoticonContainerView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFPageView.h"

@class YSFInputEmoticonCatalog;
@class YSFInputEmoticonTabView;

@protocol YSFInputEmoticonProtocol <NSObject>

- (void)didPressSend:(id)sender;

- (void)selectedEmoticon:(NSString*)emoticonID catalog:(NSString*)emotCatalogID description:(NSString *)description;

@end


@interface YSFInputEmoticonContainerView : UIControl<YSFPageViewDataSource,YSFPageViewDelegate>

@property (nonatomic, strong)  YSFPageView *emoticonPageView;
@property (nonatomic, strong)  UIPageControl  *emotPageController;
@property (nonatomic, strong)  YSFInputEmoticonCatalog    *currentCatalogData;
@property (nonatomic, readonly)YSFInputEmoticonCatalog    *nextCatalogData;
@property (nonatomic, readonly)NSArray            *allEmoticons;
@property (nonatomic, strong)  YSFInputEmoticonTabView   *tabView;
@property (nonatomic, weak)    id<YSFInputEmoticonProtocol>  delegate;

@end

