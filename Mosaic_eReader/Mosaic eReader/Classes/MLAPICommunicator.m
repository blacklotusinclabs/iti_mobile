//
//  MLAPICommunicator.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/22/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MLAPICommunicator.h"
#import "MLAuthenticateCommand.h"
#import "MLAuthenticateResult.h"
#import "MLCommandExecutor.h"
#import "MLArrayOfBook.h"
#import "MLGetDownloadedBooksCommand.h"
#import "MLGetUserLibraryCommand.h"
#import "MLGetNotAvailableBooksCommand.h"
#import "MLDownloadBookCommand.h"
#import "MLDownloadResponse.h"
#import "MLDownloadResult.h"
#import "NSMutableData+AES.h"
#import "NSDataAdditions.h"
#import "MLDataStore.h"
#import "MLSearchLibraryCommand.h"
#import "PDFSearcher.h"
#import "MLFile.h"
#import "ImageCache.h"
#import "UIImage+Resize.h"
#import "Functions.h"

#define BUFFER_SIZE 2048

static id _shared = nil;
static NSNotificationCenter *nc = nil;

@implementation MLAPICommunicator

@synthesize session;
@synthesize fetchedResultsController, managedObjectContext;
@synthesize delegate;

+ (id) sharedCommunicator
{
	if (_shared == nil)
	{
		_shared = [[MLAPICommunicator alloc] init];
        nc = [NSNotificationCenter defaultCenter];
	}
	return _shared;
}

+ (NSMutableData *) decryptData:(NSMutableData *)data withKey:(NSString *)codedKey
{
#ifndef TEST
    int retries = 0;
	if(codedKey == nil)
	{
		NSLog(@"Key is nil, assuming data passed in is raw data and returning.");
		return data;
	}

    // codedKey = @"dXNlcm5hbWU6cGFzc3dvcmQ="; // Test failure...
    
    NSData *keyData = nil;
	NSMutableData *newData = nil;
    
    // Retry decryption 5 times...
    while(newData == nil && retries < 5)
    {
        keyData = [NSData base64DataFromString: codedKey];
        newData = [data dataByDecryptingDataWithKey: keyData];
        retries++;
    }
	if(newData == nil)
	{
		NSLog(@"Decryption failed, key = %@,%@",codedKey,keyData);
        [NSException raise: NSInternalInconsistencyException
                    format: @"Download/Decryption Failed key = %@,%@",codedKey,keyData];
		return nil;
	}

	return newData;
#else
	NSString *path = [[NSBundle mainBundle] pathForResource: @"test" ofType: @"pdf"];
	NSMutableData *mutableData = [NSMutableData dataWithContentsOfFile: path];
	return mutableData;
#endif
}

+ (NSMutableData *) encryptData:(NSMutableData *)data withKey:(NSString *)codedKey
{
    int retries = 0;
	if(codedKey == nil)
	{
		NSLog(@"Key is nil, assuming data passed in is raw data and returning.");
		return data;
	}
    
    NSData *keyData = nil;
    NSMutableData *newData = nil;
    
    // Retry decryption 5 times...
    while(newData == nil && retries < 5)
    {
        keyData = [NSData base64DataFromString: codedKey];
        newData = [data dataByEncryptingDataWithKey: keyData];
        retries++;
    }
	if(newData == nil)
	{
		NSLog(@"Encryption failed, key = %@,%@",codedKey,keyData);
        [NSException raise: NSInternalInconsistencyException
                    format: @"Download/Encryption Failed key = %@,%@",codedKey,keyData];
		return nil;
	}
    
	return newData;
}

