//
//  OpenGLImageView.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@implementation OpenGLImageView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

@end
