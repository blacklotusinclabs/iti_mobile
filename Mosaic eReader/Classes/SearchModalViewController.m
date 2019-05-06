//
//  AdvancedSearchModalViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 3/31/11.
//  Copyright 2011 . All rights reserved.
//

#import "SearchModalViewController.h"
#import "PDFSearcher.h"
#import "PDFPageCell.h"
#import "MLDataStore.h"
#import "LoadingView.h"
#import "MLDataStore.h"
#import "UIImage+Resize.h"
#import "Scanner.h"

static NSString *CellIdentifier = @"PDFPageCell";

@implementation SearchModalViewController

@synthesize publicationViewController;

- (void) viewDidLoad
{
	[super viewDidLoad];
    termsArray = [[NSMutableArray alloc] initWithCapacity: 10];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"SearchStartedNotification"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"SearchEndedNotification"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(_handleNotification:) 
                                                 name: @"SearchUpdatedResultsNotification"
                                               object: nil];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    
    [termsArray release];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (BOOL) textFieldShouldReturn: (UITextField *)textField
{
	// [self searchBook: textField];
    // [resultsTable reloadData];
	[textField endEditing: YES];
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textFieldShouldClear: (UITextField *)textField
{
    publicationViewController.searchTerm = nil;
    // [termsArray removeAllObjects];
    [resultsTable reloadData];
    [publicationViewController goToPageForBookmark: publicationViewController.currentPage];
    return YES;
}

- (void) _handleNotification: (NSNotification *)notification
{
    if([[notification name] isEqualToString: @"SearchStartedNotification"])
    {
        loadingView = [LoadingView loadingViewInView: self.view withText: @"Searching..."];        
    }
    else if([[notification name] isEqualToString: @"SearchEndedNotification"])
    {
        [loadingView removeView];
    }
    else
    {
        [resultsTable reloadData];
    }
}

- (void) _searchStartedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"SearchStartedNotification"
                                                        object: nil];    
}

- (void) _searchEndedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"SearchEndedNotification"
                                                        object: nil];    
}

- (void) _searchUpdatedResultsNotification
{
    [[NSNotificationCenter defaultCenter] 
     postNotificationName: @"SearchUpdatedResultsNotification"
     object: nil];
}

- (void) _goToPage: (NSNumber *)page
{
    [publicationViewController goToPageForBookmark: [page intValue]];
}


- (void) _performSearch
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(_searchStartedNotification) withObject:nil waitUntilDone:NO];
	NSString *searchFor = searchContentField.text;
    publicationViewController.searchTerm = searchFor;
        
    // There is no cached data, do the search anyway.
    MLBook *book = [[MLDataStore sharedInstance] retrieveBook: publicationViewController.publication.bookId];
	NSUInteger numPages = book.numPages;
	NSLog(@"Searching book for %@",searchFor);
	
	size_t i = publicationViewController.currentPage;
	while(YES)
	{
        if (i > numPages)
        {
            i = 0;
        }
        
        if(i == publicationViewController.currentPage - 1) // wrapped back...
        {
            break;
        }
        NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];
        NSUInteger pageNum = i + 1;
        NSData *data = [[MLDataStore sharedInstance] 
                        imageForBookId: publicationViewController.publication.bookId
                                onPage: pageNum];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);	
        CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
        CGPDFPageRef page = CGPDFDocumentGetPage(document,1);
                
        Scanner *searcher = [[Scanner alloc] init];   
        searcher.keyword = searchFor;
        [searcher scanPage: page];
        NSArray *selections = searcher.selections;
        BOOL containsText = ([selections count] > 0);
        [searcher release];
        [selections release];
        
        CGPDFDocumentRelease(document);
        CGDataProviderRelease(dataProvider);
        // remove PDF rendering context
        UIGraphicsEndPDFContext();
        
		if(containsText)
		{
			NSLog(@"Page #%d contains %@",(int)pageNum,searchFor);

            [self performSelectorOnMainThread: @selector(_searchUpdatedResultsNotification) withObject: nil waitUntilDone: NO];
            [self performSelectorOnMainThread: @selector(_goToPage:)
                                   withObject: [NSNumber numberWithInt: pageNum]
                                waitUntilDone: NO];

            [p2 release];
            break;
		}	
        
        [p2 release];
        i++;
	}
    
    // Add cached results...
	[resultsTable reloadData];
    [pool release];
    [self performSelectorOnMainThread: @selector(_searchEndedNotification) withObject: nil waitUntilDone: YES];    
}

