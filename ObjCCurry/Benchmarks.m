//
//  Benchmarks.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.31..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "Benchmarks.h"
#import "Function.h"

static const NSInteger kCount = 2000000;

extern double getCPUTime();



// ------------------------ NON-ID ARGUMENT -----------------------------

id Fptr_NonIdArg_Test(NSInteger x) {
    return nil;
}

@interface Method_NonIdArg : NSObject
@end

@implementation Method_NonIdArg
- (id)test:(NSInteger)x {
    return nil;
}
@end

id (^Block_NonIdArg_Test)(NSInteger) = ^id(NSInteger x) {
    return nil;
};


void NonIdArgBenchmark() {
    double start = 0;
    double end = 0;
    double tfobj = 0;
    double tplain = 0;
    
    // C-style function
    Function* fptrTest = [Function fromPointer:Fptr_NonIdArg_Test objCTypes:FPTR_SIG(id, NSInteger)];
    id result = nil;
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [fptrTest :@-1];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    NSLog(@"[NonIdArg] fptr - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        result = Fptr_NonIdArg_Test(-1);
    }
    end = getCPUTime();
    tplain = end - start;
    NSLog(@"[NonIdArg] fptr - plain: %f", 1000*tplain);
    NSLog(@"[NonIdArg] fptr fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // ObjC method
    Method_NonIdArg* dummy = [Method_NonIdArg new];
    Function* methodTest = [Function fromTarget:dummy selector:@selector(test:)];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [methodTest :@-1];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[NonIdArg] selector - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [dummy test:-1];
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[NonIdArg] selector - plain: %f", 1000*tplain);
    NSLog(@"[NonIdArg] selector fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // block
    Function* blockTest = [Function fromBlock:Block_NonIdArg_Test];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [blockTest :@-1];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[NonIdArg] block - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = Block_NonIdArg_Test(-1);
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[NonIdArg] block - plain: %f", 1000*tplain);
    NSLog(@"[NonIdArg] block fobj/plain = %f", tfobj/tplain);
}



// ------------------------ NON-ID RETVAL -----------------------------

NSInteger Fptr_NonIdRetval_Test(id x) {
    return -1;
}

@interface Method_NonIdRetval : NSObject
@end

@implementation Method_NonIdRetval
- (NSInteger)test:(id)x {
    return -1;
}
@end

NSInteger (^Block_NonIdRetval_Test)(id) = ^NSInteger(id x) {
    return -1;
};


void NonIdRetvalBenchmark() {
    double start = 0;
    double end = 0;
    double tfobj = 0;
    double tplain = 0;
    
    // C-style function
    Function* fptrTest = [Function fromPointer:Fptr_NonIdRetval_Test objCTypes:FPTR_SIG(NSInteger, id)];
    NSInteger result = 0;
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [[fptrTest :nil] integerValue];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[NonIdRetval] fptr - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        result = Fptr_NonIdRetval_Test(nil);
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[NonIdRetval] fptr - plain: %f", 1000*tplain);
    NSLog(@"[NonIdRetval] fptr fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // ObjC method
    Method_NonIdRetval* dummy = [Method_NonIdRetval new];
    Function* methodTest = [Function fromTarget:dummy selector:@selector(test:)];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [[methodTest :nil] integerValue];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[NonIdRetval] selector - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [dummy test:nil];
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[NonIdRetval] selector - plain: %f", 1000*tplain);
    NSLog(@"[NonIdRetval] selector fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // block
    Function* blockTest = [Function fromBlock:Block_NonIdRetval_Test];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [[blockTest :nil] integerValue];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[NonIdRetval] block - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = Block_NonIdRetval_Test(nil);
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[NonIdRetval] block - plain: %f", 1000*tplain);
    NSLog(@"[NonIdRetval] block fobj/plain = %f", tfobj/tplain);
}




// ------------------------ FAST LANE -----------------------------

id Fptr_FastLane_Test(id x) {
    return x;
}

@interface Method_FastLane : NSObject
@end

@implementation Method_FastLane
- (id)test:(id)x {
    return x;
}
@end

id (^Block_FastLane_Test)(id) = ^id(id x) {
    return x;
};


void FastLaneBenchmark() {
    double start = 0;
    double end = 0;
    double tfobj = 0;
    double tplain = 0;
    
    // C-style function
    Function* fptrTest = [Function fromPointer:Fptr_FastLane_Test objCTypes:FPTR_SIG(id, id)];
    id result = nil;
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [fptrTest :nil];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[FastLane] fptr - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        result = Fptr_FastLane_Test(nil);
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[FastLane] fptr - plain: %f", 1000*tplain);
    NSLog(@"[FastLane] fptr fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // ObjC method
    Method_FastLane* dummy = [Method_FastLane new];
    Function* methodTest = [Function fromTarget:dummy selector:@selector(test:)];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [methodTest :nil];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[FastLane] selector - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [dummy test:nil];
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[FastLane] selector - plain: %f", 1000*tplain);
    NSLog(@"[FastLane] selector fobj/plain = %f", tfobj/tplain);
    
    sleep(1);
    
    
    // block
    Function* blockTest = [Function fromBlock:Block_FastLane_Test];
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = [blockTest :nil];
        }
    }
    end = getCPUTime();
    tfobj = end - start;
    
    NSLog(@"[FastLane] block - function object: %f", 1000*tfobj);
    
    sleep(1);
    
    
    start = getCPUTime();
    for (NSUInteger i = 0; i < kCount; ++i) {
        @autoreleasepool {
            result = Block_FastLane_Test(nil);
        }
    }
    end = getCPUTime();
    tplain = end - start;
    
    NSLog(@"[FastLane] block - plain: %f", 1000*tplain);
    NSLog(@"[FastLane] block fobj/plain = %f", tfobj/tplain);
}
