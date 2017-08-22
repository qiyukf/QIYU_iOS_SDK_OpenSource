//
//  YSFCoreTextMacros.h
//  YSFCoreText
//
//  Created by Jean-Charles BERTIN on 5/28/14.
//  Copyright (c) 2014 Axinoe. All rights reserved.
//

#import <Availability.h>

#ifndef YSF_RETURNS_INNER_POINTER
#if __has_attribute(objc_returns_inner_pointer)
#define YSF_RETURNS_INNER_POINTER __attribute__((objc_returns_inner_pointer))
#else
#define YSF_RETURNS_INNER_POINTER
#endif
#endif
