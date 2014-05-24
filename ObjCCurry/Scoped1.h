//
//  Scoped1.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.23..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef FN_MODULE
#define FN_MODULE Scoped1
#include "FCF.h"

@function(Cons, id, id);
