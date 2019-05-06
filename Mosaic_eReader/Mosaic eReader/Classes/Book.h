//
//  Book.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 4/9/12.
//  Copyright (c) 2012 Open Logic Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSData   * bookData;
@property (nonatomic, retain) NSString * bookId;
@property (nonatomic, retain) NSNumber * collectionId;

@end
