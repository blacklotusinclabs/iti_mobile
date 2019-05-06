//
//  MLDataStore.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 1/9/11.
//  Copyright 2011 . All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGDataProvider.h> 
#import <CoreGraphics/CGGeometry.h> 
#import <CoreGraphics/CGPDFPage.h> 

#import "MLDataStore.h"
#import "MLBook.h"
#import "NSString+SHA1.h"
#import "MLAuthenticateResult.h"
#import "PDFPageView.h"
#import "UIImage+Resize.h"
#import "Note.h"
#import "MLAPICommunicator.h"
#import "NSMutableData+AES.h"
#import "SSZipArchive.h"
#import "Book.h"
#import "MosaicEReaderAppDelegate.h"

#define USERNAME_KEY @"CurrentUsername"
#define BOOKS_KEY @"Books"
#define COVERS_KEY @"Covers"
#define KEYS_KEY @"Keys"
#define AVAILABLEBOOKS_KEY @"AvailableBooks"
#define NOTAVAILABLEBOOKS_KEY @"AllAvailableBooks"
#define SESSIONS_KEY @"Sessions"
#define BOOKMARKS_KEY @"Bookmarks"
#define NOTES_KEY @"Notes"
#define PATHS_KEY @"Paths"
#define DATA_KEY @"Data"
#define CACHEDSEARCH_KEY @"CachedSearch"
#define TEMPDATA_KEY @"TempData"
#define CACHEDBOOKS_KEY @"CachedBooks"
#define PAGES_KEY @"PagesAndParts"
#define LAST_PAGE_KEY @"LastPageForBook"
#define ACCESSIBLEBOOKS_KEY @"AccessibleBooks"
#define VERSION_KEY @"Version"

#define USER_BOOKS_ID [NSNumber numberWithInt:0]
#define AVAILABLE_BOOKS_ID [NSNumber numberWithInt:1]
#define NOT_AVAILABLE_BOOKS_ID [NSNumber numberWithInt:2]

#define CURRENT_DATASTORE_VERSION 1

#define INITIAL_PAGES 5

#define DATASTORE_FILE @"datastore.dat"

static MLDataStore *_datastore_instance = nil;

@implementation MLDataStore

@synthesize currentUsername;

+ (MLDataStore *) sharedInstance
{
    return _datastore_instance;
}

+ (MLDataStore *) sharedInstanceForUserId: (NSString *)userId
{
	if(_datastore_instance == nil)
	{
		_datastore_instance = [[MLDataStore alloc] initWithUserId: userId];
	}
	return _datastore_instance;
}

/*
+ (MLDataStore *)sharedInstanceForGuestUser
{
	[_datastore_instance release];
	_datastore_instance = [[MLDataStore alloc] initForGuestUser];
	return _datastore_instance;
}
*/

+ (UIImage *) imageFromPDF: (CGPDFDocumentRef)pdf
                   pageNum: (NSUInteger) pageNum
{
	CGRect rect = CGRectMake(0, 0, 1024, 768);
    UIGraphicsBeginImageContext(rect.size); 
	CGContextRef context = UIGraphicsGetCurrentContext();

	[[UIColor whiteColor] set];
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);		
	CGContextFillRect(context, CGContextGetClipBoundingBox(context));		
	CGContextFillRect(context, rect);
	CGContextTranslateCTM(context, 0.0, 768);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, pageNum);
	CGContextSaveGState(context);
	CGRect mrect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    // get the rectangle of the cropped inside
    CGContextScaleCTM(context, rect.size.width / mrect.size.width,
                      rect.size.height / mrect.size.height);
    CGContextTranslateCTM(context, -mrect.origin.x, -mrect.origin.y);
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, mrect, 0, true);
	CGContextConcatCTM(context, pdfTransform);
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        
	UIGraphicsEndImageContext();
    return resultingImage;	
}

+ (UIImage *) imageFromPDF: (CGPDFDocumentRef)pdf
{
    return [MLDataStore imageFromPDF:pdf pageNum:1];
}

+ (UIImage *) imageFromPDFData: (NSData *)data
                       pageNum: (NSUInteger)pageNum
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);	
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
    UIImage *image = [MLDataStore imageFromPDF: document
                                       pageNum: pageNum];
    CGDataProviderRelease(dataProvider);
    CGPDFDocumentRelease(document);
    return image;
}

+ (NSMutableData *) pdfFromPDF: (CGPDFDocumentRef)pdf
                       pageNum: (NSUInteger)pageNum
{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
	CGRect rect = CGRectMake(0, 0, 768, 1024);
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, rect, nil);
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsBeginPDFPage();
        
	CGContextTranslateCTM(context,0.0,1024);
	CGContextScaleCTM(context,1.0,-1.0);
	
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, pageNum);
	
	CGContextSaveGState(context);
	CGRect mrect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    // get the rectangle of the cropped inside
    CGContextScaleCTM(context, rect.size.width / mrect.size.width,
                      rect.size.height / mrect.size.height);
    CGContextTranslateCTM(context, -mrect.origin.x, -mrect.origin.y);
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, mrect, 0, true);
	CGContextConcatCTM(context, pdfTransform);
	CGContextDrawPDFPage(context, page);
	CGContextRestoreGState(context);
        
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

- (void) updateToCurrentVersionFromVersion: (NSUInteger)version
{
    NSLog(@"Nothing to be done here since this is the initial version.");
}

