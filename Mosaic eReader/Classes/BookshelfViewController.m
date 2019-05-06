//
//  BookshelfViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookshelfViewController.h"

#import "MLAPICommunicator.h"
#import "BookshelfCell.h"
#import "BookshelfCellLandscape.h"
#import "CustomCell.h"
#import "PublicationViewController.h"
#import "HTMLPublicationViewController.h"
#import "MLDataStore.h"
#import "UIImage+Resize.h"
#import "SearchCriteria.h"
#import "LoadingView.h"
#import "PDFSearcher.h"

#import <QuartzCore/QuartzCore.h>

static NSString *CellIdentifier = @"CustomCell";
static NSString *BSCellIdentifier = @"BSCustomCell";
static NSString *BSLCellIdentifier = @"BSLCustomCell";
#define UNSUBFLAG 1000000000

@implementation BookshelfViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[MLAPICommunicator sharedCommunicator] setDelegate: self];
        timeInterval = 1.0;
        percentageIncrease = 0.02;
    }
    return self;
}

- (void)dealloc
{
	[subscribed release];
	[available release];
	[allBooks release];
	[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [TestFlight passCheckpoint: @"Loaded Bookshelf..."];

	[super viewDidLoad];
    displayMode = 0;
    advancedSearchController = [[AdvancedSearchViewController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(handleNotification:) 
                                                 name:@"AdvancedSearchSelectedBookNotification" 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: @"DownloadedBookDataNotification"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: @"StartDownloadBookNotification"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: @"ShouldShowPublicationNotification"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: @"AbortShowPublicationNotification"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:) 
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    /*
    UIImage *image = [UIImage imageNamed: @"background.png"];
    UIImageView *eimageView = [[UIImageView alloc] initWithImage: image];
    [controllerTableView setBackgroundColor: [UIColor clearColor]];
    [self.view addSubview: eimageView];
    [self.view sendSubviewToBack: eimageView];
    */
    
    [self refreshData];
}

- (void) viewDidUnload
{
    // [super viewDidUnload];
    // loadingView = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    timeInterval = 1.0;
    percentageIncrease = 0.02;
    currentPerc = 0.0;
}

- (void)handleNotification: (NSNotification *)notif
{
    if([[notif name] isEqualToString: @"AdvancedSearchSelectedBookNotification"])
    {
        SearchCriteria *result = [notif object];
        [advancedSearchPopover dismissPopoverAnimated: YES];
        publication = result.book;
        [self showPublication];
    }
    else if([[notif name] isEqualToString: @"DownloadedBookDataNotification"])
    {
        //[loadingView removeView];
        //[self refreshData];
    }
    else if([[notif name] isEqualToString: @"StartDownloadBookNotification"])
    {    
        [TestFlight passCheckpoint: 
         [NSString stringWithFormat: @"starting download of book %@",
          publication.title]];

    }
    else if([[notif name] isEqualToString: @"ShouldShowPublicationNotification"])
    {
        NSData *rawData = [notif object];
        [TestFlight passCheckpoint: @"Display the publication..."];
        [self displayPublication: rawData];
    }
    else if([[notif name] isEqualToString: @"AbortShowPublicationNotification"])
    {
        [TestFlight passCheckpoint: 
         [NSString stringWithFormat: @"Showing of publication '%@' aborted..",
          publication.title]];

        [loadingView removeView];
    }  
    else if([[notif name] isEqualToString: UIDeviceOrientationDidChangeNotification])
    {
        // [TestFlight passCheckpoint: @"Change device orientation"];

        [controllerTableView reloadData];
    }
}

# pragma mark - Actions
/*
- (IBAction) button: (id)sender
{
    DummyViewController *dvc = [[DummyViewController alloc] init];
    [self.navigationController pushViewController: dvc
                                         animated:YES];    
}
*/

- (IBAction) toggleDisplay: (id)sender
{
	if(displayMode == 0)
	{
		displayMode = 1;
		[toggleButton setImage: [UIImage imageNamed: @"btn_shelfType02.png"] forState: UIControlStateNormal];
	}
	else
	{
		displayMode = 0;
		[toggleButton setImage: [UIImage imageNamed: @"btn_shelfType01.png"] forState: UIControlStateNormal];
	}
	[controllerTableView reloadData];
}

- (IBAction) searchLibrary: (id)sender
{
	[searchField endEditing: YES];
    
	if(displayMode == 0)
	{
		[self toggleDisplay: sender];
	}
	
	[controllerTableView reloadData];
	if([searchField.text isEqual: @""] == NO)
	{
		NSMutableArray *array = [NSMutableArray array];
		for(MLBook *book in subscribed)
		{
			NSString *title = book.title;
			NSRange r = [[title uppercaseString] rangeOfString: [searchField.text uppercaseString]];
			if(!NSEqualRanges(r, NSMakeRange(NSNotFound,0)))
			{
				[array addObject: book];
			}
		}
		subscribed = [array retain];
        
		array = [NSMutableArray array];
		for(MLBook *book in available)
		{
			NSString *title = book.title;
			NSRange r = [[title uppercaseString] rangeOfString: [searchField.text uppercaseString]];
			if(!NSEqualRanges(r, NSMakeRange(NSNotFound,0)))
			{
				[array addObject: book];
			}
		}
		available = [array retain];
		
		
		array = [NSMutableArray array];
		for(MLBook *book in allBooks)
		{
			NSString *title = book.title;
			NSRange r = [[title uppercaseString] rangeOfString: [searchField.text uppercaseString]];
			if(!NSEqualRanges(r, NSMakeRange(NSNotFound,0)))
			{
				[array addObject: book];
			}
		}
		allBooks = [array retain];		
	}
	else
	{
		[self refreshData];
	}
	[controllerTableView reloadData];
}


- (IBAction) searchLibraryContent:(id)sender
{
    advancedSearchPopover = [[UIPopoverController alloc] initWithContentViewController: advancedSearchController];
    advancedSearchPopover.popoverContentSize = CGSizeMake(400, 600);
	[advancedSearchPopover presentPopoverFromRect: [sender frame]
                                     inView: [self view]
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES];    
    /*
    [advancedSearchController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];    
    [self presentModalViewController: advancedSearchController
                            animated: YES];
    [advancedSearchController release];
     */
}

// Switch to different libraries...
- (IBAction) switchToMyLibrary: (id)sender
{
	selectedTab = 0;
	// [self refreshData];
	[controllerTableView reloadData];
}

- (IBAction) switchToITILibrary: (id)sender
{
	selectedTab = 1;
	// [self refreshData];
	[controllerTableView reloadData];
}

- (IBAction) switchToAvailableBooks: (id)sender
{
	selectedTab = 2;
	// [self refreshData];
	[controllerTableView reloadData];
}

- (IBAction) segmentedControl: (id)sender
{
	NSInteger indexOfSelected = [sender selectedSegmentIndex];
	switch (indexOfSelected)
	{
		case 0:
			[self switchToMyLibrary: sender];
			break;
		case 1:
			[self switchToAvailableBooks: sender];
			break;
		case 2:
			[self switchToITILibrary: sender];
			break;
		default:
			NSLog(@"Unknown");
			break;
	}
}

- (IBAction) refresh:(id)sender
{
	[self refreshDataFromServer];
	[controllerTableView reloadData];	
}

- (IBAction) vgaSwitch: (id)sender
{
	// Check for external screen.
	if ([[UIScreen screens] count] > 1) {
		
		// Internal display is 0, external is 1.
		externalScreen = [[[UIScreen screens] objectAtIndex:1] retain];
		
		screenModes = [externalScreen.availableModes retain];
		
		// set view up a little, since it has a status bar on top...
		CGRect frame = mirrorImage.frame;
		frame.origin.y -= 22;
		mirrorImage.frame = frame;		
		
		// Allow user to choose from available screen-modes (pixel-sizes).
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"External Display Size" 
														 message:@"Choose a size for the external display." 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:nil] autorelease];
		for (UIScreenMode *mode in screenModes) {
			CGSize modeScreenSize = mode.size;
			[alert addButtonWithTitle:[NSString stringWithFormat:@"%.0f x %.0f pixels", modeScreenSize.width, modeScreenSize.height]];
		}
		[alert setTag: 50];
		[alert show];
		
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"No external display found." 
														 message:@"Could not find any external displays." 
														delegate:self 
											   cancelButtonTitle:@"Dismiss" 
											   otherButtonTitles:nil] autorelease];		
		[alert setTag: 99];
		[alert show];
	}	
}

