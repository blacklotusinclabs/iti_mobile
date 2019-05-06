//
//  MLBookmarkPopoverController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PublicationViewController,MLDataStore;

@interface MLBookmarkPopoverController : UIViewController <UITableViewDelegate> {
	PublicationViewController *publicationController;
	MLDataStore *dataStore;
	IBOutlet UITableView *tableView;
	CGPDFDocumentRef pdf;	
}

@property (nonatomic, assign) CGPDFDocumentRef pdf;	
@property (nonatomic, assign) PublicationViewController *publicationController;

- (IBAction) addBookmark: (id)sender;
- (IBAction) deleteBookmark: (id)sender;

@end
