//
//  XMLObjectParser.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/8/10.
//  Copyright 2010 . All rights reserved.
//

#import "XMLObjectParser.h"
#import "Stack.h"

@implementation XMLObjectParser

@synthesize namespace;

- (id) initWithData: (NSData *)data andNameSpace: (NSString *)nmspace
{
	if((self = [super init]) != nil)
	{
		parser        = [[NSXMLParser alloc] initWithData: data];
		objectStack   = [[Stack alloc] init];
		nameStack     = [[Stack alloc] init];
		selectorStack = [[Stack alloc] init];
		namespace     = [nmspace retain];
		[parser setDelegate: self];
	}
	return self;
}

- (id) initWithContentsOfURL: (NSURL *)url andNameSpace: (NSString *)nmspace
{
	if((self = [super init]) != nil)
	{
		parser        = [[NSXMLParser alloc] initWithContentsOfURL: url];
		objectStack   = [[Stack alloc] init];
		nameStack     = [[Stack alloc] init];
		selectorStack = [[Stack alloc] init];
		namespace     = [nmspace retain];
		[parser setDelegate: self];
	}
	return self;
}

- (id) parse
{
	[parser parse];
	return resultObject;
}

- (void) dealloc
{
	[namespace release];
	[objectStack release];
	[nameStack release];
	[selectorStack release];
	[parser release];
	[super dealloc];
}

- (NSString *) classNameFromElementName: (NSString *)elementName
{
	return [NSString stringWithFormat:@"%@%@",namespace,elementName];
}

- (NSString *) selectorFromElementName: (NSString *)elementName
								prefix: (NSString *)prefix
{
	unichar c = [elementName characterAtIndex: 0];
	NSRange range = NSMakeRange(0,1);
	NSString *oneChar = [[NSString stringWithFormat:@"%C",c] uppercaseString];
	NSString *name = [elementName stringByReplacingCharactersInRange: range withString: oneChar];
	NSString *selectorName = [NSString stringWithFormat: @"%@%@:",prefix,name];

	return selectorName;
}

- (NSString *) generateSetSelectorFromElementName: (NSString *)elementName
{
	return [self selectorFromElementName: elementName prefix: @"set"];
}

- (NSString *) generateAddSelectorFromElementName: (NSString *)elementName
{
	return [self selectorFromElementName: elementName prefix: @"add"];
}

- (BOOL) objectIsCollection: (id)object
{
	return [object respondsToSelector: @selector(objectAtIndex:)];	
}

- (BOOL) currentObjectIsCollection
{
	return [self objectIsCollection: currentObject];
}

- (void)   parser:(NSXMLParser *)p 
  didStartElement:(NSString *)elementName 
	 namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qualifiedName 
	   attributes:(NSDictionary *)attributeDict
{
	Class cls = NSClassFromString([self classNameFromElementName: elementName]);

	// If the cls is nil, then this is an attribute.
	if(cls == nil)
	{
		NSString *setSelectorName = [self generateSetSelectorFromElementName: elementName];
		SEL setSelector = NSSelectorFromString(setSelectorName);
		
		if([currentObject respondsToSelector: setSelector])
		{
			currentSelector = setSelector;
			[selectorStack push: setSelectorName];
		}
	}
	else
	{
		id lastObject = [objectStack lastObject];		
		NSString *addSelectorName = [self generateAddSelectorFromElementName: elementName];
		SEL addSelector = NSSelectorFromString(addSelectorName);
		NSString *setSelectorName = [self generateSetSelectorFromElementName: elementName];
		SEL setSelector = NSSelectorFromString(setSelectorName);

		currentElementName = elementName;
		currentObject = [[cls alloc] init]; // autorelease];
		[objectStack push: currentObject];
		[nameStack push: currentElementName];
		
		if([lastObject respondsToSelector: addSelector])
		{
			currentSelector = addSelector; 
			[selectorStack push: addSelectorName];
			[lastObject performSelector: currentSelector withObject: currentObject];
            [currentObject release];
		}
		else if([lastObject respondsToSelector: setSelector])
		{
			currentSelector = setSelector;
			[selectorStack push: setSelectorName];
			[lastObject performSelector: currentSelector withObject: currentObject];
            [currentObject release];
		}
		
		if(resultObject == nil)
		{
			resultObject = currentObject; // capture the root object...
		}
	}
}

- (void)parser:(NSXMLParser *)p
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
{
	if(![objectStack isEmpty])
	{
		if(NSClassFromString([self classNameFromElementName: elementName]) ==
		   [[objectStack lastObject] class])
		{
			currentObject = [objectStack pop];	
			currentElementName = [nameStack pop];
			currentSelector = NSSelectorFromString([selectorStack pop]);
		}
	}
}

- (void) parser: (NSXMLParser *)p
foundCharacters: (NSString *)string
{
	NSString *newString = [string stringByTrimmingCharactersInSet:
						   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if([newString isEqualToString:@""] == NO)
	{
		if(currentSelector == NULL)
		{
			return;
		}
		
		if([[NSStringFromSelector(currentSelector) substringToIndex: 3] 
			isEqualToString: @"set"]) 
		{
			[currentObject performSelector: currentSelector 
								withObject: string];
		}
	}
}

@end
