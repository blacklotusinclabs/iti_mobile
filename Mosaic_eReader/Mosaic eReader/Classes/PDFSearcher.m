//
//  PDFSearcher.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 4/3/11.
//  Copyright 2011 . All rights reserved.
//

#import "PDFSearcher.h"
#import "MLDataStore.h"
#import "MLAPICommunicator.h"

// PDF handler functions
void op_MP(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_DP(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_BMC(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_BDC(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_EMC(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tc(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tw(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tz(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_TL(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tf(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tr(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Ts(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}

void op_TJ(CGPDFScannerRef inScanner, void *userInfo)
{
    PDFSearcher * searcher = (PDFSearcher *)userInfo;
	
    CGPDFArrayRef array;
    
    bool success = CGPDFScannerPopArray(inScanner, &array);
    
    for(size_t n = 0; n < CGPDFArrayGetCount(array); n += 2)
    {
        if(n >= CGPDFArrayGetCount(array))
            continue;
        
        CGPDFStringRef string;
        success = CGPDFArrayGetString(array, n, &string);
        if(success)
        {
            NSString *data = (NSString *)CGPDFStringCopyTextString(string);
            [searcher.currentData appendFormat:@"%@", data];
            [data release];
        }
    }
}

void op_Tj(CGPDFScannerRef inScanner, void *userInfo)
{
    PDFSearcher *searcher = (PDFSearcher *)userInfo;
    
    CGPDFStringRef string;
    
    bool success = CGPDFScannerPopString(inScanner, &string);
	
    if(success)
    {
        NSString *data = (NSString *)CGPDFStringCopyTextString(string);
        [searcher.currentData appendFormat:@"%@", data];
        [data release];
    }
}

void op_apostrof(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_double_apostrof(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Td(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_TD(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_Tm(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_T(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_BT(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}
void op_ET(CGPDFScannerRef inScanner, void *userInfo)
{
    //NSLog(@"Called");
}

@implementation PDFSearcher

@synthesize currentData;

-(id)init
{
    if((self = [super init]) != nil)
    {
        table = CGPDFOperatorTableCreate();
        // CGPDFOperatorTableSetCallback(table, "TJ", arrayCallback);
        //CGPDFOperatorTableSetCallback(table, "Tj", stringCallback);
        
        CGPDFOperatorTableSetCallback (table, "MP", &op_MP);//Define marked-content point
        CGPDFOperatorTableSetCallback (table, "DP", &op_DP);//Define marked-content point with property list
        CGPDFOperatorTableSetCallback (table, "BMC", &op_BMC);//Begin marked-content sequence
        CGPDFOperatorTableSetCallback (table, "BDC", &op_BDC);//Begin marked-content sequence with property list
        CGPDFOperatorTableSetCallback (table, "EMC", &op_EMC);//End marked-content sequence
        
        //Text State operators
        CGPDFOperatorTableSetCallback(table, "Tc", &op_Tc);
        CGPDFOperatorTableSetCallback(table, "Tw", &op_Tw);
        CGPDFOperatorTableSetCallback(table, "Tz", &op_Tz);
        CGPDFOperatorTableSetCallback(table, "TL", &op_TL);
        CGPDFOperatorTableSetCallback(table, "Tf", &op_Tf);
        CGPDFOperatorTableSetCallback(table, "Tr", &op_Tr);
        CGPDFOperatorTableSetCallback(table, "Ts", &op_Ts);
        
        //text showing operators
        CGPDFOperatorTableSetCallback(table, "TJ", &op_TJ);
        CGPDFOperatorTableSetCallback(table, "Tj", &op_Tj);
        CGPDFOperatorTableSetCallback(table, "'", &op_apostrof);
        CGPDFOperatorTableSetCallback(table, "\"", &op_double_apostrof);
        
        //text positioning operators        
        CGPDFOperatorTableSetCallback(table, "Td", &op_Td);
        CGPDFOperatorTableSetCallback(table, "TD", &op_TD);
        CGPDFOperatorTableSetCallback(table, "Tm", &op_Tm);
        CGPDFOperatorTableSetCallback(table, "T*", &op_T);
        
        //text object operators
        CGPDFOperatorTableSetCallback(table, "BT", &op_BT);//Begin text object
        CGPDFOperatorTableSetCallback(table, "ET", &op_ET);//End text object        
    }
    return self;
}

-(BOOL)page:(CGPDFPageRef)inPage containsString:(NSString *)inSearchString withData:(NSMutableString *)cacheData;

{
    if(cacheData)
    {
        [self setCurrentData: cacheData];
    }
    else
    {
        [self setCurrentData: [NSMutableString string]];
        CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(inPage);
        CGPDFScannerRef scanner = CGPDFScannerCreate(contentStream, table, self);
        bool ret = CGPDFScannerScan(scanner);
        if(!ret)
        {
            NSLog(@"Scanner failed!");
        }
        CGPDFScannerRelease(scanner);
        CGPDFContentStreamRelease(contentStream);
    }
    
    return ([[currentData uppercaseString] 
			 rangeOfString:[inSearchString uppercaseString]].location != NSNotFound);
}

- (void)cachePdfPagesForBook:(MLBook *)book 
                    withData:(NSData *)rawData
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)rawData);	
	CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(dataProvider);
	NSString *searchFor = @"";
    NSMutableArray *pagesArray = [NSMutableArray arrayWithCapacity:10];
    
    // If we've done this search before... return the previously generated results, since the book isn't
    // going to change.
    NSMutableArray *array = [[MLDataStore sharedInstance] cachedSearch: searchFor 
                                                               forBook: book];
    if(array != nil)
    {
        CGDataProviderRelease(dataProvider);
        CGPDFDocumentRelease(document);
        NSLog(@"Found cached data for %@ in book %@",searchFor,book);
        return;
    }
    
    // There is no cached data, do the search anyway.
	NSUInteger numPages = CGPDFDocumentGetNumberOfPages(document);	
	NSLog(@"Searching book for %@",searchFor);
	
	size_t i = 0;
	for(i = 0; i < numPages; i++)
	{
        NSUInteger pageNum = i + 1;
        // Get the cached page and search it's contents if this page has already been parsed before...
        NSMutableString *cacheData = [[MLDataStore sharedInstance] getDataForBook: book
                                                                           onPage: pageNum];        
		CGPDFPageRef page = CGPDFDocumentGetPage(document,pageNum);
        
		BOOL containsText = [self page: page 
							containsString: searchFor
                                  withData: cacheData];
		if(containsText)
		{
            [pagesArray addObject: [NSNumber numberWithInt: (int)(pageNum)]];
			NSLog(@"Page #%d contains %@",(int)pageNum,searchFor);
            [[NSNotificationCenter defaultCenter] 
             postNotificationName: @"SearchUpdatedResultsNotification"
             object: nil];
            
		}	
        [[MLDataStore sharedInstance] addData: self.currentData
                                      forBook: book
                                       onPage: pageNum];
	}
    
    // Add cached results...
    [[MLDataStore sharedInstance] addCachedSearch: searchFor 
                                          forBook: book 
                                          results: pagesArray];
    CGDataProviderRelease(dataProvider);
    CGPDFDocumentRelease(document);
    [pool release];
}
@end
