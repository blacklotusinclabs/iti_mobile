//
//  PublicationViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/27/10.
//  Copyright 2010 . All rights reserved.
//

#import "PublicationViewController.h"
#import "MLDownloadResult.h"
#import "MLDownloadResponse.h"
#import "PDFView.h"
#import "MLBookmarkPopoverController.h"
#import "MLDataStore.h"
#import "SearchModalViewController.h"
#import "TableOfContentsViewController.h"
#import "PaintingView.h"
#import "HighlightColorViewController.h"
#import "NoteListViewController.h"
#import "SearchCriteria.h"

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@implementation PublicationViewController

@synthesize publication;
@synthesize searchTerm;
// @dynamic currentPage;

- (void) startPageCachingThread
{
    if(bookThread != nil || [bookThread isExecuting])
    {
        [loadingView removeView];
        loadingView = nil;
        NSLog(@"Book caching already running, not starting new thread...");
        return;
    }
    [TestFlight passCheckpoint: @"Start Caching Thread"];

    // Start caching...
    if([[MLDataStore sharedInstance] isBookDoneCaching: publication.bookId] == NO)
    {
        // Start caching...
        bookThread = [[NSThread alloc] initWithTarget: [MLDataStore sharedInstance]
                                             selector: @selector(buildPagesCacheForBook:)
                                               object: self.publication.bookId];
        [bookThread start];    
        [progressButton setImage: [UIImage imageNamed: @"yellowbadge"] 
                        forState: UIControlStateNormal];
    }
    else
    {
        [self completePageCaching];
    }
}

- (void) stopPageCachingThread
{
    [bookThread cancel];
    [TestFlight passCheckpoint: @"Stop caching thread..."];

    [progressButton setImage: [UIImage imageNamed: @"redbadge"] 
                    forState: UIControlStateNormal];
    [loadingView removeView];
    bookThread = nil;
    loadingView = nil;
}

- (void) completePageCaching
{
    [TestFlight passCheckpoint: @"Completed caching..."];

    [progressButton setImage: [UIImage imageNamed: @"greenbadge"] 
                    forState: UIControlStateNormal];    
    [loadingView removeView];
    loadingView = nil;
}

- (void)configureForOrientation
{
    if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect frame = pdfView.frame;
        frame.size.height = 1366 + 200;
        CGSize contentSize = frame.size;
        contentSize.height -= 255;
        scrollView.contentSize = contentSize;
        pdfView.frame = frame;
    }
    else
    {
        CGRect frame; // = pdfView.frame;
        frame = CGRectMake(0, 0, 768, 1004);
        scrollView.frame = frame;
        scrollView.contentSize = frame.size;
        pdfView.frame = frame;        
    } 
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
    
    // NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [TestFlight passCheckpoint: @"In Publication View controller"];

    NS_DURING
    {
        pdfView.pubController = self;
        pdfView.numPages = publication.numPages;
        numPages = publication.numPages;
        [pdfView goToPage: 1];
        [pdfView setNeedsLayout];
        [self setSliderValue: 1];
        pdfView.pubController = self;
        slider.minimumValue = (float)1;
        slider.maximumValue = (float)numPages;
        maxPageNumber.text = [NSString stringWithFormat:@"%d",numPages];
        textfield.text = @"1";
        toolbarVisible = NO;
        bookThread = nil;
        // currentPage = 1;
        
        CGRect topbarRect = topToolBar.frame;
        CGRect bottombarRect = bottomToolBar.frame;
        
        topbarRect.origin.y -= 100;
        bottombarRect.origin.y += 100;
        
        [topToolBar setFrame: topbarRect];
        [bottomToolBar setFrame: bottombarRect];
        [self.view bringSubviewToFront: topToolBar];
        [self.view bringSubviewToFront: bottomToolBar];	
        
        bookmarkPopupController = [[MLBookmarkPopoverController alloc] init];
        searchPopupController = [[SearchModalViewController alloc] init];
        tocPopupController = [[TableOfContentsViewController alloc] init];
        highlightColorController = [[HighlightColorViewController alloc] init];
        noteListViewController = [[NoteListViewController alloc] init];
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource: @"Select" withExtension: @"caf"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileUrl error: NULL];
        highlighting = NO;
        
        // Scroll view.
        scrollView.contentSize = CGSizeMake(pdfView.frame.size.width, 
                                            pdfView.frame.size.height);
        scrollView.maximumZoomScale = 4.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.clipsToBounds = YES;
        scrollView.delegate = self;
        
        loadingView = nil;
        
        // Add observers...
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:) 
                                                     name:@"CachingStartedNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:) 
                                                     name:@"CachingCompleteNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:) 
                                                     name:@"CachingInterruptedNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:) 
                                                     name:@"AllowUserInteractionNotification"
                                                   object:nil];
        
        // Start loading view until we're told it's okay...
        if([[MLDataStore sharedInstance] isBookDoneCaching: publication.bookId] == NO)
        {
            loadingView = [LoadingView loadingViewInView: self.view withProgressView: NO];    
        }
        
        // Start caching...
        [self startPageCachingThread];
        
        [self configureForOrientation];
    }
    NS_HANDLER
    {
        [[self navigationController] popViewControllerAnimated: YES];
    }
    NS_ENDHANDLER;
    //[pool release];
}