- (void) clearStore
{
	dataStorage = [[NSMutableDictionary alloc] initWithCapacity: 10];

	// Database ...
    userBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
	availableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
	accessibleBooks = [[NSMutableArray alloc] initWithCapacity: 10];
	notAvailableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];

    // Data store...
    covers = [[NSMutableDictionary alloc] initWithCapacity: 10];
	keys = [[NSMutableDictionary alloc] initWithCapacity: 10];
    allSessions = [[NSMutableDictionary alloc] initWithCapacity: 10];
	bookmarks = [[NSMutableDictionary alloc] initWithCapacity: 10];
    notes = [[NSMutableDictionary alloc] initWithCapacity: 10];
    paths = [[NSMutableDictionary alloc] initWithCapacity: 10];
    data = [[NSMutableDictionary alloc] initWithCapacity: 10];
    cachedSearch = [[NSMutableDictionary alloc] initWithCapacity: 10];
    cachedBooks = [[NSMutableArray alloc] initWithCapacity: 10];
    pagesAndParts = [[NSMutableDictionary alloc] initWithCapacity: 10];
    lastPageDict = [[NSMutableDictionary alloc] initWithCapacity: 10];
	
    /*
	[dataStorage setObject: userBooks
					forKey: BOOKS_KEY];
	[dataStorage setObject: availableBooks 
					forKey: AVAILABLEBOOKS_KEY];			
	[dataStorage setObject: notAvailableBooks 
					forKey: NOTAVAILABLEBOOKS_KEY];			
     */
    
	[dataStorage setObject: accessibleBooks 
					forKey: ACCESSIBLEBOOKS_KEY];			    
    [dataStorage setObject: covers 
					forKey: COVERS_KEY];
	[dataStorage setObject: keys 
					forKey: KEYS_KEY];			
	[dataStorage setObject: allSessions
					forKey: SESSIONS_KEY];		
	[dataStorage setObject: bookmarks
					forKey: BOOKMARKS_KEY];
	[dataStorage setObject: notes
					forKey: NOTES_KEY];
	[dataStorage setObject: paths
					forKey: PATHS_KEY];
    [dataStorage setObject: data
					forKey: DATA_KEY];
    [dataStorage setObject: cachedSearch
					forKey: CACHEDSEARCH_KEY];
    [dataStorage setObject: @""
                    forKey: USERNAME_KEY];
    [dataStorage setObject: cachedBooks
                    forKey: CACHEDBOOKS_KEY];
    [dataStorage setObject: pagesAndParts
                    forKey: PAGES_KEY];
    [dataStorage setObject: lastPageDict
                    forKey: LAST_PAGE_KEY];
    [dataStorage setObject: [NSNumber numberWithInt:CURRENT_DATASTORE_VERSION]
                    forKey: VERSION_KEY];
    
    [userBooks release];
    [availableBooks release];
    [notAvailableBooks release];

    [covers release];
    [keys release];
    [allSessions release];
    [accessibleBooks release];
    [bookmarks release];
    [notes release];
    [paths release];
    [data release];
    [cachedSearch release];
    [cachedBooks release];
    [pagesAndParts release];
    [lastPageDict release];
    
    
    userBooks = nil;
    availableBooks = nil;
    notAvailableBooks = nil;
}

