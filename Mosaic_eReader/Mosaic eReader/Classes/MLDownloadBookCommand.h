//
//  MLDownloadBookCommand.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/29/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLBookCommand.h"

@interface MLDownloadBookCommand : MLBookCommand 
{
	NSString *bookId;
}

@property (nonatomic,retain) NSString *bookId;

@end
