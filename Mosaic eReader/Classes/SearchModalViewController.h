//
//  AdvancedSearchModalViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 3/31/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PublicationViewController.h"

@class LoadingView,MLDataStore;

@interface SearchModalViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
	IBOutlet UITableView *resultsTable;
	IBOutlet UITextField *searchContentField;
    
	PublicationViewController *publicationController;
    
    NSMutableArray *termsArray;
    LoadingView *loadingView;
}

// @property (nonatomic,assign) CGPDFDocumentRef document;
@property (nonatomic,assign) PublicationViewController *publicationViewController;

- (IBAction) searchBook: (id)sender;
- (IBAction) next:(id)sender;
- (IBAction) previous:(id)sender;

- (void) doSearchFor: (NSString *)terms;
@end