- (void) handleNotification: (NSNotification *)notification
{
    NSString *name = [notification name];
    if([name isEqualToString:@"CachingStartedNotification"])
    {
        // [cachingIndicator setHidden: NO];
        [self startPageCachingThread];
    }
    else if([name isEqualToString:@"CachingCompleteNotification"])
    {
        // [cachingIndicator setHidden: YES];
        [self completePageCaching];
    }
    else if([name isEqualToString:@"CachingInterruptedNotification"])
    {
        [self stopPageCachingThread];
    }
    else if([name isEqualToString:@"CacheFaultNotification"])
    {
        [self stopPageCachingThread];
    }
    else if([name isEqualToString: @"AllowUserInteractionNotification"])
    {
        [loadingView removeView];
        loadingView = nil;
    }      
}

- (void) viewDidUnload
{
    // [self viewWillDisappear: NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [bookmarkPopupController release];
    bookmarkPopupController = nil;
    [searchPopupController release];
    searchPopupController = nil;
    [tocPopupController release];
    tocPopupController = nil;
    [highlightColorController release];
    highlightColorController = nil;
    [publication release];
    publication = nil;
    // [player release];
    // player = nil;
    [pdfView clear];
    [pdfView release];
    
    // Cancel the thread....
    [self stopPageCachingThread];
    [self release]; // FIXME: I'm not sure where it's getting retained...
}

- (void) dealloc
{
    [bookmarkPopupController release];
    bookmarkPopupController = nil;
    [searchPopupController release];
    searchPopupController = nil;
    [tocPopupController release];
    tocPopupController = nil;
    [highlightColorController release];
    highlightColorController = nil;
    [publication release];
    publication = nil;
    [player release];
    // player = nil;
    [pdfView clear];
    [pdfView removeFromSuperview];
    [pdfView release];
    [paintingView removeRecognizers];
    [paintingView removeFromSuperview];
    [paintingView release];
    [searchTerm release];
    
    // Cancel the thread....
    [self stopPageCachingThread];
    [super dealloc];
}

- (void) didReceiveMemoryWarning
{
    NSLog(@"%@ Stopping caching thread if present...",self);
    // [bookThread cancel]; 
}

/*
- (id) retain
{
    NSLog(@"%@ Controller retained: %d",self,[self retainCount]);
    return [super retain];
}

- (oneway void) release
{    
    NSLog(@"%@ Controller release: %d",self,[self retainCount]);
    [super release];
}
*/

- (IBAction) returnToLibrary: (id)sender
{
    [paintingView deactivate];
    [self commitPathsForCurrentPage];
    [super returnToLibrary: sender];
}

- (IBAction) goToPage: (id)sender
{
    pdfView.searchTerm = self.searchTerm;
    
    // [self stopPageCachingThread];
    [paintingView deactivate];
    [self commitPathsForCurrentPage];
    
	[textfield endEditing: YES];
	[textfield resignFirstResponder];
    
	NSUInteger page = (NSUInteger)[textfield.text intValue];
	[self setSliderValue: page];
	[pdfView goToPage: page];

    if(highlighting)
    {
        [paintingView activate];
    }
    // [self startPageCachingThread];
}

- (IBAction) slideToPage: (id)sender
{
	NSUInteger page = (NSUInteger)slider.value;

    // [self stopPageCachingThread];
    pdfView.searchTerm = self.searchTerm;
    [paintingView deactivate];
    currentPage = page;
    
	[pdfView goToPage: page];

    if(highlighting)
    {
        [paintingView activate];
    }  

    // [self startPageCachingThread];
}

