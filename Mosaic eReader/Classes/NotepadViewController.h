//
//  NotepadViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"

@class PublicationViewController, Note;

@interface NotepadViewController : UIViewController <UITextViewDelegate> {
    NSUInteger currentPage;
    MLBook *book;
    IBOutlet UITextView *textView;
    PublicationViewController *publicationController;
    NSString *noteText;
    Note *currentNote;
}

@property (nonatomic,assign) NSUInteger currentPage;
@property (nonatomic,assign) MLBook *book;
@property (nonatomic,assign) PublicationViewController *publicationController;
@property (nonatomic,retain) NSString *noteText;
@property (nonatomic,assign) Note *currentNote;

- (IBAction) saveNote: (id)sender;
- (IBAction) deleteNote: (id)sender;

@end
