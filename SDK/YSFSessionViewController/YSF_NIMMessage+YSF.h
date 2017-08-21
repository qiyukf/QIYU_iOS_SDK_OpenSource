//
//  YSF_NIMMessage+http.h
//  QYKF
//
//  Created by 金华 on 16/3/22.
//  Copyright © 2016年 Netease. All rights reserved.
//

@interface YSF_NIMMessage (YSF)
- (NSString *)getDisplayMessageContent;//重设message显示
- (NSString *)getTextWithoutTrashWords;
- (BOOL)hasTrashWords;
- (NSString *)getTrashWordsTip;
@end