- (void) clearStoreExceptUserBooks
{
	covers = [[NSMutableDictionary alloc] initWithCapacity: 10];
    /*
	availableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
	notAvailableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
    */
    
	accessibleBooks = [[NSMutableArray alloc] initWithCapacity: 10];
	[dataStorage setObject: covers 
					forKey: COVERS_KEY];
	[dataStorage setObject: availableBooks 
					forKey: AVAILABLEBOOKS_KEY];			
	[dataStorage setObject: notAvailableBooks 
					forKey: NOTAVAILABLEBOOKS_KEY];		
    [dataStorage setObject: accessibleBooks 
					forKey: ACCESSIBLEBOOKS_KEY];
	
    for(NSString *bookId in [userBooks allKeys])
    {
        [availableBooks removeObjectForKey: bookId];
    }
    
    [covers release];
    [availableBooks release];
    [notAvailableBooks release];
    [accessibleBooks release];
}
- (id) initWithUserId:(NSString *)userId
{
	if((self = [super init]) != nil)
	{
        lock = [[NSLock alloc] init];
        self.currentUsername = userId;
        NSString *fileName = [[userId stringByAppendingString: @"_"] stringByAppendingString: DATASTORE_FILE];
		storageFile = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent: fileName] retain];
		dataStorage = [[NSKeyedUnarchiver unarchiveObjectWithFile: 
                        storageFile] retain];
		if(dataStorage == nil)
		{
			[self clearStore];
		}
		else
		{
            userBooks = nil;
            availableBooks = nil;
            notAvailableBooks = nil;
            
            /*
			userBooks = [[dataStorage objectForKey: BOOKS_KEY] retain];
			availableBooks = [[dataStorage objectForKey: AVAILABLEBOOKS_KEY] 
                              retain];
			notAvailableBooks = [[dataStorage objectForKey: NOTAVAILABLEBOOKS_KEY] 
                                 retain];
			*/
            
			accessibleBooks = [[dataStorage objectForKey: ACCESSIBLEBOOKS_KEY] retain];
            covers = [[dataStorage objectForKey: COVERS_KEY] retain];
			keys = [[dataStorage objectForKey: KEYS_KEY] retain];
			allSessions = [[dataStorage objectForKey: SESSIONS_KEY] retain];
			bookmarks = [[dataStorage objectForKey: BOOKMARKS_KEY] retain];
            notes = [[dataStorage objectForKey: NOTES_KEY] retain];
            paths = [[dataStorage objectForKey: PATHS_KEY] retain];
            data = [[dataStorage objectForKey: DATA_KEY] retain];
            cachedSearch = [[dataStorage objectForKey: CACHEDSEARCH_KEY] retain];
            cachedBooks = [[dataStorage objectForKey: CACHEDBOOKS_KEY] retain];
            pagesAndParts = [[dataStorage objectForKey: PAGES_KEY] retain];
            lastPageDict = [[dataStorage objectForKey: LAST_PAGE_KEY] retain];
            
            NSNumber *version = [dataStorage objectForKey: VERSION_KEY];
            if([version intValue] != CURRENT_DATASTORE_VERSION)
            {
                NSLog(@"Version discrepency");
                [self updateToCurrentVersionFromVersion:[version intValue]];
            }
            
            /*
            if(!userBooks)
            {
                userBooks = [[NSMutableDictionary alloc] initWithCapacity: 10]; 
                [dataStorage setObject: userBooks
                                forKey: BOOKS_KEY];  
                [userBooks release];
            }
            if(!availableBooks)
            {
                availableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: availableBooks 
                                forKey: AVAILABLEBOOKS_KEY];
                [availableBooks release];
            }
            if(!notAvailableBooks)
            {
                notAvailableBooks = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: notAvailableBooks 
                                forKey: NOTAVAILABLEBOOKS_KEY];		
                [notAvailableBooks release];
            }
            */
            
            if(!covers)
            {
                covers = [[NSMutableDictionary alloc] initWithCapacity: 10]; 
                [dataStorage setObject: covers 
                                forKey: COVERS_KEY];
                [covers release];
            }
            if(!keys)
            {
                keys = [[NSMutableDictionary alloc] initWithCapacity: 10]; 
                [dataStorage setObject: keys 
                                forKey: KEYS_KEY];	
                [keys release];
            }
            
            if(!allSessions)
            {
                allSessions = [[NSMutableDictionary alloc] initWithCapacity: 10];  
                [dataStorage setObject: allSessions
                                forKey: SESSIONS_KEY];	    
                [allSessions release];
            }
            if(!bookmarks)
            {
                bookmarks = [[NSMutableDictionary alloc] initWithCapacity: 10];                
                [dataStorage setObject: bookmarks
                                forKey: BOOKMARKS_KEY];  
                [bookmarks release];
            }
            if(!notes)
            {
                notes = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: notes
                                forKey: NOTES_KEY]; 
                [notes release];
            }
            if(!paths)
            {
                paths = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: paths
                                forKey: PATHS_KEY];      
                [paths release];
            }
            if(!data)
            {
                data = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: data
                                forKey: DATA_KEY];     
                [data release];
            }
            if(!cachedSearch)
            {
                cachedSearch = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: cachedSearch
                                forKey: CACHEDSEARCH_KEY]; 
                [cachedSearch release];
            } 
            if(!cachedBooks)
            {
                cachedBooks = [[NSMutableArray alloc] initWithCapacity: 10];
                [dataStorage setObject: cachedBooks
                                forKey: CACHEDBOOKS_KEY];
                [cachedBooks release];
            }
            if(!pagesAndParts)
            {
                pagesAndParts = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: pagesAndParts
                                forKey: PAGES_KEY];
                [pagesAndParts release];
            }
            if(!lastPageDict)
            {
                lastPageDict = [[NSMutableDictionary alloc] initWithCapacity: 10];
                [dataStorage setObject: lastPageDict
                                forKey: LAST_PAGE_KEY]; 
                [lastPageDict release];
            }
            if(!accessibleBooks)
            {
                accessibleBooks = [[NSMutableArray alloc] initWithCapacity: 10];
                [dataStorage setObject: accessibleBooks 
                                forKey: ACCESSIBLEBOOKS_KEY];
                [accessibleBooks release];
            }
		}
	}
	return self;
}

/*
- (void) _loadGuestBook: (NSString *)bookName 
				 bookId: (NSString *)bookId
{
	MLBook *book = nil;
	CGDataProviderRef dataProvider;	
	CGPDFDocumentRef pdf;
	UIImage *coverArt;
	NSData *artData;
	
	// What is ITI...
	book = [[MLBook alloc] init];
	book.title = bookName;
	book.bookId = bookId;
	book.drmId = @"";
	book.thumbnailUrl = nil;
	book.version = @"1";
	book.summary = bookName;
	book.bookData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: bookName ofType: @"pdf"]];
	[self addBook: book];
	[book release];
    
	dataProvider = CGDataProviderCreateWithCFData((CFDataRef)book.bookData);
	pdf = CGPDFDocumentCreateWithProvider(dataProvider);
    CFRelease(dataProvider);
	coverArt = [MLDataStore imageFromPDF: pdf];
	CFRelease(pdf);
	artData = UIImagePNGRepresentation(coverArt);
	[self addCoverArt: artData forBookId: book.bookId];	
}

- (void) _loadGuestBooks
{
	[self _loadGuestBook: @"What Is ITI"
				  bookId: @"Guest001"];
	
	[self _loadGuestBook: @"What is Sheet Metal"
				  bookId: @"Guest002"];
	
	[self _loadGuestBook: @"A Job or Career"
				  bookId: @"Guest003"];
	
	[self _loadGuestBook: @"Questions and Answers"
				  bookId: @"Guest004"];
    
    [self _loadGuestBook: @"PDF32000_2008"
				  bookId: @"Guest005"];
	
}

- (id) initForGuestUser
{
	if((self = [super init]) != nil)
	{
		storageFile = nil; // do not create a storage file for the guest user since content will be static...
		
		[self clearStore];
		[self _loadGuestBooks];
	}
	return self;
}
*/

- (void) commitToStorage
{
	if(storageFile != nil)
	{
		[NSKeyedArchiver archiveRootObject: dataStorage
									toFile: storageFile];
	}
}

- (void) dealloc
{
    [lock release];
	[storageFile release];
	[dataStorage release];
	[super dealloc];
}

- (NSManagedObjectContext *)managedObjectContext
{
    MosaicEReaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    return context;
}