- (IBAction)logout:(id)sender
{
    MLAPICommunicator *communicator = [MLAPICommunicator sharedCommunicator];
    [self.navigationController popToRootViewControllerAnimated: YES];
    [TestFlight passCheckpoint: @"logging out..."];

    [communicator logout];
}

# pragma mark - Delegate methods.

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
	[self searchLibrary: textField];
	[textField endEditing: YES];
	[textField resignFirstResponder];
	return YES;
}

- (void) refreshData
{
	if([searchField.text isEqualToString: @""] == NO &&
	   searchField.text != nil)
	{
		return;
	}
	
	[subscribed release];
	[available release];
	[allBooks release];
	
	subscribed = [[MLAPICommunicator sharedCommunicator] 
	 			  retrieveDownloadedBooks];
	available = [[MLAPICommunicator sharedCommunicator]
				 retrieveListOfAvailableBooks];
	allBooks =  [[MLAPICommunicator sharedCommunicator]	
				 retrieveListOfNotAvailableBooks];
    
    /*
    NSArray *accessibleBooks = [[MLDataStore sharedInstance] accessibleBooks];
    for(MLBook *book in [NSArray arrayWithArray: subscribed])
    {
        if([accessibleBooks containsObject: book] == NO)
        {
            [subscribed removeObject: book];
        }
    }
    */
    
    // Pre-cache the cover art for all books...
    MLAPICommunicator *communicator = [MLAPICommunicator sharedCommunicator];
    [communicator retrieveThumbnailsForPublications: subscribed];
    [communicator retrieveThumbnailsForPublications: available];
    [communicator retrieveThumbnailsForPublications: allBooks];
    
    
	[subscribed retain];
	[available retain];
	[allBooks retain];
	
	[controllerTableView reloadData];
}

