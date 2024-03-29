//
//  Mosaic_eReaderAppDelegate.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/20/10.
//  Copyright  2010. All rights reserved.
//

#import "MosaicEReaderAppDelegate.h"
#import "RootViewController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "IPAddress.h"
#import "ImageCache.h"

@implementation MosaicEReaderAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize externalWindow;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
	// nothing yet.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	externalWindow.hidden = YES;
	
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
	
	// Get MAC Address
	InitAddresses();
	GetIPAddresses();
	GetHWAddresses();
    
    // Start testflight session...
    // [TestFlight takeOff: @"77416e4ade19a02d7828706661a06125_Mjk2NDkyMDExLTEwLTAyIDE2OjQ5OjE0LjU0Mzk2Mg"];  // Start session with token...
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"Recieved memory warning from OS: Free up memory....");
    [TestFlight passCheckpoint: @"Recieved memory warning from OS"];
    [[ImageCache sharedCache] emptyCache];
}

- (void)dealloc {	
	// [navigationController release];
	// [window release];
    // Release core data...
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Data storage...
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc != nil)
    {
        if ([moc hasChanges] && ![moc save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

//Explicitly write Core Data accessors
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"Model.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (void) deleteAllObjects: (NSString *)entityDescription  
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        [[self managedObjectContext] deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
}

- (void)deleteAllObjects:(NSString *)entityDescription
           withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    
    for (NSManagedObject *managedObject in items) {
        [[self managedObjectContext] deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }    
}
@end