- (BOOL) authenticateUserWithUsername: (NSString *)uname 
							 password: (NSString *)pass
{	
	self.session = [[MLDataStore sharedInstanceForUserId: uname] retrieveSessionForUsername:uname andPassword:pass];
	NSDate *targetDate = [self.session.accessDate dateByAddingTimeInterval: 7776000];
	if([targetDate compare: [NSDate date]] == NSOrderedAscending)
	{
        self.session = nil;
	}
	
	if(self.session == nil)
	{
		MLAuthenticateCommand *command = [[MLAuthenticateCommand alloc] init];
		command.username = uname;
		command.password = pass;
		self.session = (MLAuthenticateResult *)[[MLCommandExecutor sharedCommandExecutor] 
										  executeCommand: command];
		
		if([self.session isAuthenticatedAsBool])
		{
			[[MLDataStore sharedInstance] addSession: self.session
						forUsername: uname 
						andPassword: pass];
		}
        [command release];
	}
	
	// Check to see if login was successful.
	return [self.session isAuthenticatedAsBool];
}

- (BOOL) authenticateGuestUser
{
	//
	// Fill in the minimum fields for the guest user...
	//
	session = [[MLAuthenticateResult alloc] init];
	session.userId = @"guest"; // @"-1";
	session.userName = @"guest";
	session.firstName = @"Guest";
	session.lastName = @"User";
	[session setIsAuthenticated: @"true"];
	[session setIsBookAdmin: @"false"];
	session.guestUser = YES;
	
	return YES;
}
								  
					

// Get publication names...
- (NSMutableArray *) retrieveDownloadedBooks
{
	NSMutableArray *booksArray = [[MLDataStore sharedInstance] allDownloadedBooks];
    NSMutableArray *sortedArray = [[booksArray sortedArrayUsingFunction:stringSort
                                                        context:nil] mutableCopy];
    [sortedArray autorelease];
	return sortedArray;	
}

- (NSArray *) retrieveListOfAvailableBooks
{
	NSMutableArray *booksArray = [[MLDataStore sharedInstance] allAvailableBooks];
	
	if(booksArray == nil || [booksArray count] == 0)
	{
        NSMutableArray *accessibleBooks = [NSMutableArray arrayWithCapacity: 10];
		MLGetUserLibraryCommand *command = [[MLGetUserLibraryCommand alloc] init];
		command.session = self.session; 
		MLArrayOfBook *books = [command execute];
		booksArray = [books array];     

		for(MLBook *book in booksArray)
		{
            if([[MLDataStore sharedInstance] retrieveBook: book.bookId] == NO)
            {
                [[MLDataStore sharedInstance] addAvailableBook: book];
            }
            [accessibleBooks addObject: book];
        }
        
        /*
        for(MLBook *book in booksArray)
		{
			[[MLDataStore sharedInstance] addNotAvailableBook: book];
		}
        */
        
        [[MLDataStore sharedInstance] setAccessibleBooks: accessibleBooks];
        
        // Remove available books from list.
        for(MLBook *book in [[MLDataStore sharedInstance] allDownloadedBooks])
        {
            [booksArray removeObject: book];
        }
        
        [command release];
        // [books release];
	}
    NSArray *sortedArray = [booksArray sortedArrayUsingFunction:stringSort
                                                        context:nil];
    // [booksArray release];
	return sortedArray;	
}

- (NSArray *) retrieveListOfNotAvailableBooks
{
	NSMutableArray *booksArray = [[MLDataStore sharedInstance] allNotAvailableBooks];
	
	if(booksArray == nil || [booksArray count] == 0)
	{
		MLGetNotAvailableBooksCommand *command = [[MLGetNotAvailableBooksCommand alloc] init];
		command.session = self.session;
		MLArrayOfBook *books = [command execute];
		booksArray = [books array];
        // [booksArray retain];
		for(MLBook *book in booksArray)
		{
			[[MLDataStore sharedInstance] addNotAvailableBook: book];
		}	
        [command release];
		// [books release];
	}
    
    NSArray *sortedArray = [booksArray sortedArrayUsingFunction:stringSort
                                                        context:nil];
    // [booksArray release];
    return sortedArray;	
}

