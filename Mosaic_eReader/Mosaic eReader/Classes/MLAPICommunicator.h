//
//  MLAPICommunicator.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/22/10.
//  Copyright 2010 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MLAuthenticateResult.h"
#import "MLBook.h"

@class MLDataStore;

@protocol MLAPIComminicatorDelegate <NSObject>

- (void) setTimeIntervalForDownload: (NSTimeInterval)value;
- (void) setPercentageIncrease: (double)perc;
- (void) initializeTimer;
- (void) stopTimer;
- (void) setProgress: (double)perc;

@end

/**
 * This class will communicate with the API.   It will
 * keep track of which user is currently logged in and only
 * get the information based on that user.
 */
@interface MLAPICommunicator : NSObject 
{
	MLAuthenticateResult *session;	
	// MLDataStore *dataStorage;
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    id<MLAPIComminicatorDelegate> delegate;
}

@property (nonatomic,retain) MLAuthenticateResult *session;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id<MLAPIComminicatorDelegate> delegate;

+ (id) sharedCommunicator;

- (BOOL) authenticateUserWithUsername: (NSString *)uname 
							 password: (NSString *)pass;

- (BOOL) authenticateGuestUser;

// decryption
+ (NSMutableData *) decryptData: (NSMutableData *)data withKey: (NSString *)key;
+ (NSMutableData *) encryptData:(NSMutableData *)data withKey:(NSString *)codedKey;

// Get publication names...
- (NSMutableArray *) retrieveDownloadedBooks;

- (NSArray *) retrieveListOfAvailableBooks;

- (NSArray *) retrieveListOfNotAvailableBooks;

- (NSMutableArray *) searchLibrary: (NSString *)searchTerm;

// Thumbnails...
- (UIImage *) retrieveThumbnailArtForPublication: (MLBook *)book;

- (NSArray *) retrieveThumbnailsForPublications: (NSArray *)array;

- (UIImage *) retrieveThumbnailArtForPublicationId: (NSString *)pubname;

- (NSArray *) retrieveThumbnailsForPublicationIds: (NSArray *)array;

// Getting the books...
- (void) retrieveDataForPublication: (MLBook *)book;

- (void) logout;

- (void) clear;
@end
