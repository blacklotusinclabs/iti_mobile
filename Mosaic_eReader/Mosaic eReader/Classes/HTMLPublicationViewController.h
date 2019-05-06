//
//  HTMLPublicationViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/14/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"
#import "BasePublicationViewController.h"
#import "MLWebView.h"

@interface HTMLPublicationViewController : BasePublicationViewController
{
    BOOL toolbarVisible;
    
	IBOutlet UIView *topToolBar;
	IBOutlet MLWebView *webView;
    IBOutlet UIButton *libraryButton;
}

- (void) hideToolbars;

@end