- (void) goToPageNumber: (NSUInteger)page
{
    // [self stopPageCachingThread];
    // [player play];
    pdfView.searchTerm = self.searchTerm;
    
    [pdfView goToPage: page];
	[self setSliderValue: page];
    // [self startPageCachingThread];
}

- (void) goToPageForBookmark:(NSUInteger)page
{
    // [self stopPageCachingThread];
	[self goToPageNumber:page];
	[bookmarkPopover dismissPopoverAnimated: YES];
    // [self startPageCachingThread];
}

- (void) setSliderValue: (NSUInteger)page
{
	BOOL bookmarked =  [[MLDataStore sharedInstance] isPageNumberBookmarked:page inBook:publication];
    BOOL hasNote = [[MLDataStore sharedInstance] isNoteOnPage:page inBook:publication];

    //[paintingView deactivate];
	slider.value = (float)page;
    currentPage = page;

	textfield.text = [NSString stringWithFormat:@"%d",page];
	[bookmark setHidden: !bookmarked];
    [note setHidden:!hasNote];
    [paintingView replayPathsForCurrentPage];

    // Scroll to the top...
    CGPoint offset = CGPointMake(0, 0); // [scrollView contentSize].height);
    [scrollView setContentOffset: offset animated: YES];
    /*
    if(highlighting)
    {
        [paintingView activate];
    }
    */
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self goToPage: textField];
	[textField endEditing: YES];
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[self goToPage: textField];
	[textField resignFirstResponder];
}

- (void) nextPage: (id)sender
{
	NSUInteger page = slider.value + 1;
    
    pdfView.searchTerm = self.searchTerm;
    [paintingView deactivate];
    [self commitPathsForCurrentPage];
	[pdfView goToPage: page];
    if(highlighting)
    {
        [paintingView activate];
    }
}
	
- (void) previousPage: (id)sender
{
	NSUInteger page = slider.value - 1;
    
    pdfView.searchTerm = self.searchTerm;
    [paintingView deactivate];
    [self commitPathsForCurrentPage];
	[pdfView goToPage: page];
    if(highlighting)
    {
        [paintingView activate];
    }
}

- (IBAction) showTableOfContents: (id)sender
{
    /*
    tocPopover = [[UIPopoverController alloc] initWithContentViewController: tocPopupController];
	tocPopupController.publicationViewController = self;
    [tocPopupController refresh];
	[tocPopover presentPopoverFromRect: [sender frame]
                                inView: [self view]
              permittedArrowDirections: UIPopoverArrowDirectionAny
                              animated: YES];
     */
}

- (IBAction) textSearch: (id)sender
{
    if([[MLDataStore sharedInstance] isBookDoneCaching: publication.bookId])
    {
        searchPopover = [[UIPopoverController alloc] initWithContentViewController: searchPopupController];
        searchPopupController.publicationViewController = self;
        [searchPopover presentPopoverFromRect: [sender frame]
                                       inView: [self view]
                     permittedArrowDirections: UIPopoverArrowDirectionAny
                                     animated: YES];
    }
    else
    {
        UIAlertView *alert = [[[UIAlertView alloc] 
                               initWithTitle: publication.title
                               message: @"Search is unavailable until caching is completed."                               
                               delegate: self
                               cancelButtonTitle: @"OK" 
                               otherButtonTitles: nil]
                              autorelease];            
        [alert setTag:1];
        [alert show];
    }
}

- (void) alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)index
{
    // Do nothing for now...
}

- (IBAction) addBookmark: (id)sender
{
	bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController: bookmarkPopupController];
	bookmarkPopupController.publicationController = self;
	// bookmarkPopupController.pdf = pdfView.document;
	[bookmarkPopover presentPopoverFromRect: [sender frame]
                                     inView: [self view]
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES];
}

- (IBAction) addNote:(id)sender
{
    noteListPopover = [[UIPopoverController alloc] initWithContentViewController: noteListViewController];
    noteListViewController.publicationController = self;
    noteListViewController.currentPage = currentPage;
	[noteListPopover presentPopoverFromRect: [sender frame]
                                     inView: [self view]
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES];    
}

- (IBAction) addHighlighting:(id)sender
{  
    [player play];
    highlighting = YES;
    [paintingView activate];
    [self hideToolbars];
}

