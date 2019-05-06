//
//  MLAuthenticateResult.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/6/10.
//  Copyright 2010 . All rights reserved.
//

#import "MLAuthenticateResult.h"
#import "MLUserGroup.h"

@implementation MLAuthenticateResult

@synthesize userId;
@synthesize userName;
@synthesize firstName;
@synthesize lastName;
@synthesize accessDate;
@synthesize guestUser;
@synthesize sessionId;

- (id) initWithCoder:(NSCoder *)aCoder
{
	if((self = [super init]) != nil)
	{
		userId = [[aCoder decodeObjectForKey:@"UserID"] retain];
		userName = [[aCoder decodeObjectForKey:@"UserName"] retain];
		firstName = [[aCoder decodeObjectForKey:@"FirstName"] retain];
		lastName = [[aCoder decodeObjectForKey:@"LastName"] retain];
		userGroups = [[aCoder decodeObjectForKey:@"UserGroups"] retain];
		isAuthenticated = [[aCoder decodeObjectForKey:@"isAuthenticated"] retain];
		isBookAdmin = [[aCoder decodeObjectForKey:@"isBookAdmin"] retain];
		accessDate = [[aCoder decodeObjectForKey:@"lastAccess"] retain];
        sessionId = [[aCoder decodeObjectForKey:@"sessionId"] retain];
		
		if(accessDate == nil)
		{
			accessDate = [[NSDate date] retain];
		}
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:userId forKey:@"UserID"];
	[aCoder encodeObject:userName forKey:@"UserName"];
	[aCoder encodeObject:firstName forKey:@"FirstName"];
	[aCoder encodeObject:lastName forKey:@"LastName"];
	[aCoder encodeObject: userGroups forKey:@"UserGroups"];
	[aCoder encodeObject: isAuthenticated forKey:@"isAuthenticated"];
	[aCoder encodeObject: isBookAdmin forKey:@"isBookAdmin"];
	[aCoder encodeObject: accessDate forKey: @"lastAccess"];
    [aCoder encodeObject: sessionId forKey: @"sessionId"];
}

- (void) addUserGroups:(MLUserGroup *)userGroup
{
	[userGroups addObject: userGroup];
}

- (NSString *) isAuthenticated
{
	return isAuthenticated;
}

- (void) setIsAuthenticated: (NSString *)value
{
	isAuthenticated = [value retain];
}

- (BOOL) isAuthenticatedAsBool
{
	return [isAuthenticated isEqualToString: @"true"];
}

- (NSString *) isBookAdmin
{
	return isBookAdmin;
}

- (void) setIsBookAdmin: (NSString *)value
{
	isBookAdmin = [value retain];
}

- (BOOL) isBookAdminAsBool
{
	return [isBookAdmin isEqualToString: @"true"];
}


@end