- (UIImage *) retrieveThumbnailArtForPublication: (MLBook *)book
{
#ifndef TEST
	UIImage *image = [[ImageCache sharedCache] imageForName: book.bookId];
    if(image != nil)
    {
        return image;
    }
	
    NS_DURING
    {
        NSData *data = [[MLDataStore sharedInstance] retrieveCoverArtForBookId: book.bookId];
        if(data == nil)
        {
            data = [NSData dataWithContentsOfURL: [NSURL URLWithString: book.thumbnailUrl]];
            [[MLDataStore sharedInstance] addCoverArt: data
                                            forBookId: book.bookId];
        }	
        image = [[UIImage imageWithData: data] imageScaledToSize: CGSizeMake(124, 154)]; // stretchableImageWithLeftCapWidth: 0 topCapHeight: 0];
        [[ImageCache sharedCache] addImage: image withName: book.bookId];
        // [data release];
    }
    NS_HANDLER
    {
        NSLog(@"%@",[localException reason]);
    }
    NS_ENDHANDLER;
    
	return image;	
#else
	return [UIImage imageNamed: @"temp_bookCvr_01.png"];
#endif
}

// Thumbnails...
- (UIImage *) retrieveThumbnailArtForPublicationId: (NSString *)pubname
{
	MLBook *book = [[MLDataStore sharedInstance] retrieveNotAvailableBook: pubname];
	if(book == nil)
	{
		[self retrieveListOfNotAvailableBooks];
		book = [[MLDataStore sharedInstance] retrieveNotAvailableBook: pubname];
	}
	return [self retrieveThumbnailArtForPublication: book];
}

- (NSArray *) retrieveThumbnailsForPublicationIds: (NSArray *)books
{
	NSMutableArray *array = [NSMutableArray array];
	for(NSString *pubname in books)
	{
        UIImage *image = [self retrieveThumbnailArtForPublicationId: pubname];
		[array addObject: image];
	}
	return array;
}

- (NSArray *) retrieveThumbnailsForPublications: (NSArray *)books
{
	NSMutableArray *array = [NSMutableArray array];
	for(MLBook *book in books)
	{
        UIImage *image = [self retrieveThumbnailArtForPublication: book];
		[array addObject: image];
	}
	return array;
}


- (void) dataForBook: (MLDownloadResult *)result
{
}

- (void) _startDownloadPublication: (MLBook *)book
{
    [nc postNotificationName: @"StartDownloadBookNotification"
                      object: book];
}

- (void) _downloadedBookData: (MLBook *)book
{
    [nc postNotificationName: @"DownloadedBookDataNotification" object: book];    
}

- (void) _showAlertPanelForTimeout
{
    UIAlertView *alert = [[[UIAlertView alloc] 
                           initWithTitle: @"" 
                           message: @"There was a timeout while trying to reach the server.  Please check your internet connection." 
                           delegate: nil
                           cancelButtonTitle: @"OK" 
                           otherButtonTitles: nil] 
                          autorelease];
    [alert setTag:12];
    [alert show];    
}

- (void) _showAlertPanelForDecryptionFailure: (NSString *)bookName
{
    UIAlertView *alert = [[[UIAlertView alloc] 
                           initWithTitle: @"" 
                           message: [NSString stringWithFormat: @"Decryption failed for document %@.",bookName]
                           delegate: nil
                           cancelButtonTitle: @"OK" 
                           otherButtonTitles: nil] 
                          autorelease];
    [alert setTag:12];
    [alert show];    
}

- (void) cachePageImages: (NSDictionary *)dict
{
    MLDataStore *dataStore = [MLDataStore sharedInstance];
    NSString *bookId = [dict objectForKey: @"bookid"];
    [dataStore buildPagesCacheForBook: bookId];
}

- (void) indexForSearch: (NSDictionary *)dict
{
    NSData *rawData = [dict objectForKey: @"results"];
    [self performSelectorOnMainThread: @selector(_cachingStarted:)
                           withObject: rawData
                        waitUntilDone: NO];
    
    [NSThread detachNewThreadSelector:@selector(indexPublication:)
                             toTarget:self
                           withObject:dict];
}

