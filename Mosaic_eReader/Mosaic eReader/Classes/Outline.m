//
//  Outline.c
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// Based on code from the OutlineExample.c...  here is the notice...

/* Extract the outline from a PDF file.
 * Author: Derek B Clegg
 * 21 March 2003
 *
 * Copyright (c) 2003-2004 Apple Computer, Inc.
 * All rights reserved.
 */

/* IMPORTANT: This Apple software is supplied to you by Apple Computer,
 * Inc. ("Apple") in consideration of your agreement to the following
 * terms, and your use, installation, modification or redistribution of
 * this Apple software constitutes acceptance of these terms.  If you do
 * not agree with these terms, please do not use, install, modify or
 * redistribute this Apple software.
 *
 * In consideration of your agreement to abide by the following terms, and
 * subject to these terms, Apple grants you a personal, non-exclusive
 * license, under Apple's copyrights in this original Apple software (the
 * "Apple Software"), to use, reproduce, modify and redistribute the Apple
 * Software, with or without modifications, in source and/or binary forms;
 * provided that if you redistribute the Apple Software in its entirety and
 * without modifications, you must retain this notice and the following
 * text and disclaimers in all such redistributions of the Apple Software.
 * Neither the name, trademarks, service marks or logos of Apple Computer,
 * Inc. may be used to endorse or promote products derived from the Apple
 * Software without specific prior written permission from Apple. Except as
 * expressly stated in this notice, no other rights or licenses, express or
 * implied, are granted by Apple herein, including but not limited to any
 * patent rights that may be infringed by your derivative works or by other
 * works in which the Apple Software may be incorporated.
 *
 * The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 * MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 * THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 * OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 *
 * IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 * MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 * AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 * STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE. */


#import "Outline.h"
#import <stdlib.h>
#import <string.h>

@implementation OutlineItem

@synthesize name,page,isTitle,destination;

- (id) init
{
    if((self = [super init]) != nil)
    {   
        subItems = [[NSMutableArray alloc] initWithCapacity: 10];
    }
    return self;
}

- (void) dealloc
{
    [name release];
    [subItems release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@, %d, %@, %@> = (%@)",
                        name,
                        page,
                        (isTitle ? @"YES" : @"NO"),
                        destination,
                        subItems];
}

- (id) copyWithZone: (NSZone *)zone
{
    OutlineItem *copy = [[[self class] allocWithZone: zone] init];
    copy.name = self.name;
    copy.page = self.page;
    copy.isTitle = self.isTitle;
    return copy;
}

- (BOOL) isEqual: (id)object
{
    if([object isKindOfClass: [self class]])
    {
        OutlineItem *other = (OutlineItem *)object;
        if(self.name == other.name)
        {
            return YES;
        }
    }
    return NO;
}

- (void) addItem: (OutlineItem *)anItem
{
    [subItems addObject: anItem];
}

- (NSMutableArray *)subItems
{
    return subItems;
}

@end

@implementation Outline

- (id) init
{
    if((self = [super init]) != nil)
    {
        result = [[OutlineItem alloc] init];
        result.name = @"Root";
        entries = [[NSMutableArray alloc] init];
        lastTitle = result;
    }
    return self;
}

- (void)addItem: (BOOL) isTitle
      withTitle: (CFStringRef) title
         isOpen: (BOOL) isOpen
    destination: (NSString *) destination
{
    if(isTitle)
    {
        OutlineItem *item = [[OutlineItem alloc] init];
        
        item.isTitle = isTitle;
        item.name = (NSString *)title;
        item.page = 0; 
        item.destination = destination;
        
        if(lastTitle != nil)
        {
            [lastTitle addItem: item];
        }
        else
        {
            lastTitle = item;
        }
        
        if(result == nil)
        {
            result = item;
        }
        [item release];
    }
    else
    {
        OutlineItem *item = [[OutlineItem alloc] init];
        
        item.name = (NSString *)title;
        item.isTitle = NO;
        item.page = 0;
        item.destination = destination;
        
        [lastTitle addItem: item];
        [item release];
    }
}

- (void) addOutlineItems: (BOOL) isTitle 
            withDocument: (CGPDFDocumentRef) document
               withEntry: (CGPDFDictionaryRef) outline
{
    // int style;
    BOOL isOpen = NO;
    // float color[3];
    CGPDFStringRef string;
    CGPDFDictionaryRef first;
    CGPDFInteger count; // , flags;
    CFStringRef title;
    
    if (document == NULL || outline == NULL)
        return;
    
    do {
        title = NULL;
        if (CGPDFDictionaryGetString(outline, "Title", &string))
        {   
            title = CGPDFStringCopyTextString(string);
            //CFRelease(title);
        }
        isOpen = YES;
        if (CGPDFDictionaryGetInteger(outline, "Count", &count))
            isOpen = (count < 0) ? NO : YES;
        
        CGPDFStringRef page;
        CGPDFDictionaryGetString(outline, "Dest", &page);
        NSString *destination = (NSString *)CGPDFStringCopyTextString(page);
        [self addItem: isTitle withTitle: title isOpen: isOpen destination: destination];
        CFRelease(destination);
        
        if (CGPDFDictionaryGetDictionary(outline, "First", &first))
        {
            [self addOutlineItems: NO
                     withDocument: document
                        withEntry: first];
        }
        
    } while (CGPDFDictionaryGetDictionary(outline, "Next", &outline));
}

- (OutlineItem *) buildOutlineFromDocument: (CGPDFDocumentRef) document
{
    CGPDFDictionaryRef catalog, outline, first;
    
    if (document == NULL)
        return result;
    
    catalog = CGPDFDocumentGetCatalog(document);
    if (!CGPDFDictionaryGetDictionary(catalog, "Outlines", &outline))
        return result;
    
    if (!CGPDFDictionaryGetDictionary(outline, "First", &first))
        return result;
    
    [self addOutlineItems: YES 
             withDocument: document 
                withEntry: first];

    return result;
}

@end