- (void) refreshDataFromServer
{
	MLDataStore *dataStore = [MLDataStore sharedInstance];
	[dataStore clearStoreExceptUserBooks];
	[self refreshData];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(displayMode == 1)
	{
		tableView.rowHeight = 150;	
	}
	else
	{
		tableView.rowHeight = 187;		
	}
	
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSInteger count = 0;
    
	if(selectedTab == 0) // My Library
	{
		count = [subscribed count];
	}
	else if(selectedTab == 1) // iTi Library
	{
		count = [allBooks count];
	}
	else if(selectedTab == 2) // Available Books
	{
		count = [available count];
	}
	
	return [NSString stringWithFormat: @"%d books",count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
    NSInteger cols = 4;
    
    if(UIDeviceOrientationIsLandscape(self.interfaceOrientation))
    {
        cols = 6;
    }
	
	if(displayMode == 0)
	{
		if(selectedTab == 0)
		{
			rows = ([subscribed count] / cols) + 1; 
		}
		else if(selectedTab == 2)
		{
			rows = ([available count] / cols) + 1;
		}
		else if(selectedTab == 1)
		{
			rows = ([allBooks count] / cols) + 1;
		}
		
		if(rows < 6)
		{
			rows += (6 - rows);
		}
	}
	else
	{
		if(selectedTab == 0)
		{
			rows = [subscribed count];
		}
		else if(selectedTab == 2)
		{
			rows = [available count];
		}				
		else if(selectedTab == 1)
		{
			rows = [allBooks count];
		}
	}
	
	return rows;
}


// Customize the appearance of table view cells.
// Custom cell handling...
- (CustomCell *) _dequeueCustomCell: (UITableView *)tableView
{
	CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	if(cell == nil) 
	{
		NSArray *topLevelObjects = nil;
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"CustomCell"
														owner: nil 
													  options: nil];
		
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass: [UITableViewCell class]])
			{
				cell = (CustomCell *) currentObject;
                //[cell retain]; //
				break;
			}
		}
        
        //[topLevelObjects autorelease];
	}
	return cell;
}

