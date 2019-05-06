//
//  HTMLPublicationViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 12/14/11.
//  Copyright (c) 2011 Open Logic Corporation. All rights reserved.
//

#import "HTMLPublicationViewController.h"
#import "MLDataStore.h"

@implementation HTMLPublicationViewController

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect topbarRect = topToolBar.frame;
    topbarRect.origin.y -= 100;
    [topToolBar setFrame: topbarRect];
    [self.view bringSubviewToFront: topToolBar];
    MLDataStore *ds = [MLDataStore sharedInstance];
    [ds unzipFileForBookId: self.publication.bookId];
    NSString *indexFile = [ds indexFileForBookId: self.publication.bookId];
    NSString *baseDir = [indexFile stringByDeletingLastPathComponent];
    NSURL *baseURL = [NSURL fileURLWithPath: baseDir isDirectory: YES];
    NSString *htmlString = [NSString stringWithContentsOfFile: indexFile encoding: NSUTF8StringEncoding error:NULL];
    [webView setPubController: self];
    [webView loadHTMLString: htmlString baseURL: baseURL];
    [webView reload];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MLDataStore *ds = [MLDataStore sharedInstance];
    [ds deleteFilesForBookId: self.publication.bookId];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Other Methods

- (void) hideToolbars
{
	toolbarVisible = NO;
	[UIView beginAnimations:@"MoveToolbarOut" context: nil];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
	
	CGRect topbarRect = topToolBar.frame;
	topbarRect.origin.y -= 100;
	[topToolBar setFrame: topbarRect];
    	
	[UIView commitAnimations];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end
