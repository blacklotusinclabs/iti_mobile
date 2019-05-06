//
//  MLWebView.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/19/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import "MLWebView.h"
#import "HTMLPublicationViewController.h"

@implementation MLWebView

@synthesize pubController;

- (void) addRecognizers
{
	tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self 
                                                            action: @selector(_tapGesture:)];	
}

- (void) awakeFromNib
{
    [self addRecognizers];
}

- (void) _tapGesture: (id)sender
{
    [pubController hideToolbars];
}
@end