- (void) saveContext
{
    MosaicEReaderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveContext];
}
 
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void) addBookId: (NSString *)bookId
          withData: (NSData *)bookData
{
    NSString *dataFile = [self fileNameForBookId: bookId];
    [bookData writeToFile: dataFile atomically: YES];
}

- (NSMutableData *) retrieveDataForBookId: (NSString *)bookId
{
    NSString *dataFile = [self fileNameForBookId: bookId];
    NSMutableData *result = [NSMutableData dataWithContentsOfFile:dataFile];
    return result;
}

- (void) removeDataForBookId: (NSString *)bookId
{
    NSDictionary *parts = [pagesAndParts objectForKey: bookId];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(parts != nil)
    {
        for(NSString *partId in [parts allKeys])
        {            
            NSString *dataFile = [self fileNameForBookId: bookId
                                                    part: [partId intValue]];
            [fm removeItemAtPath:dataFile error:NULL];
        }
    }
    else
    {
        NSString *dataFile = [self fileNameForBookId: bookId];
        [fm removeItemAtPath:dataFile error:NULL];
    }
}

- (void) addBookId: (NSString *)bookId
          withData: (NSData *)aData
           forPart: (NSUInteger)part
{
    NSString *fileName = [self fileNameForBookId: bookId
                                            part: part];
    [aData writeToFile: fileName atomically: YES];
}

- (NSMutableData *) retrieveDataForBookId: (NSString *)bookId
                                     part: (NSUInteger)part
{
    NSString *dataFile = [self fileNameForBookId: bookId part: part];
    NSMutableData *result = [NSMutableData dataWithContentsOfFile:dataFile];
    return result;    
}

- (void) addBook: (MLBook *)book
{	
    if([self retrieveBook:book.bookId] == nil)
    {
        [userBooks release];
        userBooks = nil;
        
        [lock lock];
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Book"
                                       inManagedObjectContext:context];
        NSData *bookData = [NSKeyedArchiver archivedDataWithRootObject:book];
        Book *dbBook = [[Book alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        dbBook.bookData = bookData;
        dbBook.bookId = book.bookId;
        dbBook.collectionId = USER_BOOKS_ID;
        [self saveContext];
        [lock unlock];
    }
}

- (MLBook *) retrieveBook: (NSString *)bookId
{
    [lock lock];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Book" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"bookId like %@ and collectionId = %@", 
                              bookId, USER_BOOKS_ID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    [lock unlock];

    if (array == nil || [array count] == 0)
    {
        return nil;
    }    
    else
    {
        Book *dbBook = [array objectAtIndex: 0];
        MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
        return  book;
    }
    
    return nil;
}

- (void) removeBook:(NSString *)bookId
{
    [lock lock];
    
    [userBooks release];
    userBooks = nil;
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Book" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"bookId like %@", bookId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil || [array count] == 0)
    {
        NSLog(@"Couldn't find book.");
    }    
    else
    {
        Book *dbBook = [array objectAtIndex: 0];
        [moc deleteObject:dbBook];
    }
    [lock unlock];
}


- (void) addAvailableBook: (MLBook *)book
{	
    if([self retrieveBook:book.bookId] == nil)
    {
        [lock lock];
        [availableBooks release];
        availableBooks = nil;
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Book"
                                       inManagedObjectContext:context];
        NSData *bookData = [NSKeyedArchiver archivedDataWithRootObject:book];
        Book *dbBook = [[Book alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        dbBook.bookData = bookData;
        dbBook.bookId = book.bookId;
        dbBook.collectionId = AVAILABLE_BOOKS_ID;
        
        [self saveContext];
        [lock unlock];
    }
}

- (MLBook *) retrieveAvailableBook:(NSString *)bookId
{
    [lock lock];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Book" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"bookId like %@ and collectionId = %@", 
                              bookId, AVAILABLE_BOOKS_ID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    [lock unlock];
    if (array == nil || [array count] == 0)
    {
        return nil;
    }    
    else
    {
        Book *dbBook = [array objectAtIndex: 0];
        MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
        return  book;
    }
    
    return nil;
}

- (void) removeAvailableBook: (NSString *)bookId
{
    [lock lock];
    [availableBooks release];
    availableBooks = nil;
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Book" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"bookId like %@", bookId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil || [array count] == 0)
    {
        NSLog(@"Couldn't find book.");
    }    
    else
    {
        Book *dbBook = [array objectAtIndex: 0];
        [moc deleteObject:dbBook];
    }
    [lock unlock];
}

- (void) addNotAvailableBook: (MLBook *)book
{	
    if([self retrieveBook:book.bookId] == nil)
    {
        [lock lock];
        [notAvailableBooks release];
        notAvailableBooks = nil;
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Book"
                                       inManagedObjectContext:context];
        NSData *bookData = [NSKeyedArchiver archivedDataWithRootObject:book];
        Book *dbBook = [[Book alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        dbBook.bookData = bookData;
        dbBook.bookId = book.bookId;
        dbBook.collectionId = NOT_AVAILABLE_BOOKS_ID;
        
        [self saveContext];
        [lock unlock];
    }
}

- (MLBook *) retrieveNotAvailableBook:(NSString *)bookId
{
    [lock lock];
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Book" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"bookId like %@ and collectionId = %@", 
                              bookId, NOT_AVAILABLE_BOOKS_ID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    [lock unlock];
    if (array == nil || [array count] == 0)
    {
        return nil;
    }    
    else
    {
        Book *dbBook = [array objectAtIndex: 0];
        MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
        return  book;
    }
    
    return nil;
}

- (void) setAccessibleBooks: (NSMutableArray *)books
{
    [dataStorage setObject: books forKey: ACCESSIBLEBOOKS_KEY];
}

- (NSMutableArray *) accessibleBooks
{
    return [dataStorage objectForKey: ACCESSIBLEBOOKS_KEY];
}

- (void) addCoverArt: (NSData *)image
		   forBookId: (NSString *)bookId
{
    NSString *fileName = [NSString stringWithFormat: @"%@-coverart.img",bookId];
    NSString *dataFile = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];    

	if(image == nil)
		return;

    [image writeToFile: dataFile atomically: YES];
}

- (NSData *) retrieveCoverArtForBookId: (NSString *)bookId
{
    NSString *fileName = [NSString stringWithFormat: @"%@-coverart.img",bookId];
    NSString *dataFile = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];    
    NSData *image = [NSData dataWithContentsOfFile: dataFile];
    return image;
}

- (void) addKey: (NSString *)key
	  forBookId: (NSString *)bookId
{
    if(key == nil)
    {
        [TestFlight passCheckpoint: [NSString stringWithFormat: @"Key is nil for book id %@",bookId]];
        NSLog(@"Key is nil for book id %@",bookId);
        return;
    }

    if(bookId == nil)
    {
        [TestFlight passCheckpoint: @"BookId is nil!!"];
        NSLog(@"Book id is nil!!");
        return;
    }

    [keys setObject: key
			 forKey: bookId];
	[self commitToStorage];
}

- (NSString *) retrieveKey: (NSString *)bookId;
{
	return [keys objectForKey: bookId];
}

- (NSMutableArray *) allDownloadedBooks
{
    if(userBooks == nil)
    {
        userBooks = [[NSMutableDictionary alloc] initWithCapacity:10];
        [lock lock];
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Book" inManagedObjectContext:moc];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"collectionId = %@", 
                                  USER_BOOKS_ID];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        [lock unlock];

        NSMutableArray *result = [NSMutableArray arrayWithCapacity:100];
        for(Book *dbBook in array)
        {
            MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
            [result addObject:book];
            [userBooks setObject:book forKey:book.bookId];
        }
        return result;
    }

    return [[userBooks allValues] mutableCopy];
}