- (BookshelfCell *) _dequeueBookshelfCell: (UITableView *)tableView
{
    BookshelfCell *cell = nil;
    NSArray *topLevelObjects = nil;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(UIDeviceOrientationIsPortrait(self.interfaceOrientation)) 
	{
        cell = (BookshelfCell *) [tableView dequeueReusableCellWithIdentifier: BSCellIdentifier];
        if(cell == nil)
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"BookshelfCell" 
                                                            owner: nil 
                                                          options: nil];            
        }
	}
    else
    {
        cell = (BookshelfCell *) [tableView dequeueReusableCellWithIdentifier: BSLCellIdentifier];
        if(cell == nil)
        {
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"BookshelfCellLandscape" 
                                                            owner: nil 
                                                          options: nil];
        }        
    }
        
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass: [UITableViewCell class]])
        {
            cell = (BookshelfCell *) currentObject;
            [cell retain];
            break;
        }
    }
    [pool release];
    
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger cols = 4;
    
    if(UIDeviceOrientationIsLandscape(self.interfaceOrientation))
    {
        cols = 6;
    }
    
	// NSLog(@".....");
	if(displayMode == 0)
	{
		// NSUInteger section = [indexPath indexAtPosition: 0];    	
		NSUInteger index = [indexPath indexAtPosition: 1];
		NSUInteger startIndex = index * cols;
		NSUInteger realIndex = 0;
		NSArray *array = nil;
		NSUInteger flag = 0;
		
		if(selectedTab == 0)
		{
			flag = 0;
			array = subscribed;
		}
		else if(selectedTab == 2)
		{
			flag = UNSUBFLAG;
			array = available;
		}
		else
		{
			flag = UNSUBFLAG;
			array = allBooks;
		}
		
		BookshelfCell *cell = [self _dequeueBookshelfCell: tableView];
        /*
		if (cell == nil) 
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier];
            [cell autorelease];
		}
         */
		cell.viewController = self;
		
		if([array count] == 0)
		{
			return cell;
		}
		
		// Configure the cell.
		NSMutableArray *bookCells = [NSMutableArray arrayWithCapacity: 10];
		NSMutableArray *shadowCells = [NSMutableArray arrayWithCapacity: 10];
        [bookCells addObject: cell.bookImage1];
        [bookCells addObject: cell.bookImage2];
        [bookCells addObject: cell.bookImage3];
        [bookCells addObject: cell.bookImage4];
        
        [shadowCells addObject: cell.shadow1];
        [shadowCells addObject: cell.shadow2];
        [shadowCells addObject: cell.shadow3];
        [shadowCells addObject: cell.shadow4];
        
        if([cell isKindOfClass: [BookshelfCellLandscape class]])
        {
            BookshelfCellLandscape *newCell = (BookshelfCellLandscape *)cell;
            [bookCells addObject:   newCell.bookImage5];
            [bookCells addObject:   newCell.bookImage6];
            [shadowCells addObject: newCell.shadow5];
            [shadowCells addObject: newCell.shadow6];
        }
		NSUInteger cellIndex = 0;
		for(realIndex = startIndex; (realIndex < startIndex + cols) && realIndex < [array count]; realIndex++)
		{
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			cellIndex = realIndex % cols;
			MLBook *book = [array objectAtIndex: realIndex];
			UIImage *image = [[MLAPICommunicator sharedCommunicator] retrieveThumbnailArtForPublication: book]; 
			UIButton *imageView = [bookCells objectAtIndex: cellIndex];
			UIImageView *shadowView = [shadowCells objectAtIndex: cellIndex];
			
			[imageView setBackgroundImage: image forState: UIControlStateNormal];
			[imageView setEnabled: YES];
			[imageView setTag: flag + realIndex];
			[shadowView setHidden: NO];
            [pool release];
		}
		
		return cell;
	}
	else
	{
		NSUInteger index = [indexPath indexAtPosition: 1];
		NSString *name = nil;
		NSString *description = nil;
		UIImage *image = nil;
		NSArray *array = nil;
		//NSUInteger flag = 0;
		
		if(selectedTab == 0)
		{
            //	flag = 0;
			array = subscribed;
		}
		else if(selectedTab == 2)
		{
            //	flag = UNSUBFLAG;
			array = available;
		}
		else
		{
            //	flag = UNSUBFLAG;
			array = allBooks;
		}
		
		
		// Get the items out of the array selected...
		MLBook *book = [array objectAtIndex: index];
		name = [book title];
		description = [book summary];
		image = [[MLAPICommunicator sharedCommunicator] retrieveThumbnailArtForPublication: book]; 
		CustomCell *cell = [self _dequeueCustomCell: tableView];
        /*
		if (cell == nil) 
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier];
            [cell autorelease];
		}
		*/
		// Configure the cell.
		cell.nameLabel.text = name;
		cell.messageLabel.text = description;
		cell.imageView.image = image;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(displayMode == 0)
		return;
	
	NSUInteger index = [indexPath indexAtPosition: 1];
	
	if(selectedTab == 0)
	{
        if(index < [subscribed count])
        {
            publication = [subscribed objectAtIndex: index];
            [self showPublication];
        }
    }
	else if(selectedTab == 2)
	{
        if(index < [available count])
        {
            publication = [available objectAtIndex: index];
            NSString *agreementPath = 
            [[NSBundle mainBundle] pathForResource:@"ITI_Download_Agreement" 
                                            ofType: @"txt"];
            NSString *agreementText = [NSString stringWithContentsOfFile: agreementPath
                                                                encoding: NSUTF8StringEncoding
                                                                   error: NULL];
            UIAlertView *alert = [[[UIAlertView alloc] 
                                   initWithTitle: publication.title
                                   message: agreementText                                 
                                   delegate: self
                                   cancelButtonTitle: @"I Decline" 
                                   otherButtonTitles: @"I Accept",nil]
                                  autorelease];            
            [alert setTag:11];
            [alert show];
        }
    }
	else if(selectedTab == 1)
	{
		if([available count] == 0)
		{
			return;
		}
        
		UIAlertView *alert = [[[UIAlertView alloc] 
							   initWithTitle: @"" 
							   message: @"If you are interested in downloading this book, please contact your local JATC Coordinator." 
							   delegate: nil
							   cancelButtonTitle: @"OK" 
							   otherButtonTitles: nil] 
							  autorelease];
		[alert setTag:99];
		[alert show];				
	}
    
	[self refreshData];
}