// Cache the search information....
- (void) _cachingStarted: (NSData *)rawData
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CachingStartedNotification"
                                                        object: nil];    
}

- (void) _cachingComplete: (NSData *)rawData
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CachingCompleteNotification"
                                                        object: nil];
}

- (void) indexPublication: (NSDictionary *)dict
{
    PDFSearcher *searcher = [[PDFSearcher alloc] init];
    NSData *data = [dict objectForKey: @"results"];
    NSString *bookId = [dict objectForKey: @"bookid"];
    MLBook *publication = [[MLDataStore sharedInstance] retrieveBook: bookId];

    [searcher cachePdfPagesForBook:publication
                          withData:data];
    
    [self performSelectorOnMainThread: @selector(_cachingComplete:)
                           withObject: nil
                        waitUntilDone: NO];
    [searcher release];
}

- (void) _updateProgress: (NSNumber *)perc
{
    [delegate setProgress: [perc doubleValue]];
    if([perc doubleValue] == 1.0)
    {
        [delegate stopTimer];
    }
}

- (void) updateProgress: (double)perc
{
    NSNumber *percNumber = [[NSNumber alloc] initWithFloat: perc];
    [self performSelectorOnMainThread: @selector(_updateProgress:) 
                           withObject: percNumber
                         waitUntilDone:NO];
    [percNumber release];

}

- (void) startTimerWithOptions: (NSArray *)options
{
    double percInc = [[options objectAtIndex: 1] doubleValue];
    NSTimeInterval timeInterval = [[options objectAtIndex: 0] doubleValue];
    [delegate setPercentageIncrease: percInc];
    [delegate setTimeIntervalForDownload: timeInterval];
}

- (void) startTimer
{
    [delegate initializeTimer];
}

