//
//  TableOfContentsViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicationViewController.h"
#import "Outline.h"

@interface TableOfContentsViewController : UIViewController {
    IBOutlet UITableView *resultsTable;

    PublicationViewController *publicationController;
    CGPDFDocumentRef document;
    OutlineItem *rootItem;
}

@property (nonatomic,assign) CGPDFDocumentRef document;
@property (nonatomic,assign) PublicationViewController *publicationViewController;

- (void) refresh;

@end
