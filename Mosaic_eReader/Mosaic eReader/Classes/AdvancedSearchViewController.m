//
//  AdvancedSearchViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvancedSearchViewController.h"
#import "CustomCell.h"
#import "MLDataStore.h"
#import "MLBook.h"
#import "PDFSearcher.h"
#import "SearchResult.h"
#import "PublicationViewController.h"
#import "SearchCriteria.h"
#import "MLAPICommunicator.h"
#import "LoadingView.h"

static NSString *CellIdentifier = @"CustomCell";

@implementation AdvancedSearchViewController

@synthesize searchDownloaded, searchAvailable, searchNotAvailable, searchAll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) _searchStartedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AdvancedSearchStartedNotification"
                                                        object: nil];    
}

- (void) _searchEndedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AdvancedSearchEndedNotification"
                                                        object: nil];    
}

- (void) _searchUpdatedResultsNotification
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName: @"AdvancedSearchUpdatedResultsNotification"
     object: nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    searchDownloaded = YES;
    downloadPagesArray = [[NSMutableArray alloc] initWithCapacity: 10];
    bookListArray = [[NSMutableArray alloc] initWithCapacity:10];
    availableArray = [[NSMutableArray alloc] initWithCapacity:10];
    notAvailableArray = [[NSMutableArray alloc] initWithCapacity:10];
    [self update: self];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"AdvancedSearchStartedNotification"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"AdvancedSearchEndedNotification"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"AdvancedSearchUpdatedResultsNotification"
                                               object: nil];
    
    UIImage *image = [UIImage imageNamed: @"background.png"];
    UIImageView *eimageView = [[UIImageView alloc] initWithImage: image];
    [tableView setBackgroundColor: [UIColor clearColor]];
    [self.view addSubview: eimageView];
    [self.view sendSubviewToBack: eimageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [downloadPagesArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table delegate
// Customize the number of sections in the table view.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
    {
        return [NSString stringWithFormat: @"On Device (%d)",[bookListArray count]];
    }
    else if(section == 1)
    {
        return [NSString stringWithFormat: @"Available Books (%d)",[availableArray count]];
    }
    else if(section == 2)
    {
        return [NSString stringWithFormat: @"Library (%d)",[notAvailableArray count]];
    }
	return @"No books found";
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
    {
        return [bookListArray count];
    }
    else if(section == 1)
    {
        return [availableArray count];
    }
    else if(section == 2)
    {
        return [notAvailableArray count];
    }
	return 0;
}


// Customize the appearance of table view cells.
- (CustomCell *) _dequeueCustomCell: (UITableView *)tv
{
	CustomCell *cell = (CustomCell *) [tv dequeueReusableCellWithIdentifier: CellIdentifier];
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
                [cell retain]; //
				break;
			}
		}
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger section = [indexPath indexAtPosition: 0];

    CustomCell *cell = [self _dequeueCustomCell:tv];
    NSUInteger index = [indexPath indexAtPosition: 1];
    MLBook *result = nil;
    switch (section) 
    {
        case 0:
            result = [bookListArray objectAtIndex:index];
            break;
        case 1:
            result = [availableArray objectAtIndex:index];
            break;
        case 2:
            result = [notAvailableArray objectAtIndex:index];
            break;
        default:
            break;
    }
    
    UIImage *image = [[MLAPICommunicator sharedCommunicator] retrieveThumbnailArtForPublication: result]; 
    [cell.imageView setImage: image];
    cell.nameLabel.text = result.title;
    cell.messageLabel.text = @"";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger section = [indexPath indexAtPosition: 0];
    NSUInteger index = [indexPath indexAtPosition: 1];
    if(section == 0)
    {
        publication = [bookListArray objectAtIndex:index];
        
        NSData *pubData = nil; // [[MLAPICommunicator sharedCommunicator] retrieveDataForPublication:publication];
        publication.bookData = pubData;
        
        NSString *terms = searchField.text;
        SearchCriteria *criteria = [[SearchCriteria alloc] init];
        criteria.book = publication;
        criteria.terms = terms;
        [[NSNotificationCenter defaultCenter] postNotificationName: @"AdvancedSearchSelectedBookNotification" object:criteria]; 
        [criteria release];
    }
    if(section == 1)
    {
        publication = [availableArray objectAtIndex:index];
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
    if(section == 2)
    {
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
}

- (NSMutableArray *) searchBook: (MLBook *)book
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *resultsArray = [NSMutableArray array];
	NSString *searchFor = searchField.text;
    NSMutableArray *pagesResultsArray = [NSMutableArray array];

    // If we've done this search before... return the previously generated results,
    // since the book isn't going to change.
    NSMutableArray *array = nil; /*[[MLDataStore sharedInstance] cachedSearch: searchFor 
                                                               forBook: book]; */
    if(array != nil)
    {
        for(NSNumber *num in array)
        {
            SearchResult *result = [[SearchResult alloc] init];
            result.book = book;
            result.page = [num intValue];
            [resultsArray addObject: result];
            [result release];
        }
        return resultsArray;
    }
    
    // There is no cached data, do the search anyway.
	NSUInteger numPages = book.numPages;
	PDFSearcher *searcher = [[PDFSearcher alloc] init];
	
	NSLog(@"Searching book for %@",searchFor);
	
	size_t i = 0;
	for(i = 0; i < numPages; i++)
	{
        NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];
        NSUInteger pageNum = i + 1;
        // Get the cached page and search it's contents if this page has already been parsed before...
        NSMutableString *cacheData = nil; /*[[MLDataStore sharedInstance] getDataForBook: book
                                                                           onPage: pageNum]; */
        /*
		NSString *fileName = [[MLDataStore sharedInstance] fileNameForPage:pageNum
                                             withBookId:book.bookId];
        NSData *data = [[NSData alloc] initWithContentsOfFile:fileName];
         */
        NSData *data = [[MLDataStore sharedInstance] 
                        imageForBookId: book.bookId
                        onPage: pageNum];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);	
        CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
        CGPDFPageRef page = CGPDFDocumentGetPage(document,1);
        
		BOOL containsText = [searcher page: page 
							containsString: searchFor
                                  withData: cacheData];
        // [(NSObject *)page release];
        CGPDFDocumentRelease(document);
        CGDataProviderRelease(dataProvider);
        // remove PDF rendering context
        UIGraphicsEndPDFContext();
        
        //[data release];
        
		if(containsText)
		{
            SearchResult *result = [[SearchResult alloc] init];
            result.book = book;
            result.page = pageNum;
            [resultsArray addObject: result];
            [result release];
            [pagesResultsArray addObject: [NSNumber numberWithInt: pageNum]];
            
            if([bookListArray containsObject: book] == NO)
            {
                [bookListArray addObject: book];
                [self performSelectorOnMainThread: @selector(_searchUpdatedResultsNotification) withObject: nil waitUntilDone: NO];
            }
            
			NSLog(@"Page #%d contains %@",(int)pageNum,searchFor);
            [p2 release];
            break;
		}	
        
        /*
        [[MLDataStore sharedInstance] addData: searcher.currentData
                                      forBook: book
                                       onPage: pageNum];
         */
        [p2 release];
	}
    
    // Add cached results...
    /*
    [[MLDataStore sharedInstance] addCachedSearch: searchFor 
                                          forBook: book
                                          results: pagesResultsArray];*/

	[searcher release];
    [pool release];
    return resultsArray;
}