- (void)selectBookWithTag: (NSUInteger)tag
{
	NSUInteger index = 0; 
	
	if(selectedTab == 0)
	{
		index = tag; 
	}
	else
	{
		index = tag - UNSUBFLAG;
	}
	
	if(selectedTab == 0)
	{
		if([subscribed count] == 0)
		{
			return;
		}
		
        if(index < [subscribed count])
        {
            publication = [subscribed objectAtIndex: index];
            [self showPublication];
        }
	}
	else if(selectedTab == 2)
	{
		if([available count] == 0)
		{
			return;
		}
		
        if(index < [available count])
        {
            publication = [available objectAtIndex: index];
            NSString *agreementPath = 
                [[NSBundle mainBundle] pathForResource:@"ITI_Download_Agreement" 
                                                ofType: @"txt"];
            NSString *agreementText = [NSString stringWithContentsOfFile: agreementPath
                                                                encoding: NSUTF8StringEncoding
                                                                   error: NULL];
            UIAlertView *alert = [[[UIAlertView alloc] 
                                   initWithTitle: publication.title
                                   message: agreementText                                 
                                   delegate: self
                                   cancelButtonTitle: @"I Decline" 
                                   otherButtonTitles: @"I Accept",nil]
                                  autorelease];
            [alert setTag:11];
            [alert show];
        }
	}
	else if(selectedTab == 1)
	{
		if([available count] == 0)
		{
			return;
		}
        
		UIAlertView *alert = [[[UIAlertView alloc] 
							   initWithTitle: @"" 
							   message: @"If you are interested in downloading this book, please contact your local JATC Coordinator." 
							   delegate: nil
							   cancelButtonTitle: @"OK" 
							   otherButtonTitles: nil] 
							  autorelease];
		[alert setTag:99];
		[alert show];				
	}
	[self refreshData];
}

