//
//  TableOfContentsViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableOfContentsViewController.h"
#import "Outline.h"
#import "PDFPageCell.h"
#import "MLDataStore.h"

static NSString *CellIdentifier = @"PDFPageCell";

@implementation TableOfContentsViewController

@synthesize document, publicationViewController;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

- (void) refresh
{
    Outline *outline = [[Outline alloc] init];
    rootItem =  [outline buildOutlineFromDocument: document];
    NSLog(@"%@",rootItem);
    [outline release];
}

#pragma mark - Delegate methods....

- (PDFPageCell *) _dequeueCustomCell: (UITableView *)tv
{
	PDFPageCell *cell = (PDFPageCell *) [tv dequeueReusableCellWithIdentifier: CellIdentifier];
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
	return [NSString stringWithFormat: @"Table of Contents(%d)",[[rootItem subItems] count]];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = [[rootItem subItems] count];
	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    MLDataStore *dataStore = [MLDataStore sharedInstance];
	PDFPageCell *pageCell = [self _dequeueCustomCell:tv];
	NSUInteger index = [indexPath indexAtPosition: 1];
    OutlineItem *item = [[rootItem subItems] objectAtIndex: index];    
	pageCell.nameLabel.text = [NSString stringWithFormat: @"Page# %d",[item page]];
    pageCell.messageLabel.text = [item name]; // nothing to display for bookmarks....  this is used in other areas to show occurrences.
    pageCell.pdfView.image = [MLDataStore imageFromPDFData: [dataStore imageForBookId: publicationController.publication.bookId onPage: [item page]] pageNum: 1];   
    
	return pageCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUInteger index = [indexPath indexAtPosition: 1];
	NSNumber *pageNum = [[rootItem subItems] objectAtIndex: index];
	[publicationViewController goToSelectedToc: [pageNum intValue]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	return 100;
}

@end
