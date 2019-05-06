//
//  MLSearchLibraryCommand.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCommand.h"

@interface MLSearchLibraryCommand : MLCommand {
    NSString *searchTerm;
}

@property (nonatomic, retain) NSString *searchTerm;

@end