- (void) alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)index
{
	if(alertView.tag == 99)
	{
		// Add code to send request here...
		return;
	}
	
	if(alertView.tag == 50)
	{
		UIScreenMode *desiredMode = [screenModes objectAtIndex:index];
		externalScreen.currentMode = desiredMode;
		externalWindow.screen = externalScreen;
		
		CGRect rect = CGRectZero;
		rect.size = desiredMode.size;
		externalWindow.frame = rect;
		externalWindow.clipsToBounds = YES;
		
		externalWindow.hidden = NO;
		[externalWindow makeKeyAndVisible];
		
		[NSTimer scheduledTimerWithTimeInterval:0.02
										 target:self 
                                       selector:@selector(takeCapture:)
									   userInfo:nil 
										repeats:YES];	
		
	}
	
	if(index == 1) 
	{
		[self showPublication];
	}
}

#pragma mark - Screen Capture methods

- (UIImage*)screenshot 
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    // Iterate over every window from back to front
    for (UIWindow *awindow in [[UIApplication sharedApplication] windows]) 
    {
        if (![awindow respondsToSelector:@selector(screen)] || [awindow screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [awindow center].x, [awindow center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [awindow transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[awindow bounds].size.width * [[awindow layer] anchorPoint].x,
                                  -[awindow bounds].size.height * [[awindow layer] anchorPoint].y);
			
            // Render the layer hierarchy to the current context
            [[awindow layer] renderInContext:context];
			
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
	
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    return image;
}

- (void) takeCapture: (NSTimer *)timer
{
	UIImage *screenImage = [self screenshot];
	CGRect screenRect = externalScreen.bounds;
	
	// Calculations for resizing view...
	float ratio =  screenRect.size.height / screenRect.size.width;
	CGSize newSize;
	newSize.height = screenRect.size.height;
	newSize.width = screenImage.size.width * ratio;
	UIImage *newImage = [screenImage imageScaledToSize: newSize];
	
	// Calculate offset for image...
	float xoffset = ((screenRect.size.width - newSize.width)/2);
	CGRect newFrame = mirrorImage.frame;
	newFrame.origin.x = xoffset;
    newFrame.origin.y = 0.0;
	newFrame.size = newSize;
	mirrorImage.frame = newFrame;
	mirrorImage.image = newImage;
}

#pragma mark - Other methods

- (void)_shouldShowPublication: (NSData *)rawData
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName: @"ShouldShowPublicationNotification"
     object: nil];    
}

- (void) _abortShowPublication: (NSString *)message
{
    [loadingView removeView];
    
    UIAlertView *alert = [[[UIAlertView alloc] 
                           initWithTitle: @"" 
                           message: message 
                           delegate: nil
                           cancelButtonTitle: @"OK" 
                           otherButtonTitles: nil] 
                          autorelease];
    [alert setTag:99];
    [alert show];	    
}


- (void) downloadPublication
{
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    BOOL success = NO;
    int retries = 0;
    NSString *reason = nil;
    
    while(success == NO && retries < 5)
    {
        NS_DURING
        {
            MLDataStore *ds = [MLDataStore sharedInstance];
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            [[MLAPICommunicator sharedCommunicator] retrieveDataForPublication: publication];  
            if([publication.type isEqualToString: @"PDF"])
            {
                [ds imageForBookId: publication.bookId onPage: 1];
            }
            [self performSelectorOnMainThread: @selector(_shouldShowPublication:)
                                   withObject: nil
                                waitUntilDone: NO];
            success = YES;
            [pool release];
        }
        NS_HANDLER
        {
            reason = [localException reason];// [[NSString alloc] initWithString: [localException reason]];
            NSLog(@"Exception thrown while retrieving data: %@, retry = %d, bookId = %@, book Title = %@",reason,retries,publication.bookId,publication.title);
            [TestFlight passCheckpoint: [NSString stringWithFormat: @"Exception thrown while retrieving data: %@, retry = %d, bookId = %@, book Title = %@",reason,retries,publication.bookId,publication.title]];
            [[MLDataStore sharedInstance] removeBook: publication.bookId];
            [[MLDataStore sharedInstance] removeDataForBookId: publication.bookId];
        }
        NS_ENDHANDLER;
        retries++;
    }
    
    if(success == NO)
    {
        [self performSelectorOnMainThread: @selector(_abortShowPublication:)
                               withObject: reason
                            waitUntilDone: YES];
        // [reason release];
    }
    [p release];
}

- (void) updateTimer: (NSTimer *)timer
{
    currentPerc += percentageIncrease;
    [loadingView setProgress: currentPerc];    
}

- (void) initializeTimer
{
    [downloadTimer invalidate];
    downloadTimer = nil;
    [loadingView setProgress: currentPerc];
    downloadTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                                     target:self 
                                                   selector:@selector(updateTimer:) 
                                                   userInfo:nil 
                                                    repeats:YES];
}

