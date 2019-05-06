//
//  AdvancedSearchViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLBook.h"

@class LoadingView;

@interface AdvancedSearchViewController : UIViewController {
    BOOL searchDownloaded;
    BOOL searchAvailable;
    BOOL searchNotAvailable;
    BOOL searchAll;
    
    NSMutableArray *downloadPagesArray;
    NSMutableArray *availablePagesArray;
    NSMutableArray *notAvailablePagesArray;
    NSMutableArray *bookListArray;
    NSMutableArray *notAvailableArray;
    NSMutableArray *availableArray;
    
    IBOutlet UITextField *searchField;
    IBOutlet UITableView *tableView;
    IBOutlet UISwitch *allBooksSwitch;
    IBOutlet UISwitch *availableBooksSwitch;
    IBOutlet UISwitch *notAvailableBooksSwitch;
    MLBook *publication;
    
    LoadingView *loadingView;
}

@property (nonatomic,assign) BOOL searchDownloaded;
@property (nonatomic,assign) BOOL searchAvailable;
@property (nonatomic,assign) BOOL searchNotAvailable;
@property (nonatomic,assign) BOOL searchAll;

- (IBAction) dismiss: (id)sender;
- (IBAction) search: (id)sender;
- (IBAction) update: (id)sender;

@end
