//
//  MLDownloadResult.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/26/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLBookFiles.h"

@interface MLDownloadResult : NSObject {
	NSString *bookId;
	NSString *drmId;
	NSString *key;
	NSString *bookUrl;
	NSString *bookBytes;
    NSString *bookFormat;
	NSString *thumbnailUrl;	
    NSString *isSplit;
    MLBookFiles *bookFiles;
    NSString *pageCount;
    NSString *version;
}

@property (nonatomic,retain) NSString *bookId;
@property (nonatomic,retain) NSString *drmId;
@property (nonatomic,retain) NSString *key;
@property (nonatomic,retain) NSString *bookUrl;
@property (nonatomic,retain) NSString *bookBytes;
@property (nonatomic,retain) NSString *thumbnailUrl;
@property (nonatomic,retain) NSString *isSplit;
@property (nonatomic,retain) MLBookFiles *bookFiles;
@property (nonatomic,retain) NSString *pageCount;
@property (nonatomic,retain) NSString *bookFormat;
@property (nonatomic,retain) NSString *version;

- (BOOL) isSplitBool;

@end
