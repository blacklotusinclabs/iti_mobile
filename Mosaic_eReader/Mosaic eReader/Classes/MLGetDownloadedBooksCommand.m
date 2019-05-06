//
//  MLGetDownloadedBooksCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 2/3/11.
//  Copyright 2011 . All rights reserved.
//

#import "MLGetDownloadedBooksCommand.h"
#import "MLDataStore.h"
#import "MLAPICommunicator.h"
#import "MLArrayOfBook.h"

@implementation MLGetDownloadedBooksCommand

- (id) execute
{
	MLDataStore *dataStore = [MLDataStore sharedInstance];
	NSMutableArray *booksArray = [dataStore allDownloadedBooks];
	MLArrayOfBook *books = [[MLArrayOfBook alloc] initWithArray: booksArray];
	[books autorelease];
	return books;	
}

@end