- (void) searchAllBooks: (NSString *)searchText
{
    NSMutableArray *booksToSearch = [NSMutableArray array];
    
    if(searchDownloaded)
    {
        [booksToSearch addObjectsFromArray: [[MLDataStore sharedInstance] allDownloadedBooks]];
        for(MLBook *book in booksToSearch)
        {
            //NSMutableArray *results = 
            [self searchBook: book];
            //[downloadPagesArray addObjectsFromArray: results];
        }
    }
    if(searchAvailable || searchNotAvailable)
    {
        NSArray *resultsArray = [[MLAPICommunicator sharedCommunicator] searchLibrary: searchField.text];
        NSArray *downloadedBooks = [[MLDataStore sharedInstance] allDownloadedBooks];
        for(MLBook *book in resultsArray)
        {
            if([book isAvailable] && searchAvailable)
            {
                if([downloadedBooks containsObject: book] == NO)
                {
                    [availableArray addObject: book];
                }
            }
            else if([book isAvailable] == NO && searchNotAvailable)
            {
                [notAvailableArray addObject: book];
            }
        }
    }
        
    
    [tableView reloadData];
}

#pragma mark - TextField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField endEditing: YES];
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
}

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void) _handleNotification: (NSNotification *)notification
{
    if([[notification name] isEqualToString: @"AdvancedSearchStartedNotification"])
    {
        loadingView = [LoadingView loadingViewInView: self.view withText: @"Searching..."];            
    }
    else if([[notification name] isEqualToString: @"AdvancedSearchEndedNotification"])
    {
        [loadingView removeView];
    }
    else
    {
        [tableView reloadData];
    }
}

- (void) _performSearch
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(_searchStartedNotification) withObject: nil waitUntilDone: NO];
    
    [bookListArray removeAllObjects];
    [availableArray removeAllObjects];
    [notAvailableArray removeAllObjects];
    [self searchAllBooks: [searchField text]];
    
    [self performSelectorOnMainThread: @selector(_searchEndedNotification) withObject: nil waitUntilDone: NO];
    [pool release];
}

- (IBAction) search: (id)sender
{
    [sender endEditing: YES];
	[sender resignFirstResponder];
    
    [NSThread detachNewThreadSelector:@selector(_performSearch)
                             toTarget:self 
                           withObject:nil];
}

- (IBAction) update: (id)sender
{
    searchDownloaded = allBooksSwitch.on;
    searchAvailable = availableBooksSwitch.on;
    searchNotAvailable = notAvailableBooksSwitch.on;
}


// Alert delegate function
- (void) alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)index
{
	if(alertView.tag == 99)
	{
		// Add code to send request here...
		return;
	}
	
	if(alertView.tag == 11) 
	{
        if(index == 1)
        {
            NSData *pubData = nil; // [[MLAPICommunicator sharedCommunicator] retrieveDataForPublication:publication];
            
            publication.bookData = pubData;
            
            NSString *terms = searchField.text;
            SearchCriteria *criteria = [[SearchCriteria alloc] init];
            criteria.book = publication;
            criteria.terms = terms;
            [[NSNotificationCenter defaultCenter] postNotificationName: @"AdvancedSearchSelectedBookNotification" object:criteria]; 
            [criteria release];
        }
    }
}
@end
