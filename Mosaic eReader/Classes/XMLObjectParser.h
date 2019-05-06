//
//  XMLObjectParser.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/8/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface XMLObjectParser : NSObject <NSXMLParserDelegate>
{
	NSXMLParser *parser;
	NSString *namespace;
	NSString *currentElementName;
	id currentObject;
	SEL currentSelector;
	BOOL isCollection;
	Stack *objectStack;
	Stack *nameStack;
	Stack *selectorStack;
	
	id resultObject;
}

@property (nonatomic,readonly) NSString *namespace;

- (id) initWithData: (NSData *)data andNameSpace: (NSString *)nmspace;
- (id) initWithContentsOfURL: (NSURL *)url andNameSpace: (NSString *)nmspace;

- (id) parse;

- (NSString *) classNameFromElementName: (NSString *)elementName;
- (NSString *) selectorFromElementName: (NSString *)elementName
								prefix: (NSString *)prefix;
- (NSString *) generateSetSelectorFromElementName: (NSString *)elementName;
- (NSString *) generateAddSelectorFromElementName: (NSString *)elementName;

- (BOOL) objectIsCollection: (id)object;
- (BOOL) currentObjectIsCollection;

@end
