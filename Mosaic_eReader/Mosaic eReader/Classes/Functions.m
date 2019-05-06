//
//  Functions.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/6/12.
//  Copyright (c) 2012 Open Logic Corporation. All rights reserved.
//

#import "Functions.h"
#import "MLBook.h"

// Sort function...
NSInteger stringSort(id v1, id v2, void *context)
{
    return [[v1 title] compare: [v2 title]];
}