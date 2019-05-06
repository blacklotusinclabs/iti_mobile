//
//  HighlightColorViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PublicationViewController;

@interface HighlightColorViewController : UIViewController {
    NSArray *colors;
    PublicationViewController *publicationViewController;
}

@property (nonatomic,assign) PublicationViewController *publicationViewController;

@end
