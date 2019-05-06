//
//  MLBookmarkPopoverController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import "MLBookmarkPopoverController.h"
#import "PDFPageCell.h"
#import "PublicationViewController.h"
#import "MLDataStore.h"

static NSString *CellIdentifier = @"PDFPageCell";

NSInteger sortBookmarks(id val1, id val2, void *context)
{
    NSNumber *num1 = (NSNumber *)val1;
    NSNumber *num2 = (NSNumber *)val2;
    NSComparisonResult result = NSOrderedSame;
    if([num1 intValue] < [num2 intValue])
    {
        result = NSOrderedAscending;
    }
    else
    {
        result = NSOrderedDescending;
    }
    return result;
}

@implementation MLBookmarkPopoverController

@synthesize publicationController;
@synthesize pdf;

- (void) viewDidLoad
{
	[super viewDidLoad];
	dataStore = [MLDataStore sharedInstance];
	[tableView reloadData];
}

- (IBAction) addBookmark: (id)sender
{
	[publicationController addBookmarkForCurrentPage];
	[tableView reloadData];	
}

- (IBAction) deleteBookmark: (id)sender
{
	[publicationController deleteBookmarkForCurrentPage];
	[tableView reloadData];
}

- (PDFPageCell *) _dequeueCustomCell: (UITableView *)tv
{
	PDFPageCell *cell = (PDFPageCell *) [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	if(cell == nil) 
	{
		NSArray *topLevelObjects = nil;
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"PDFPageCell"
														owner: nil 
													  options: nil];
		
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass: [UITableViewCell class]])
			{
				cell = (PDFPageCell *) currentObject;
				break;
			}
		}
	}
	return cell;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat: @"Bookmarks (%d)",
            [[dataStore allBookmarksForBook: publicationController.publication] count]];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = [[dataStore allBookmarksForBook: publicationController.publication] count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	PDFPageCell *pageCell = [self _dequeueCustomCell:tv];
	NSArray *array = [dataStore allBookmarksForBook: publicationController.publication];
	NSUInteger index = [indexPath indexAtPosition: 1];
    NSArray *sortedArray = [array sortedArrayUsingFunction:sortBookmarks context: nil];
    NSUInteger pageNum = [[sortedArray objectAtIndex:index] intValue];
    
	pageCell.nameLabel.text = [NSString stringWithFormat: @"Page# %d",pageNum];
    pageCell.messageLabel.text = @""; // nothing to display for bookmarks....  this is used in other areas to show occurrences.
    pageCell.pdfView.image = [MLDataStore imageFromPDFData: [dataStore imageForBookId: publicationController.publication.bookId onPage: pageNum] pageNum: 1];  
    
    // [sortedArray autorelease];
    
	return pageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSArray *array = [dataStore allBookmarksForBook: publicationController.publication];
	NSUInteger index = [indexPath indexAtPosition: 1];
	NSNumber *pageNum = [array objectAtIndex: index];
	[publicationController goToPageForBookmark: [pageNum intValue]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	return 100;
}

@end