- (NSMutableArray *) allAvailableBooks
{
    if(availableBooks == nil)
    {
        availableBooks = [[NSMutableDictionary alloc] initWithCapacity:10];        
        [lock lock];
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Book" inManagedObjectContext:moc];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"collectionId = %@", 
                                  AVAILABLE_BOOKS_ID];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        [lock unlock];

        NSMutableArray *result = [NSMutableArray arrayWithCapacity:100];
        for(Book *dbBook in array)
        {
            MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
            [result addObject:book];
            [availableBooks setObject:book forKey:book.bookId];                
        }
        return result;        
    }    
    return [[availableBooks allValues] mutableCopy];
}

- (NSMutableArray *) allNotAvailableBooks
{
    if(notAvailableBooks == nil)
    {
        notAvailableBooks = [[NSMutableDictionary alloc] initWithCapacity:10];        
        [lock lock];
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Book" inManagedObjectContext:moc];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"collectionId = %@", 
                                  NOT_AVAILABLE_BOOKS_ID];
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        [lock unlock];

        NSMutableArray *result = [NSMutableArray arrayWithCapacity:100];
        for(Book *dbBook in array)
        {
            MLBook *book = (MLBook *)[NSKeyedUnarchiver unarchiveObjectWithData:dbBook.bookData];
            [result addObject:book];
            [notAvailableBooks setObject:book forKey:book.bookId];                                
        }
        return result;
    }    
    return [[notAvailableBooks allValues] mutableCopy];
}

- (void) addSession: (MLAuthenticateResult *)session
		forUsername: (NSString *)userName
		andPassword: (NSString *)password
{
	NSString *stringToHash = [userName stringByAppendingString:password];
	NSString *hashString = [stringToHash stringByHashingStringWithSHA1];
	
	[allSessions setObject: session
					forKey: hashString];
	[self commitToStorage];
}

- (MLAuthenticateResult *) retrieveSessionForUsername: (NSString *)name
										  andPassword: (NSString *)password
{
	NSString *stringToHash = [name stringByAppendingString:password];
	NSString *hashString = [stringToHash stringByHashingStringWithSHA1];
	
	MLAuthenticateResult *result = [allSessions objectForKey: hashString];
	
	return result;
}

- (void) addBookmarkInBook: (MLBook *)book
				   forPage: (NSUInteger)page
{
	NSMutableArray *array = [bookmarks objectForKey: book.bookId];
	NSNumber *pageNum = [NSNumber numberWithInt: page];

	if(array == nil)
	{
		array = [NSMutableArray arrayWithCapacity: 10];
		[bookmarks setObject: array
					  forKey: book.bookId];		
	}

	if([array containsObject: pageNum] == NO)
	{
		[array addObject: pageNum];
	}
	[self commitToStorage];
}

- (void) deleteBookmarkInBook: (MLBook *)book
					  forPage: (NSUInteger)page
{
	NSNumber *pageNum = [NSNumber numberWithInt: page];
	NSMutableArray *array = [bookmarks objectForKey: book.bookId];
	[array removeObject: pageNum];
	[self commitToStorage];	
}

- (NSArray *)allBookmarksForBook: (MLBook *)book
{
	return [bookmarks objectForKey: book.bookId];
}

- (BOOL) isPageNumberBookmarked: (NSUInteger)page
						 inBook: (MLBook *)book
{
	NSArray *array = [self allBookmarksForBook: book];
	return [array containsObject: [NSNumber numberWithInt: page]];
}

// Notes
- (void) addNote: (Note *)note
         forBook: (MLBook *)book
          onPage: (NSUInteger)page
{
    NSMutableDictionary *dictForBook = [notes objectForKey: book.bookId];
    if(!dictForBook)
    {
        dictForBook = [NSMutableDictionary dictionaryWithCapacity: 10];
        [notes setObject: dictForBook forKey: book.bookId];
    }
    
    NSMutableArray *array = [self notesForBook:book onPage:page];
    if(array == nil)
    {
        array = [NSMutableArray arrayWithCapacity: 10];
    }
    
    [array addObject:note];
    [dictForBook setObject: array forKey: [NSNumber numberWithInt: page]];
	[self commitToStorage];
}

