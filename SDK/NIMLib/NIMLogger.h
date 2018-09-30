//
//  NIMLogger.h
//  NIM
//
//  Created by amao on 13-8-23.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


#define YSFLogErr(frmt, ...)                            \
    YSF_NIMLOG_OBJC( 6, __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)

#define YSFLogWar(frmt, ...)                            \
    YSF_NIMLOG_OBJC( 8, __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)

#define YSFLogApp(frmt, ...)                            \
    YSF_NIMLOG_OBJC(12, __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)

#define YSFLogPro(frmt, ...)                            \
    YSF_NIMLOG_OBJC(14, __FILE__, __FUNCTION__, __LINE__,frmt,##__VA_ARGS__)

#define NIMTrace() NIMLogPro(@"%s",__FUNCTION__) //排除错误时使用,AppStore就去掉

#if defined(__cplusplus)
extern "C" {
#endif

    typedef void (*LogInfoCallback)(const char *);
    
    void YSF_SetupLogger();
    void YSF_RegisterCallback(LogInfoCallback callback);

    void YSF_NIMLOG_OBJC(uint32_t level, const char *file, const char *func, uint32_t line, NSString *format, ...);

    NSString *YSF_GetMessage(NSUInteger lastestMessageSize);

#if defined(__cplusplus)
}
#endif
