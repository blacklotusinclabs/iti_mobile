//
//  RootViewController.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/20/10.
//  Copyright  2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class LoadingView;

@interface RootViewController : UIViewController <NSFetchedResultsControllerDelegate>
{
	IBOutlet UITextField *username;
	IBOutlet UITextField *password;
    IBOutlet UISwitch *rememberMe;
	
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;	
    
    NSString *uname;
    NSString *pass;
    
    LoadingView *loadingView;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (IBAction) login: (id)sender;
// - (IBAction) guestLogin: (id)sender;
- (IBAction) rememberMe: (id)sender;

@end
