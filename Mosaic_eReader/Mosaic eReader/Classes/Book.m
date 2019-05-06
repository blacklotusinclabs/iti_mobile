//
//  Book.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 4/9/12.
//  Copyright (c) 2012 Open Logic Corporation. All rights reserved.
//

#import "Book.h"
#import "MLBook.h"
#import "XMLObjectParser.h"

@implementation Book

@dynamic bookData;
@dynamic bookId;
@dynamic collectionId;

- (MLBook *) book
{
    XMLObjectParser *parser = 
        [[XMLObjectParser alloc] initWithData:self.bookData 
                                 andNameSpace:@""];
    MLBook *result = (MLBook *)[parser parse];
    [parser release];
    return result;
}

@end
