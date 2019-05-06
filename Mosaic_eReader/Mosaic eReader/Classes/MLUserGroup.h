//
//  MLUserGroup.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/7/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLUserGroup : NSObject <NSCoding>
{
	NSString *groupId;
	NSString *name;
}

@property (nonatomic,retain) NSString *groupId;
@property (nonatomic,retain) NSString *name;

@end
