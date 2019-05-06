//
//  Outline.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface OutlineItem : NSObject <NSCopying>
{
    NSString *name;
    NSInteger page;
    BOOL isTitle;
    NSMutableArray *subItems;
    NSString *destination;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isTitle;
@property (nonatomic, retain) NSString *destination;

- (void) addItem: (OutlineItem *)anItem;
- (NSMutableArray *)subItems;

@end

@interface Outline : NSObject
{
    OutlineItem *lastTitle;
    OutlineItem *result;
    NSMutableArray *entries;
}

- (void)addItem: (BOOL) isTitle
      withTitle: (CFStringRef) title
         isOpen: (BOOL) isOpen
    destination: (NSString *) destination;


- (void) addOutlineItems: (BOOL) isTitle 
            withDocument: (CGPDFDocumentRef) document
               withEntry: (CGPDFDictionaryRef) outline;

- (OutlineItem *) buildOutlineFromDocument: (CGPDFDocumentRef) document;

@end