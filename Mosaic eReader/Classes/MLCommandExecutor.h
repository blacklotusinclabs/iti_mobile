//
//  MLCommandExecutor.h
//  Mosaic eReader
//
//  Created by Gregory Casamento on 10/5/10.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MLCommand.h"

@interface MLCommandExecutor : NSObject 
{
}

+ (id) sharedCommandExecutor;

- (id) executeCommand: (MLCommand *)command;

@end