- (void) stopTimer
{
    [downloadTimer invalidate];
    downloadTimer = nil;
    [loadingView setProgress: 1.0];
    currentPerc = 0.0;
}

- (void) displayPublication: (NSData *)rawData
{
    if([publication.type isEqualToString: @"PDF"])
    {
        PublicationViewController *pvc = [[PublicationViewController alloc] init];
        pvc.publication = publication;
        [self stopTimer];
        [self.navigationController pushViewController: pvc
                                             animated: YES];
        [pvc release];
        [loadingView removeView];
        loadingView = nil;
        
        [self refreshData];
    }
    else
    {
        HTMLPublicationViewController *pvc = [[HTMLPublicationViewController alloc] init];
        pvc.publication = publication;
        [self stopTimer];
        [self.navigationController pushViewController: pvc
                                             animated: YES];
        [pvc release];
        [loadingView removeView];
        loadingView = nil;
        
        [self refreshData];
        
    }
}

- (void) showPublication
{	
    loadingView = [LoadingView loadingViewInView: self.view withProgressView: YES];   
    [NSThread detachNewThreadSelector:@selector(downloadPublication)
                             toTarget:self 
                           withObject:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) didReceiveMemoryWarning
{
    NSLog(@"%@ recieved memory warning.",self);
}

- (void) setTimeIntervalForDownload:(NSTimeInterval)value
{
    timeInterval = value;
    [self initializeTimer];
}

- (void) setPercentageIncrease:(double)perc
{
    percentageIncrease = perc;
    [self initializeTimer];
}

- (void) setProgress: (double)perc
{
    [loadingView setProgress: perc];
}
@end
