//
//  MLDataStore.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 1/9/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLBook, MLAuthenticateResult, Note;

@interface MLDataStore : NSObject
{
	NSString *storageFile;
    NSString *currentUsername;
    NSMutableArray *cachedBooks;
	NSMutableDictionary *dataStorage;
	NSMutableDictionary *covers;
	NSMutableDictionary *keys;
	NSMutableDictionary *userBooks;
	NSMutableDictionary *availableBooks;
	NSMutableDictionary *notAvailableBooks;
    NSMutableArray *accessibleBooks;
	NSMutableDictionary *allSessions;
	NSMutableDictionary *bookmarks;
    NSMutableDictionary *notes;
    NSMutableDictionary *paths;
    NSMutableDictionary *data;
    NSMutableDictionary *cachedSearch;
    NSMutableDictionary *pagesAndParts;
    NSMutableDictionary *lastPageDict;
    
    NSLock *lock;
}

@property (nonatomic, retain) NSString *currentUsername;
// @property (nonatomic, retain) NSMutableArray *accessibleBooks;

+ (MLDataStore *) sharedInstance;
// + (MLDataStore *) sharedInstanceForGuestUser;
+ (MLDataStore *) sharedInstanceForUserId: (NSString *)userId;
+ (UIImage *) imageFromPDF: (CGPDFDocumentRef)pdf
                   pageNum: (NSUInteger) pageNum;
+ (UIImage *) imageFromPDF: (CGPDFDocumentRef)pdf;
+ (UIImage *) imageFromPDFData: (NSData *)data
                       pageNum: (NSUInteger)pageNum;

- (id) initWithUserId: (NSString *)userId;
// - (id) initForGuestUser;
- (void) commitToStorage;

- (NSString *)applicationDocumentsDirectory;

// Cover art...
- (void) addCoverArt: (NSData *)image
		   forBookId: (NSString *)bookId;
- (NSData *) retrieveCoverArtForBookId: (NSString *)bookId;

// Decryption key...
- (void) addKey: (NSString *)key
	  forBookId: (NSString *)bookId;
- (NSString *) retrieveKey: (NSString *)bookId;

// Storing and retrieving subscribed books...
- (void) addBook: (MLBook *)book;
- (MLBook *) retrieveBook: (NSString *)bookId;
- (void) removeBook: (NSString *)bookId;

// Adding and retrieving data...
- (void) addBookId: (NSString *)bookId
          withData: (NSData *)data;
- (NSMutableData *) retrieveDataForBookId: (NSString *)bookId;
- (void) addBookId: (NSString *)bookId
          withData: (NSData *)data
           forPart: (NSUInteger)part;
- (NSMutableData *) retrieveDataForBookId: (NSString *)bookId
                                     part: (NSUInteger)part;
- (void) removeDataForBookId: (NSString *)bookId;

// Unsubscribed book...
- (void) addAvailableBook: (MLBook *)book;
- (MLBook *) retrieveAvailableBook:(NSString *)bookId;
- (void) removeAvailableBook: (NSString *)bookId;

// Books in the larger library..
- (void) addNotAvailableBook: (MLBook *)book;
- (MLBook *) retrieveNotAvailableBook:(NSString *)bookId;

// Session storage...
- (void) addSession: (MLAuthenticateResult *)session
		forUsername: (NSString *)userName
		andPassword: (NSString *)password;
- (MLAuthenticateResult *) retrieveSessionForUsername: (NSString *)name
										  andPassword: (NSString *)password;

// Bookmarks...
- (void) addBookmarkInBook: (MLBook *)book
				   forPage: (NSUInteger)page;

- (void) deleteBookmarkInBook: (MLBook *)book
				   forPage: (NSUInteger)page;

- (NSArray *)allBookmarksForBook: (MLBook *)book;

- (BOOL) isPageNumberBookmarked: (NSUInteger)page
						 inBook: (MLBook *)book;

// Notes
- (void) addNote: (Note *)note
         forBook: (MLBook *)book
          onPage: (NSUInteger)page;

- (void) deleteNote: (Note *)note
            forBook: (MLBook *)book
             onPage: (NSUInteger)page;

- (NSMutableArray *) notesForBook: (MLBook *)book
                     onPage: (NSUInteger)page;

- (BOOL) isNoteOnPage: (NSUInteger)page
               inBook: (MLBook *)book;

- (NSArray *) notesForBook: (MLBook *)book;

// Paths
- (void) addPaths: (NSMutableArray *)array
          forPage: (NSUInteger)page
           inBook: (MLBook *)book;

- (void) deletePathsForBook: (MLBook *)book
                     onPage: (NSUInteger)page;

- (NSMutableArray *)pathsForBook: (MLBook *)book
                          onPage: (NSUInteger)page;

// Book meta data...
- (NSMutableString *) getDataForBook: (MLBook *)book
                              onPage: (NSUInteger) page;

- (void) addData: (NSMutableString *)data
         forBook: (MLBook *)book
          onPage: (NSUInteger)page;

// Cached search...
- (NSMutableArray *) cachedSearch: (NSString *)criteria
                          forBook: (MLBook *)book;

- (void) addCachedSearch: (NSString *)criteria
                 forBook: (MLBook *)book
                 results: (NSMutableArray *)array;

// Get all subscribed books.
- (NSMutableArray *) allDownloadedBooks;
- (NSMutableArray *) allAvailableBooks;
- (NSMutableArray *) allNotAvailableBooks;
- (void) setAccessibleBooks: (NSMutableArray *)books;
- (NSMutableArray *) accessibleBooks;
- (void) clearStore;
- (void) clearStoreExceptUserBooks;

// Manage page image data.
- (void) saveImage: (UIImage *)image
           forBook: (NSString *)bookId
            onPage: (NSUInteger)pageNum;
- (NSData *) imageForBookId: (NSString *)bookId
                     onPage: (NSUInteger)pageNum;
- (void) buildPagesCacheForBook: (NSString *)bookId;

- (NSString *)fileNameForBookId: (NSString *)bookId;
- (NSString *)fileNameForBookId: (NSString *)bookId
                           part: (NSUInteger)part;
// Caching
- (BOOL) isBookDoneCaching: (NSString *)bookId;
- (void) bookIsDoneCaching: (NSString *)bookId; 
- (NSString *)fileNameForPage: (NSUInteger)pageNum withBookId: (NSString *)bookId;
- (BOOL) dataExistsForPage: (NSUInteger)pageNum withBookId: (NSString *)bookId;
- (void) setPages: (NSUInteger)pages forPart: (NSUInteger)part ofBook: (NSString *)bookId;
- (NSUInteger) pagesForPart: (NSUInteger)part ofBook: (NSString *)bookId;
- (NSUInteger) lastPageCachedForBookId: (NSString *)bookId;
- (void) setLastPage: (NSUInteger)page
           forBookId: (NSString *)bookId;


// Zipping and unzipping...
- (void) unzipFileForBookId: (NSString *)bookId;
- (void) deleteFilesForBookId: (NSString *)bookId;
- (NSString *) indexFileForBookId: (NSString *)bookId;

// logout...
- (void) logout;
@end
