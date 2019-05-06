//
//  MLFile.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLFile : NSObject
{
    NSString *fileUrl;
    NSString *fileBytes;
    NSString *orderBy;
    NSString *pageCount;
}

@property (nonatomic,retain) NSString *fileUrl;
@property (nonatomic,retain) NSString *fileBytes;
@property (nonatomic,retain) NSString *orderBy;
@property (nonatomic,retain) NSString *pageCount;

@end
