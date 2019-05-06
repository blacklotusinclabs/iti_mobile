//
//  MLCategory.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/21/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLCategory : NSObject {
    NSString *name;
    NSString *categoryId;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *categoryId;

@end
