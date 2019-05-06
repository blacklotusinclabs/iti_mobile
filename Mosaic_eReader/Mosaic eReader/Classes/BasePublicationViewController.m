//
//  BasePublicationViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/14/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import "BasePublicationViewController.h"

@implementation BasePublicationViewController

@synthesize publication;

- (IBAction) returnToLibrary:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

@end
