//
//  Mosaic_eReaderAppDelegate.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/20/10.
//  Copyright  2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "BookshelfViewController.h"

@interface MosaicEReaderAppDelegate : NSObject <UIApplicationDelegate> 
{	
    UIWindow *window;
    UINavigationController *navigationController;
	BookshelfViewController *bookshelfController;	
    
    // Core data
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIWindow *externalWindow;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


// Core data
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

@end

