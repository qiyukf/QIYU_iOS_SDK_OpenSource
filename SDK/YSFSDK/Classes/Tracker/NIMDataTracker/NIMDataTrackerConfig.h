//
//  NIMDataTrackerConfig.h
//  NIMSDK
//
//  Created by amao on 2017/12/20.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMDataTrackerOption;


typedef enum : NSInteger {
    YSF_NIMDataTrackerConfigCategoryDevice,
    YSF_NIMDataTrackerConfigCategoryCarrier,
    YSF_NIMDataTrackerConfigCategoryApp,
    YSF_NIMDataTrackerConfigCategoryWifi,
} YSF_NIMDataTrackerConfigCategory;


@interface YSF_NIMDataTrackerConfig : NSObject
@property (nonatomic,strong)    NSDictionary    *serverConfig;
- (BOOL)trackable;
- (NSArray *)trackableCategories;
- (void)markCategoriesTracked:(NSArray *)categories;
@end