- (void) deleteNote: (Note *)note
            forBook: (MLBook *)book
             onPage: (NSUInteger)page
{
    NSMutableDictionary *dictForBook = [notes objectForKey: book.bookId];
    NSMutableArray *array = [dictForBook objectForKey: [NSNumber numberWithInt: page]];
    if(array)
    {
        [array removeObject: note];
    }
	[self commitToStorage];
}

- (NSMutableArray *) notesForBook: (MLBook *)book
                    onPage: (NSUInteger)page
{
    NSMutableDictionary *dictForBook = [notes objectForKey: book.bookId];
    NSMutableArray *array = [dictForBook objectForKey: [NSNumber numberWithInt: page]];
    return array;
}

- (NSArray *) notesForBook: (MLBook *)book
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: 10];
    NSDictionary *dictForBook = [notes objectForKey: book.bookId];
    NSEnumerator *en = [dictForBook keyEnumerator];
    NSNumber *key;
    while((key= [en nextObject]) != nil)
    {
        NSArray *notesArray = [dictForBook objectForKey: key];
        [result addObjectsFromArray: notesArray];
    }
    return result;
}

- (BOOL) isNoteOnPage: (NSUInteger)page
               inBook: (MLBook *)book
{
    NSMutableDictionary *dictForBook = [notes objectForKey: book.bookId];
    NSMutableArray *array = [dictForBook objectForKey: [NSNumber numberWithInt: page]];
    return array != nil;
}

// Paths...
- (void) addPaths: (NSMutableArray *)array
          forPage: (NSUInteger)page
           inBook: (MLBook *)book
{
    if(page == 0)
        return;
    
    NSMutableDictionary *dictForBook = [paths objectForKey: book.bookId];
    if(!dictForBook)
    {
        dictForBook = [NSMutableDictionary dictionaryWithCapacity: 10];
        [paths setObject: dictForBook forKey: book.bookId];
    }
    
    [dictForBook setObject: array forKey: [NSNumber numberWithInt: page]];    
	[self commitToStorage];
}

- (void) deletePathsForBook: (MLBook *)book
                     onPage: (NSUInteger)page
{
    NSMutableDictionary *dictForBook = [paths objectForKey: book.bookId];
    NSArray *array = [dictForBook objectForKey: [NSNumber numberWithInt: page]];
    if(array)
    {
        [dictForBook removeObjectForKey: [NSNumber numberWithInt:page]];
    }    
	[self commitToStorage];
}

- (NSMutableArray *)pathsForBook: (MLBook *)book
                          onPage: (NSUInteger)page
{
    NSMutableDictionary *dictForBook = [paths objectForKey: book.bookId];
    NSMutableArray *array = [dictForBook objectForKey: [NSNumber numberWithInt: page]];
    return array;
}

// Book meta data...
- (NSMutableString *) getDataForBook: (MLBook *)book
                              onPage: (NSUInteger) page
{
    NSString *fileName = [NSString stringWithFormat: @"%@-%d-cachedsearch.txt",book.bookId,page];
    NSString *dataFile = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];    
    NSMutableString *string = [NSMutableString stringWithContentsOfFile:dataFile encoding:NSUTF8StringEncoding error:NULL];
    return string;
}

- (void) addData: (NSMutableString *)string
         forBook: (MLBook *)book
          onPage: (NSUInteger)page
{
    NSString *fileName = [NSString stringWithFormat: 
                          @"%@-%d-cachedsearch.txt",book.bookId,page];
    NSString *dataFile = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];    
    
	if(string == nil)
		return;
    
    [string writeToFile:dataFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];   
}

// Cached searches...
- (NSMutableArray *) cachedSearch: (NSString *)criteria
                          forBook: (MLBook *)book
{
    NSMutableDictionary *dictForBook = [cachedSearch objectForKey: book.bookId];
    NSMutableArray *array = [dictForBook objectForKey: criteria];
    return array;
}

- (void) addCachedSearch: (NSString *)criteria
                 forBook: (MLBook *)book
                 results: (NSMutableArray *)results
{
    if(criteria == nil)
        return;
    
    NSMutableDictionary *dictForBook = [cachedSearch objectForKey: book.bookId];
    if(!dictForBook)
    {
        dictForBook = [NSMutableDictionary dictionaryWithCapacity: 10];
        [cachedSearch setObject: dictForBook forKey: book.bookId];
    }
    
    [dictForBook setObject: results forKey: criteria];    
	[self commitToStorage];    
}

- (void) saveImage: (UIImage *)image
           forBook: (NSString *)bookId
            onPage: (NSUInteger)pageNum
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [NSString stringWithFormat: @"%@-%d.img",
                          bookId,pageNum];

    NSLog(@"Caching Image page %d for %@",pageNum,bookId);
    
    if([[NSFileManager defaultManager] fileExistsAtPath: fileName] == NO)
    {
        NSString *dataFile = [[self applicationDocumentsDirectory] 
                              stringByAppendingPathComponent:fileName];
        [imageData writeToFile: dataFile atomically: YES];
    }
}

- (void) savePDF: (NSMutableData *)pdfData
         forBook: (NSString *)bookId
          onPage: (NSUInteger)pageNum
{
    NSString *fileName = [NSString stringWithFormat: @"%@-%d.img",
                          bookId,pageNum];
    
    NSLog(@"Caching PDF page %d for %@",pageNum,bookId);
    
    if([[NSFileManager defaultManager] fileExistsAtPath: fileName] == NO)
    {
        NSString *key = [self retrieveKey: bookId];
        NSString *dataFile = [[self applicationDocumentsDirectory] 
                              stringByAppendingPathComponent:fileName];
        NSMutableData *encryptedData = [MLAPICommunicator encryptData:pdfData 
                                                              withKey:key];
        [encryptedData writeToFile: dataFile atomically: YES];
    }
}