- (void) showToolbars
{
	toolbarVisible = YES;
	[UIView beginAnimations:@"MoveToolbarIn" context: nil];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
	
	CGRect topbarRect = topToolBar.frame;
	CGRect bottombarRect = bottomToolBar.frame;
	
	topbarRect.origin.y += 100;
	bottombarRect.origin.y -= 100;
	
	[topToolBar setFrame: topbarRect];
	[bottomToolBar setFrame: bottombarRect];
	
	[UIView commitAnimations];
}

- (void) hideToolbars
{
	toolbarVisible = NO;
	[UIView beginAnimations:@"MoveToolbarOut" context: nil];
	[UIView setAnimationDuration:.5];
	[UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
	
	CGRect topbarRect = topToolBar.frame;
	topbarRect.origin.y -= 100;
	[topToolBar setFrame: topbarRect];
    
	CGRect bottombarRect = bottomToolBar.frame;
	bottombarRect.origin.y += 100;
	[bottomToolBar setFrame: bottombarRect];
	
	[UIView commitAnimations];	
}

- (void) toggleToolbars
{
	if(toolbarVisible)
	{
		[self hideToolbars];
	}
	else
	{
		[self showToolbars];
	}
}

- (void) updatePage
{
    NSUInteger page = (NSUInteger)(slider.value);
    BOOL hasNote = [[MLDataStore sharedInstance] isNoteOnPage:page inBook:publication];
    [note setHidden:!hasNote];
    [noteListViewController refresh];
}

- (void) goToSelectedToc: (NSUInteger)reference
{
    [player play];
}

- (void) addBookmarkForCurrentPage
{
	[[MLDataStore sharedInstance] addBookmarkInBook: publication
											forPage: (NSUInteger)slider.value];
    BOOL flag = [[MLDataStore sharedInstance] 
                    isPageNumberBookmarked:(NSUInteger)slider.value
                                    inBook: publication];
    
    bookmark.hidden = !flag;
    [player play];
}

- (void) deleteBookmarkForCurrentPage
{
	[[MLDataStore sharedInstance] deleteBookmarkInBook: publication
											   forPage: (NSUInteger)slider.value];	
    BOOL flag = [[MLDataStore sharedInstance] 
                 isPageNumberBookmarked:(NSUInteger)slider.value
                 inBook: publication];
    
    bookmark.hidden = !flag;    
    [player play];
}

- (void) commitPathsForCurrentPage
{
    NSMutableArray *pathsForPage = paintingView.paths;
    if(pathsForPage != nil)
    {
        [[MLDataStore sharedInstance] addPaths:pathsForPage
                                       forPage:(NSUInteger)slider.value
                                        inBook:publication];
    }
}

- (IBAction) clearAll: (id)sender
{
    [paintingView clear];
    [self commitPathsForCurrentPage];    
}

- (IBAction) stop: (id)sender
{
    [player play];
    [self commitPathsForCurrentPage];
    [paintingView deactivate];
    highlighting = NO;
    [self showToolbars];
}

- (void) addNote
{
    [noteListPopover dismissPopoverAnimated: YES];
}

- (NSUInteger) currentPage
{
    return currentPage;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(fromInterfaceOrientation == UIInterfaceOrientationPortrait ||
       fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
        // we are going landscape
    {
        CGRect frame; // = pdfView.frame;
        frame = CGRectMake(0, 0, 1024, 1366);
        scrollView.frame = CGRectMake(0, 0, 1024, 768);
        scrollView.contentSize = frame.size;
        // self.view.frame = CGRectMake(0, 0, 1024, 768);
        pdfView.frame = frame;
    }
    else
    {
        CGRect frame; // = pdfView.frame;
        frame = CGRectMake(0, 0, 768, 1024);
        scrollView.frame = frame;
        scrollView.contentSize = frame.size;
        pdfView.frame = frame;        
    }
}

- (void) showSearchForCriteria:(SearchCriteria *)criteria
{
	searchPopover = [[UIPopoverController alloc] initWithContentViewController: searchPopupController];
	searchPopupController.publicationViewController = self;
	// searchPopupController.document = pdfView.document;
	[searchPopover presentPopoverFromRect: [searchButton frame]
                                   inView: [self view]
                 permittedArrowDirections: UIPopoverArrowDirectionAny
                                 animated: YES];  
    
    [searchPopupController doSearchFor: criteria.terms];
    self.searchTerm = criteria.terms;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return pdfView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [paintingView deactivate];
}

@end
