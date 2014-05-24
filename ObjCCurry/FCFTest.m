//
//  FCFTest.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.23..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#define FN_IMPLEMENTATION
#import "FCFTest.h"

@functionImpl(Const)
- (id):(id)a :(id)b {
    return a;
}
@end


@functionImpl(Flip)
- (id):(Function*)f :(id)a :(id)b {
    return [f :b :a];
}
@end


@functionImpl(Max)
- (id):(id)a :(id)b {
    return [a doubleValue] >= [b doubleValue]? a: b;
}
@end

