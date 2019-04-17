//
//  YSFMenuModel.h
//  YSFSDK
//
//  Created by liaosipei on 2019/3/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFMenuModel : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL selected;

+ (instancetype)dataByJson:(NSDictionary *)dict;
- (instancetype)initWithText:(NSString *)text selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
