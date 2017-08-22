//
//  YSFAnimatedGIF.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 7/2/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Loads an animated GIF from file, compatible with UIImageView
 */
UIImage *YSFAnimatedGIFFromFile(NSString *path);

/**
 Loads an animated GIF from data, compatible with UIImageView
 */
UIImage *YSFAnimatedGIFFromData(NSData *data);