- (NSMutableData *) decryptedBookDataForBookId: (NSString *)bookId
{
    NSString *bookFileName = [self fileNameForBookId: bookId];
    NSMutableData *bookData = [[NSMutableData alloc] initWithContentsOfFile: bookFileName];
    if(bookData == nil)
    {
        return nil;
    }
    NSString *key = [self retrieveKey: bookId];
    NSMutableData *resultData = [MLAPICommunicator decryptData: bookData withKey: key]; 
    [bookData release];
    return resultData;
}

- (NSMutableData *) decryptedBookDataForBookId: (NSString *)bookId
                                       forPart: (NSUInteger)part
{
    NSString *bookFileName = [self fileNameForBookId: bookId
                                                part: part];
    NSMutableData *bookData = [[NSMutableData alloc] initWithContentsOfFile: bookFileName];
    if(bookData == nil)
    {
        return nil;
    }
    NSString *key = [self retrieveKey: bookId];
    NSMutableData *resultData = [MLAPICommunicator decryptData: bookData withKey: key];     
    [bookData release];
    return resultData;
}

- (void) _startCaching: (id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CachingStartedNotification"
                                                        object: nil];        
}

- (void) _interruptCaching: (id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CachingInterruptedNotification"
                                                        object: nil];    
}

- (void) _completeCaching: (id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CachingCompleteNotification"
                                                        object: nil];        
}

- (void) _allowUserInteraction: (id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AllowUserInteractionNotification"
                                                        object: nil];        
}

- (NSString *)fileNameForPage: (NSUInteger)pageNum withBookId: (NSString *)bookId
{
    NSString *fileName = [NSString stringWithFormat: @"%@-%d.img",
                          bookId,pageNum]; 
    NSString *dataFile = [[self applicationDocumentsDirectory] 
                          stringByAppendingPathComponent:fileName];
    return dataFile;
}

- (BOOL) dataExistsForPage: (NSUInteger)pageNum withBookId: (NSString *)bookId
{
    NSString *dataFile = [self fileNameForPage:pageNum withBookId:bookId];
    return [[NSFileManager defaultManager] fileExistsAtPath: dataFile];
}

- (NSData *) imageForBookId: (NSString *)bookId
                      onPage: (NSUInteger)pageNum
{
    NSString *fileName = [NSString stringWithFormat: @"%@-%d.img",
                          bookId,pageNum];
    NSString *dataFile = [[self applicationDocumentsDirectory] 
                          stringByAppendingPathComponent:fileName];
    NSMutableData *result = [NSMutableData dataWithContentsOfFile:dataFile];  
    
    if(result == nil)
    {
        NSMutableData *bookData = nil;
        NS_DURING
        {
            MLBook *book = [self retrieveBook: bookId];
            if(book.numParts == 0)
            {
                bookData = [self decryptedBookDataForBookId: bookId];  // autoreleased
                if(bookData == nil)
                {
                    return nil;
                }
                
                // get number of pages...
                CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)bookData);	
                CGDataProviderRetain(dataProvider);
                CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
                
                result = [MLDataStore pdfFromPDF: document
                                         pageNum: pageNum];
                [self savePDF: result forBook: bookId onPage: pageNum];
                
                CGDataProviderRelease(dataProvider);
                CGPDFDocumentRelease(document);
                [bookData release];
            }
            else
            {
                NSUInteger part = [book partForPage: pageNum];
                bookData = [self decryptedBookDataForBookId: bookId
                                                    forPart: part];  
                if(bookData == nil)
                {
                    return nil;
                }
                
                // get number of pages...
                CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)bookData);	
                CGDataProviderRetain(dataProvider);
                CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
                NSUInteger realPageNum = [book partPageNumber: pageNum];
                
                result = [MLDataStore pdfFromPDF: document
                                         pageNum: realPageNum];
                [self savePDF: result forBook: bookId onPage: pageNum];
                
                CGDataProviderRelease(dataProvider);
                CGPDFDocumentRelease(document);
            }
        }
        NS_HANDLER
        {
            MLDataStore *dataStore = [MLDataStore sharedInstance];
            [dataStore removeBook: bookId];
            [dataStore removeDataForBookId: bookId];
            
            NSLog(@"Local exception %@",[localException reason]);
            [localException raise];
        }
        NS_ENDHANDLER;
    }
    else
    {
        NSString *key = [self retrieveKey: bookId];
        NS_DURING
        {
            NSMutableData *newData = 
                [MLAPICommunicator decryptData:result withKey:key];
            result = newData;
        }
        NS_HANDLER
        {
            [NSException raise:NSInternalInconsistencyException 
                        format:@"Could not decrypt page %d for bookId %@",pageNum,bookId];
        }
        NS_ENDHANDLER;
    }
    
    return result;
}

- (void) bookIsDoneCaching: (NSString *)bookId
{
    [cachedBooks addObject: bookId];
    [self commitToStorage];
}

- (BOOL) isBookDoneCaching: (NSString *)bookId
{
    return [cachedBooks containsObject: bookId];
}

