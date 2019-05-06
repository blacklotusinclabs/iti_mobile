//
//  PublicationViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/27/10.
//  Copyright 2010 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"
#import "NotepadViewController.h"
#import "LoadingView.h"
#import "BasePublicationViewController.h"

@class SearchCriteria, PDFView, MLBookmarkPopoverController, SearchModalViewController, TableOfContentsViewController, PaintingView, HighlightColorViewController, NoteListViewController, AVAudioPlayer;

@interface PublicationViewController : BasePublicationViewController <UIScrollViewDelegate>
{
    // Data
	NSUInteger numPages;
    NSUInteger currentPage;
	BOOL toolbarVisible;
    BOOL highlighting;

    // Outlet
	IBOutlet PDFView *pdfView;
	IBOutlet UISlider *slider;
	IBOutlet UITextField *textfield;
	IBOutlet UITextField *maxPageNumber;
	IBOutlet UIView *topToolBar;
	IBOutlet UIView *bottomToolBar;
	IBOutlet UIImageView *bookmark;
    IBOutlet UIImageView *note;
    IBOutlet PaintingView *paintingView;
    IBOutlet UIButton *searchButton;
    IBOutlet UIActivityIndicatorView *cachingIndicator;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *progressButton;
    
    // Controllers
	MLBookmarkPopoverController *bookmarkPopupController;
    TableOfContentsViewController *tocPopupController;
    SearchModalViewController *searchPopupController;
    HighlightColorViewController *highlightColorController;
    NoteListViewController *noteListViewController;
    NotepadViewController *notepadController;
    
	UIPopoverController *bookmarkPopover;
    UIPopoverController *searchPopover;
    UIPopoverController *tocPopover;
    UIPopoverController *highlightPopover;
    UIPopoverController *noteListPopover;
    
    // Audio
    AVAudioPlayer *player;
    NSThread *bookThread;
    
    LoadingView *loadingView;
    NSString *searchTerm;
    
    BOOL cachingComplete;
}

@property (nonatomic,retain) NSString *searchTerm;

- (IBAction) goToPage: (id)sender;
- (IBAction) slideToPage: (id)sender;
- (IBAction) nextPage: (id)sender;
- (IBAction) previousPage: (id)sender;
- (IBAction) showTableOfContents: (id)sender;
- (IBAction) textSearch: (id)sender;
- (IBAction) addBookmark: (id)sender;
- (IBAction) addNote: (id)sender;
- (IBAction) addHighlighting: (id)sender;
- (IBAction) stop: (id)sender;
- (IBAction) clearAll: (id)sender;

- (void) goToSelectedToc: (NSUInteger)reference;
- (void) addBookmarkForCurrentPage;
- (void) deleteBookmarkForCurrentPage;
- (void) goToPageForBookmark: (NSUInteger)page;
- (void) addNote;

- (void) setSliderValue: (NSUInteger)page;
- (void) goToPageNumber: (NSUInteger)page;
- (void) toggleToolbars;
- (void) updatePage;
- (void) showToolbars;
- (void) hideToolbars;
- (void) showSearchForCriteria: (SearchCriteria *)criteria;

- (NSUInteger) currentPage;
- (void) commitPathsForCurrentPage;

- (void) startPageCachingThread;
- (void) stopPageCachingThread;
- (void) completePageCaching;

@end