// Getting the books...
- (void) retrieveDataForPublication: (MLBook *)book
{
    MLBook *abook = [[MLDataStore sharedInstance] retrieveBook: book.bookId];
    if(abook != nil)
    {
        return;
    }
    
    NS_DURING
    {
        MLDataStore *dataStore = [MLDataStore sharedInstance];
        NSString *key = nil;
        // Notify the world that we've started downloading the book...
        [self performSelectorOnMainThread: @selector(_startDownloadPublication:) withObject: book waitUntilDone: NO];
        NSMutableData *data = [[MLDataStore sharedInstance] retrieveDataForBookId: book.bookId];
        if(data == nil)
        {
            MLDownloadBookCommand *command = [[MLDownloadBookCommand alloc] init];
            NSTimeInterval timeout = 5 * 60; // five minutes...

            command.session = self.session;
            command.bookId = book.bookId;
            
            MLDownloadResponse *response = (MLDownloadResponse *)[command execute];
            MLDownloadResult *result = [response resultForKey: book.bookId];
            
            if([[response errors] count] > 0)
            {
                NSString *message = [[[response errors] objectAtIndex: 0] message];
                if(message != nil)
                {
                    [NSException raise: NSInvalidArgumentException
                                format: @"Error Message From Server: %@",message];
                }
            }
                        
            [command release];
            key = result.key;
            
            book.numPages = [result.pageCount intValue];
            book.type = result.bookFormat;
            [dataStore addKey: key forBookId: book.bookId];
            [dataStore commitToStorage];
            
            if([response isEmpty])
            {
                [NSException raise: NSInternalInconsistencyException 
                            format: @"Empty response while downloading book: %@.",book.title];              
            }
            
            
            if(result != nil)
            {
                if(result.isSplitBool)
                {
                    NSUInteger index = 0;
                    NSArray *array = [[result bookFiles] array];
                    NSUInteger count = [array count];
                    // double percInc = (double) ((double)1.0 / (double)[array count]);
                    // NSTimeInterval timeInterval = 0;
                    for(MLFile *file in array)
                    {
                        double percent = (double)((double)(index + 1)/(double)count);
                        
                        [self updateProgress: percent];
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                        // NSDate *startTime = [NSDate date];
                        NSURLRequest *request = [NSURLRequest 
                                                 requestWithURL:[NSURL URLWithString:file.fileUrl]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                 timeoutInterval:timeout];
                        NSError *error = nil;
                        NSURLResponse *response = nil;
                        NSData *tempData = [NSURLConnection 
                                            sendSynchronousRequest:request
                                            returningResponse: &response 
                                            error: &error];
                        NSString *bookId = result.bookId;
                        [book setPages: [file.pageCount intValue] 
                               forPart: index];
                        [dataStore addBookId: bookId 
                                    withData: tempData 
                                     forPart: index];
                        [dataStore commitToStorage]; 
                        /*
                        if(timeInterval == 0)
                        {
                            NSDate *endTime = [NSDate date];
                            timeInterval = [endTime timeIntervalSince1970] - [startTime timeIntervalSince1970];
                            NSArray  *opts = [NSArray arrayWithObjects: [NSNumber numberWithDouble: timeInterval], [NSNumber numberWithDouble: percInc], nil];
                            [self performSelectorOnMainThread: @selector(startTimerWithOptions:) withObject: opts waitUntilDone: YES];
                        }*/
                        [pool release]; 
                        index++;
                    }
                    [self updateProgress: 1.0];
                    // [delegate setProgress: 1.0];
                    // NSUInteger count = [array count];
                    book.numParts = count;
                }
                else
                {
                    // [self updateProgress: 0.5];                  
                    
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    [self performSelectorOnMainThread: @selector(startTimer) withObject: nil waitUntilDone: YES];
                    NSURLRequest *request = [NSURLRequest 
                                             requestWithURL:[NSURL URLWithString:result.bookUrl]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:timeout];
                    NSError *error = nil;
                    NSURLResponse *response = nil;
                    NSData *tempData = [NSURLConnection 
                                        sendSynchronousRequest:request
                                        returningResponse: &response 
                                        error: &error];
                    NSString *bookId = result.bookId;
                    
                    [[MLDataStore sharedInstance] addBookId: bookId withData: tempData];
                    [dataStore addBookId: bookId withData: tempData];
                    [pool release];
                    [self updateProgress: 1.0];                   
                }                   
            }	
            else
            {
                [self performSelectorOnMainThread:@selector(_showAlertPanelForTimeout:) withObject: book.title waitUntilDone: NO];
                [NSException raise: NSInternalInconsistencyException 
                            format: @"Error timeout while downloading book: @.",book.title];
            }
        }
        
        // add book and key...
        [dataStore removeAvailableBook: book.bookId];
        [dataStore addBook: book]; 
        [dataStore addKey: key forBookId: book.bookId];
        [dataStore commitToStorage];
        
        [self performSelectorOnMainThread: @selector(_downloadedBookData:) withObject: book waitUntilDone: NO];
    }
    NS_HANDLER
    {
        NSLog(@"%@",[localException reason]);
        [localException raise];
    }
    NS_ENDHANDLER;
}

- (NSMutableArray *) searchLibrary: (NSString *)searchTerm
{
	NSMutableArray *booksArray = nil; // [[MLDataStore sharedInstance] allNotAvailableBooks];
	
	if(booksArray == nil || [booksArray count] == 0)
	{
		MLSearchLibraryCommand *command = [[MLSearchLibraryCommand alloc] init];
		command.session = self.session;
        command.searchTerm = searchTerm;
		MLArrayOfBook *books = [command execute];
		booksArray = [books array];
        [command release];
	}
	return booksArray;	    
}

- (void) logout
{
    [[MLDataStore sharedInstance] logout];    
}

- (void) clear
{
    [[MLDataStore sharedInstance] clearStore];
}
@end