- (void) _performSearchBackwards
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread: @selector(_searchStartedNotification) withObject:nil waitUntilDone:NO];
	NSString *searchFor = searchContentField.text;
    publicationViewController.searchTerm = searchFor;
    
    // There is no cached data, do the search anyway.
	NSLog(@"Searching book for %@",searchFor);
	
	size_t i = publicationViewController.currentPage - 2;
	while(YES)
	{
        if(i <= 0)
        {
            i = publicationViewController.publication.numPages; // wrap around backwards...
        }
        if(i == publicationViewController.currentPage + 1)
        {
            break;
        }
        NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init];
        NSUInteger pageNum = i + 1;
        NSData *data = [[MLDataStore sharedInstance] 
                        imageForBookId: publicationViewController.publication.bookId
                        onPage: pageNum];
        CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);	
        CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
        CGPDFPageRef page = CGPDFDocumentGetPage(document,1);
        
        Scanner *searcher = [[Scanner alloc] init];   
        searcher.keyword = searchFor;
        [searcher scanPage: page];
        NSArray *selections = searcher.selections;
        BOOL containsText = ([selections count] > 0);
        [searcher release];
        [selections release];
        
        CGPDFDocumentRelease(document);
        CGDataProviderRelease(dataProvider);
        
		if(containsText)
		{
			NSLog(@"Page #%d contains %@",(int)pageNum,searchFor);
            
            [self performSelectorOnMainThread: @selector(_searchUpdatedResultsNotification) withObject: nil waitUntilDone: NO];
            [self performSelectorOnMainThread: @selector(_goToPage:)
                                   withObject: [NSNumber numberWithInt: pageNum]
                                waitUntilDone: NO];
            [p2 release];
            break;
		}	
        
        [p2 release];
        i--;
	}
    
    // Add cached results...
	[resultsTable reloadData];
    [pool release];
    [self performSelectorOnMainThread: @selector(_searchEndedNotification) withObject: nil waitUntilDone: YES];
}


- (IBAction) searchBook: (id)sender
{
    if([termsArray containsObject: searchContentField.text] == NO &&
       [searchContentField.text isEqualToString: @""] == NO &&
       searchContentField.text != nil )
    {
        [termsArray insertObject: searchContentField.text atIndex: 0];
        [resultsTable reloadData];
    }
    [sender endEditing: YES];
	[sender resignFirstResponder];
    
    // [self _performSearch];
    [NSThread detachNewThreadSelector:@selector(_performSearch)
                             toTarget:self 
                           withObject:nil];
}

- (IBAction)next:(id)sender
{
    [self searchBook: sender];
}

- (IBAction)previous:(id)sender
{
    if([termsArray containsObject: searchContentField.text] == NO &&
       [searchContentField.text isEqualToString: @""] == NO &&
       searchContentField.text != nil )
    {
        [termsArray insertObject: searchContentField.text atIndex: 0];
        [resultsTable reloadData];
    }   
    [sender endEditing: YES];
	[sender resignFirstResponder];
    
    // [self _performSearchBackwards];
    [NSThread detachNewThreadSelector:@selector(_performSearchBackwards)
                             toTarget:self 
                           withObject:nil];   
}

- (void) doSearchFor:(NSString *)terms
{
    searchContentField.text = terms;
    [self searchBook: searchContentField];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat: @"Search Terms (%d)",[termsArray count]];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = [termsArray count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:
                                 CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] 
                initWithStyle:UITableViewCellStyleDefault 
                reuseIdentifier: CellIdentifier];
        [cell autorelease];
    }
	NSUInteger index = [indexPath indexAtPosition: 1];
	cell.textLabel.text = [termsArray objectAtIndex:index];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUInteger index = [indexPath indexAtPosition: 1];
	NSString *term = [termsArray objectAtIndex: index];
    searchContentField.text = term;
    publicationViewController.searchTerm = 
        searchContentField.text;
    [self searchBook: searchContentField];
}

- (CGFloat) tableView:(UITableView *)tableView 
    heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	return 100;
}
@end
