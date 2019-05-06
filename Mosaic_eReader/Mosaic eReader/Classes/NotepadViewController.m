//
//  NotepadViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotepadViewController.h"
#import "MLDataStore.h"
#import "PublicationViewController.h"
#import "Note.h"

@implementation NotepadViewController

@synthesize currentPage;
@synthesize book;
@synthesize publicationController;
@synthesize noteText;
@synthesize currentNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentNote = nil;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) didReceiveMemoryWarning
{
    NSLog(@"%@ recieved memory warning.",self);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [TestFlight passCheckpoint: @"Opened Note view."];

    // Do any additional setup after loading the view from its nib.
    textView.text = noteText; /*[[MLDataStore sharedInstance] noteForBook: book
                                                       onPage: currentPage];*/
    [textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) saveNote: (id)sender
{
    NSLog(@"Saving note");
    [self dismissModalViewControllerAnimated: YES];
    NSString *string = textView.text;
    Note *note = nil;
    
    if(currentNote != nil)
    {
        [currentNote retain];
        [[MLDataStore sharedInstance] deleteNote:currentNote
                                         forBook:book
                                          onPage:currentNote.page];
        note = currentNote;
        note.content = string;
    }
    else
    {
        note = [[Note alloc] init];
        note.page = currentPage;
        note.content = string;
    }
        
    [[MLDataStore sharedInstance] addNote: note
                                  forBook: book
                                   onPage: currentPage];
    
    [publicationController updatePage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveNoteNotification"
                                                        object:note];
    [note release];
}

- (IBAction) deleteNote: (id)sender
{
    NSLog(@"Delete note");
    [self dismissModalViewControllerAnimated: YES];
    NSString *string = textView.text;
    Note *note = [[Note alloc] init];
    note.page = currentPage;
    note.content = string;
    [[MLDataStore sharedInstance] deleteNote: note
                                     forBook: book
                                      onPage: currentPage];
    [publicationController updatePage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteNoteNotification"
                                                        object:note];
    [note release];
}

-(void)textViewDidEndEditing:(UITextView *)tv 
{
	[tv endEditing: YES];
	[tv resignFirstResponder];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end
