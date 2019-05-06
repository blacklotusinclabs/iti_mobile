//
//  BookshelfViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"
#import "AdvancedSearchViewController.h"
#import "MLAPICommunicator.h"

@class LoadingView;

@interface BookshelfViewController : UIViewController <MLAPIComminicatorDelegate> 
{
	MLBook *publication;
	int displayMode;
	int selectedTab;
	IBOutlet UITableView *controllerTableView;
	IBOutlet UIButton *toggleButton;
	IBOutlet UITextField *searchField;
	IBOutlet UISwitch *switchButton;
	IBOutlet UITextView *agreementView;
    NSTimer *downloadTimer;
	double currentPerc;
    NSTimeInterval timeInterval;
    double percentageIncrease;
	
	// External display...
    IBOutlet UIWindow *externalWindow;	
	UIScreen *externalScreen;
	IBOutlet UIImageView *mirrorImage;	
	NSArray *screenModes;	
    
    // View controllers...
    UIPopoverController *advancedSearchPopover;
    AdvancedSearchViewController *advancedSearchController;
    
    LoadingView *loadingView;
}


- (void) showPublication;
- (void) downloadPublication;
- (void) displayPublication: (NSData *)data;

- (void) selectBookWithTag:(NSUInteger)tag;
- (IBAction) toggleDisplay: (id)sender;
- (IBAction) searchLibrary: (id)sender;

// Switch to different libraries...
- (IBAction) segmentedControl: (id)sender;
- (IBAction) switchToMyLibrary: (id)sender;
- (IBAction) switchToITILibrary: (id)sender;
- (IBAction) switchToAvailableBooks: (id)sender;
- (IBAction) refresh: (id)sender;

// Logout
- (IBAction) logout:(id)sender;

// Search
- (IBAction) searchLibraryContent: (id)sender;

// Data refresh...
- (void) refreshData;
- (void) refreshDataFromServer;

// VGA switch...
- (IBAction) vgaSwitch: (id)sender;

// - (IBAction) button: (id)sender;

@end
