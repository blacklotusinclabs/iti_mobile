//
//  SearchCriteria.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLBook;

@interface SearchCriteria : NSObject {
    MLBook *book;
    NSString *terms;
}

@property (nonatomic,retain) MLBook *book;
@property (nonatomic,retain) NSString *terms;

@end
