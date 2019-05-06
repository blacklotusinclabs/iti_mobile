//
//  NoteListViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PublicationViewController, Note, MLDataStore;

@interface NoteListViewController : UIViewController {
    IBOutlet UITableView *tableView;
	PublicationViewController *publicationController;  
    NSUInteger currentPage;
    Note *currentNote;
    MLDataStore *dataStore;
}

@property (nonatomic,assign) PublicationViewController *publicationController;
@property (nonatomic,assign) NSUInteger currentPage;

- (IBAction) addNote:(id)sender;
- (IBAction) deleteNote:(id)sender;

- (void) refresh;

@end
