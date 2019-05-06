//
//  MLGetNotAvailableBooksCommand.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLGetNotAvailableBooksCommand.h"

#ifdef TEST
#import "MLArrayOfBook.h"
#import "MLBook.h"
#endif

@implementation MLGetNotAvailableBooksCommand

- (NSURL *) url
{
	return [NSURL URLWithString: 
            [NSString stringWithFormat: 
             @"http://%@/Book.asmx/GetNotAvailableBooks",[self baseURL]]];
}

- (NSString *) asXML
{
	NSString *format = @"userId=%@&sessionId=%@";
	
	return [NSString stringWithFormat: format, session.userId,session.sessionId];
}

#ifdef TEST
- (id) testResponse
{
	MLArrayOfBook *books = [[MLArrayOfBook alloc] init];
	MLBook *book = [[MLBook alloc] init];
	book.bookId = @"Blah blah2";
	book.title = @"Example book #2";
	book.summary = @"This book is an example.";
	book.thumbnailUrl = @"Testing.";
	[books addBook: book];
	return books;
}
#endif

@end
