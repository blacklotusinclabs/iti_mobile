//
//  MLWebView.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/19/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTMLPublicationViewController;

@interface MLWebView : UIWebView
{
  	UITapGestureRecognizer *tapRecognizer;
    HTMLPublicationViewController *pubController;
}

@property (nonatomic,assign) HTMLPublicationViewController *pubController;

@end
