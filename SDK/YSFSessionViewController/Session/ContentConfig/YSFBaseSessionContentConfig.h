//
//  NIMBaseSessionContentConfig.h
//  NIMKit
//
//  Created by amao on 9/15/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//


@protocol YSFSessionContentConfig <NSObject>

- (CGSize)contentSize:(CGFloat)cellWidth;
- (NSString *)cellContent;
- (UIEdgeInsets)contentViewInsets;

@end


@interface YSFBaseSessionContentConfig : NSObject

@property (nonatomic, strong) YSF_NIMMessage *message;

@end


typedef id<YSFSessionContentConfig>(^QueryCustomContentConifgBlock)(YSF_NIMMessage *message);

@interface YSFSessionContentConfigFactory : NSObject

@property (nonatomic, copy) QueryCustomContentConifgBlock queryCustomContentConifgBlock;

+ (instancetype)sharedFacotry;
- (id<YSFSessionContentConfig>)configBy:(YSF_NIMMessage *)message;

@end
