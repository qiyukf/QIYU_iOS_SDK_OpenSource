//
//  YSFLog.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 06.08.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Replacement for `NSLog` which can be configured to output certain log levels at run time.
 */

// block signature called for each log statement
typedef void (^YSFLogBlock)(NSUInteger logLevel, NSString *fileName, NSUInteger lineNumber, NSString *methodName, NSString *format, ...);


// internal variables needed by macros
extern YSFLogBlock YSFLogHandler;
extern NSUInteger YSFCurrentLogLevel;

/**
 There is a macro for each ASL log level:
 
 - YSFLogEmergency (0)
 - YSFLogAlert (1)
 - YSFLogCritical (2)
 - YSFLogError (3)
 - YSFLogWarning (4)
 - YSFLogNotice (5)
 - YSFLogInfo (6)
 - YSFLogDebug (7)
 */

/**
 Constants for log levels used by YSFLog
 */
typedef NS_ENUM(NSUInteger, YSFLogLevel)
{
	/**
	 Log level for *emergency* messages
	 */
	YSFLogLevelEmergency = 0,
	
	/**
	 Log level for *alert* messages
	 */
	YSFLogLevelAlert     = 1,
	
	/**
	 Log level for *critical* messages
	 */
	YSFLogLevelCritical  = 2,
	
	/**
	 Log level for *error* messages
	 */
	YSFLogLevelError     = 3,
	
	/**
	 Log level for *warning* messages
	 */
	YSFLogLevelWarning   = 4,
	
	/**
	 Log level for *notice* messages
	 */
	YSFLogLevelNotice    = 5,
	
	/**
	 Log level for *info* messages. This is the default log level for YSFLog.
	 */
	YSFLogLevelInfo      = 6,
	
	/**
	 Log level for *debug* messages
	 */
	YSFLogLevelDebug     = 7
};

/**
 @name Logging Functions
 */

/**
 Sets the block to be executed for messages with a log level less or equal the currently set log level
 @param handler The block to handle log output
 */
void YSFLogSetLoggerBlock(YSFLogBlock handler);

/**
 Modifies the current log level
 @param logLevel The ASL log level (0-7) to set, lower numbers being more important
 */
void YSFLogSetLogLevel(NSUInteger logLevel);

/**
 Variant of YSFLogMessage that takes a va_list.
 @param logLevel The YSFLogLevel for the message
 @param format The log message format
 @param args The va_list of arguments
*/
void YSFLogMessagev(YSFLogLevel logLevel, NSString *format, va_list args);

/**
 Same as `NSLog` but allows for setting a message log level
 @param logLevel The YSFLogLevel for the message
 @param format The log message format and optional variables
 */
void YSFLogMessage(YSFLogLevel logLevel, NSString *format, ...);

/**
 Retrieves the log messages currently available for the running app
 @returns an `NSArray` of `NSDictionary` entries
 */
NSArray *YSFLogGetMessages(void);

/**
 @name Macros
 */

// log macro for error level (0)
#define YSFLogEmergency(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelEmergency, format, ##__VA_ARGS__)

// log macro for error level (1)
#define YSFLogAlert(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelAlert, format, ##__VA_ARGS__)

// log macro for error level (2)
#define YSFLogCritical(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelCritical, format, ##__VA_ARGS__)

// log macro for error level (3)
#define YSFLogError(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelError, format, ##__VA_ARGS__)

// log macro for error level (4)
#define YSFLogWarning(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelWarning, format, ##__VA_ARGS__)

// log macro for error level (5)
#define YSFLogNotice(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelNotice, format, ##__VA_ARGS__)

// log macro for info level (6)
#define YSFLogInfo(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelInfo, format, ##__VA_ARGS__)

// log macro for debug level (7)
#define YSFLogDebug(format, ...) YSFLogCallHandlerIfLevel(YSFLogLevelDebug, format, ##__VA_ARGS__)

// macro that gets called by individual level macros
#define YSFLogCallHandlerIfLevel(logLevel, format, ...) \
if (YSFLogHandler && YSFCurrentLogLevel>=logLevel) YSFLogHandler(logLevel, YSFLogSourceFileName, YSFLogSourceLineNumber, YSFLogSourceMethodName, format, ##__VA_ARGS__)

// helper to get the current source file name as NSString
#define YSFLogSourceFileName [[NSString stringWithUTF8String:__FILE__] lastPathComponent]

// helper to get current method name
#define YSFLogSourceMethodName [NSString stringWithUTF8String:__PRETTY_FUNCTION__]

// helper to get current line number
#define YSFLogSourceLineNumber __LINE__
