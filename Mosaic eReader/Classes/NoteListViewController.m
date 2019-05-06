//
//  NoteListViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteListViewController.h"
#import "NoteListCell.h"
#import "MLDataStore.h"
#import "PublicationViewController.h"
#import "NotepadViewController.h"
#import "Note.h"
#import "PDFPageCell.h"
#import "MLDataStore.h"

#define SAMPLE_LEN 20

NSInteger sortNotes(id val1, id val2, void *context)
{
    Note *note1 = (Note *)val1;
    Note *note2 = (Note *)val2;
    NSComparisonResult result = NSOrderedSame;
    if(note1.page < note2.page)
    {
        result = NSOrderedAscending;
    }
    else
    {
        result = NSOrderedDescending;
    }
    return result;
}

@implementation NoteListViewController

@synthesize publicationController;
@synthesize currentPage;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:) 
                                                 name:@"SaveNoteNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:) 
                                                 name:@"DeleteNoteNotification"
                                               object:nil];
    dataStore = [MLDataStore sharedInstance];
}

- (void) handleNotification: (NSNotification *)notification
{
    NSString *name = [notification name];
    id object = [notification object];
    if([name isEqualToString:@"SaveNoteNotification"])
    {
        currentNote = object;
        [tableView reloadData];
    }
    else if([name isEqualToString:@"DeleteNoteNotification"])
    {
        // currentNote = nil;
        [self deleteNote: nil];
        currentNote = nil;
        [tableView reloadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (PDFPageCell *) _dequeueCustomCell: (UITableView *)tv
{
    static NSString *CellIdentifier = @"PDFPageCell";

	PDFPageCell *cell = (PDFPageCell *) 
        [tv dequeueReusableCellWithIdentifier: CellIdentifier];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *array = [[MLDataStore sharedInstance] notesForBook:publicationController.publication];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	PDFPageCell *cell = [self _dequeueCustomCell:tv];
	NSArray *array = [[MLDataStore sharedInstance] notesForBook:publicationController.publication];
    NSUInteger index = [indexPath indexAtPosition: 1];
    NSArray *sortedArray = [array sortedArrayUsingFunction:sortNotes context:nil];
    Note *note = [sortedArray objectAtIndex:index];
    NSString *noteText = note.content;
    NSString *noteSample = [(([noteText length] >= SAMPLE_LEN) ? [noteText substringToIndex:SAMPLE_LEN] : noteText) stringByAppendingString: @"..."];

    cell.messageLabel.text = noteSample;
    cell.nameLabel.text = [NSString stringWithFormat: @"Page #%d",note.page];    
    cell.pdfView.image = [MLDataStore imageFromPDFData: [dataStore imageForBookId: publicationController.publication.bookId onPage: note.page] pageNum: 1]; 

    // [sortedArray autorelease];

	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	return 110;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition: 1];
	NSArray *array = [[MLDataStore sharedInstance] notesForBook:publicationController.publication];
    
    NotepadViewController *notepadController = [[NotepadViewController alloc] init];
    notepadController.book = publicationController.publication;
    notepadController.publicationController = publicationController;
    [notepadController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal]; 
    
    Note *note = [array objectAtIndex:index];
    currentPage = note.page;
    notepadController.currentPage = note.page;
    notepadController.noteText = note.content;
    notepadController.currentNote = note;
    [publicationController goToPageNumber: note.page];
    [self presentModalViewController: notepadController
                            animated: YES];
    
    [notepadController release];
    [tableView reloadData];
}


- (IBAction) addNote:(id)sender
{
    // Dismiss the modal view controller
    [self dismissModalViewControllerAnimated: YES];
    
    // open the notepad...
    NotepadViewController *notepadController = [[NotepadViewController alloc] init];
    notepadController.currentPage = currentPage;
    notepadController.book = publicationController.publication;
    notepadController.publicationController = publicationController;
    notepadController.currentNote = nil;
    [notepadController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal]; 
    
    [self presentModalViewController: notepadController
                            animated: YES];
    [notepadController release];     
    [tableView reloadData];
}

- (IBAction) deleteNote: (id)sender
{
    [[MLDataStore sharedInstance] deleteNote: currentNote 
                                     forBook: publicationController.publication
                                      onPage: currentNote.page];
    [tableView reloadData];
}


- (void) refresh
{
    [tableView reloadData];
}
@end