- (void) buildPagesCacheForBook: (NSString *)bookId
{
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    NSMutableData *bookData = nil;

    NS_DURING
    {
        MLBook *book = [self retrieveBook: bookId];
        NSUInteger numPages = book.numPages;
        NSString *fileName = [self fileNameForBookId: bookId];
        NSUInteger startPage = [self lastPageCachedForBookId: bookId];
        
        for(size_t i = startPage + 1; i <= numPages; i++)
        {
            if([self dataExistsForPage: i withBookId: bookId] == NO)
            {
                MLBook *book = [self retrieveBook: bookId];
                if(book.numParts == 0)
                {
                    NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init]; 
                    bookData = [self decryptedBookDataForBookId: bookId]; 
                    // get number of pages...
                    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)bookData);
                    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);

                    NSMutableData *pdfdata = [MLDataStore pdfFromPDF: document
                                                             pageNum: i];
                    [self savePDF: pdfdata forBook: bookId onPage: i];
                     
                    CGDataProviderRelease(dataProvider);
                    CGPDFDocumentRelease(document);
                    [p2 release];
                }
                else
                {
                    NSAutoreleasePool *p2 = [[NSAutoreleasePool alloc] init]; 
                    NSUInteger part = [book partForPage: i];
                    NSString *newFileName = [self fileNameForBookId: book.bookId part: part];
                    
                    
                    fileName = newFileName;
                    bookData = [self decryptedBookDataForBookId: bookId
                                                        forPart: part]; 
                    
                    // get number of pages...
                    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)bookData);	
                    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
                    NSUInteger realPageNum = [book partPageNumber: i];

                    NSMutableData *pdfdata = [MLDataStore pdfFromPDF: document
                                                             pageNum: realPageNum];
                    [self savePDF: pdfdata forBook: bookId onPage: i];
                     
                    CGDataProviderRelease(dataProvider);
                    CGPDFDocumentRelease(document);
                    [p2 release];
                }            
                
                if([[NSThread currentThread] isCancelled])
                {
                    NSLog(@"Page caching aborted...");
                    [self performSelectorOnMainThread: @selector(_interruptCaching:) 
                                           withObject: nil
                                        waitUntilDone: NO];
                    [p release];
                    [NSThread exit];
                }
            }
            
            [self setLastPage: i forBookId: bookId];

            if(i >= INITIAL_PAGES)
            {
                [self performSelectorOnMainThread: @selector(_allowUserInteraction:) 
                                       withObject: nil
                                    waitUntilDone: NO];
            }
        }    
        
        NSLog(@"Finished caching pages for %@..",bookId);
        [self performSelectorOnMainThread: @selector(_completeCaching:) 
                               withObject: nil
                            waitUntilDone: NO];
        [self bookIsDoneCaching: bookId];
        
        [p release];          
    }
    NS_HANDLER
    {
        MLDataStore *dataStore = [MLDataStore sharedInstance];
        [dataStore removeBook: bookId];
        [dataStore removeDataForBookId: bookId];
        NSLog(@"Exception thrown during caching: %@",[localException reason]);
        [localException raise];
    }
    NS_ENDHANDLER;
}

- (NSString *)fileNameForBookId: (NSString *)bookId
{
    NSString *fileName = [NSString stringWithFormat: @"%@.mlx",bookId];
    NSString *dataFile = [[self applicationDocumentsDirectory] 
                          stringByAppendingPathComponent:fileName];
    return dataFile;
}

- (NSString *)fileNameForBookId: (NSString *)bookId
                           part: (NSUInteger)part
{
    NSString *fileName = [NSString stringWithFormat: @"%@$%d.mlx",bookId,part];
    NSString *dataFile = [[self applicationDocumentsDirectory] 
                          stringByAppendingPathComponent:fileName];
    return dataFile;
}

- (void) setPages: (NSUInteger)pages forPart: (NSUInteger)part ofBook: (NSString *)bookId
{
    NSMutableDictionary *dict = [pagesAndParts objectForKey: bookId];
    if(dict == nil)
    {
        dict = [NSMutableDictionary dictionaryWithCapacity: 10];
        [pagesAndParts setObject: dict forKey: bookId];
    }
    [dict setObject: [NSNumber numberWithInt: pages]
             forKey: [NSNumber numberWithInt: part]];
}

- (NSUInteger) pagesForPart: (NSUInteger)part ofBook: (NSString *)bookId
{
    NSMutableDictionary *dict = [pagesAndParts objectForKey: bookId];
    return [[dict objectForKey: [NSNumber numberWithInt: part]] intValue];
}

- (NSUInteger) lastPageCachedForBookId: (NSString *)bookId
{
    return [[lastPageDict objectForKey: bookId] intValue];
}

- (void) setLastPage: (NSUInteger)page
           forBookId: (NSString *)bookId
{
    [lastPageDict setObject: [NSNumber numberWithInt: page]
                     forKey: bookId];
    [self commitToStorage];
}

// Zipping and unzipping...
- (void) unzipFileForBookId: (NSString *)bookId
{
    NSString *fileName = [self fileNameForBookId: bookId];
    NSString *dirName = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: bookId];
    NSString *zipFile = [[fileName stringByDeletingPathExtension] stringByAppendingPathExtension: @"zip"];
    NSMutableData *zipData = [MLAPICommunicator decryptData: [NSMutableData dataWithContentsOfFile: fileName] withKey: [self retrieveKey: bookId]];
    [zipData writeToFile: zipFile atomically: YES];
    [SSZipArchive unzipFileAtPath: zipFile toDestination: dirName];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:zipFile error:NULL];  // get rid of the unencrypted version of the file
}

- (void) deleteFilesForBookId: (NSString *)bookId
{
    NSString *dirName = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: bookId];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:dirName error:NULL];
}

- (NSString *) indexFileForBookId: (NSString *)bookId
{
    NSString *dirName = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: bookId];
    NSString *indexName = [dirName stringByAppendingPathComponent:@"index.html"];
    return indexName;
}

- (void) logout
{
    _datastore_instance =  nil;
    [allSessions removeAllObjects];
    [self commitToStorage];
    exit(0);
}
@end
