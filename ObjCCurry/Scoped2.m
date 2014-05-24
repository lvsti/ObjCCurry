//
//  Scoped2.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.23..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#define FN_IMPLEMENTATION
#import "Scoped2.h"

@functionImpl(Cons)

- (NSArray*):(id)value :(NSArray*)list{
    return [@[value] arrayByAddingObjectsFromArray:list];
}

@end
