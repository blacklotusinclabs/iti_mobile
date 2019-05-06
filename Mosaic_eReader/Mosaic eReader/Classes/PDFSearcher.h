//
//  PDFSearcher.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 4/3/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResult.h"

@interface PDFSearcher : NSObject 
{
    CGPDFOperatorTableRef table;
    NSMutableString *currentData;
}

@property (nonatomic, retain) NSMutableString * currentData;

-(id)init;
-(BOOL)       page:(CGPDFPageRef)inPage 
    containsString:(NSString *)inSearchString
          withData: (NSMutableString *)cacheData;
- (void)cachePdfPagesForBook:(MLBook *)book 
                    withData:(NSData *)rawData;
@end