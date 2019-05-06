//
//  BasePublicationViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/14/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"

@interface BasePublicationViewController : UIViewController

@property (nonatomic,retain) MLBook *publication;

- (IBAction) returnToLibrary: (id)sender;

@end
