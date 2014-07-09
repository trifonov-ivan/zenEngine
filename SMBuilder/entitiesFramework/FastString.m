//
//  FastString.m
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "FastString.h"

static NSMutableDictionary* stringsCollection = nil;
static int lastStringId = 0;

@implementation FastString

- (id) initWithId:(int)Id andWithStr:(NSString*)str {
    if ((self = [super init])) {
        if (stringsCollection == nil) {
            @synchronized (self) {
                if (stringsCollection == nil) {
                    stringsCollection = [[NSMutableDictionary alloc] init];
                }
            }
        }
        _Id = Id;
        _String = str;
    }
    
    return self;
}

+ (FastString*) Make:(NSString*)str {
    FastString* fs = nil;
    
    if (str != nil) {
        @synchronized(stringsCollection) {
            fs = (FastString*)[stringsCollection objectForKey:str];
            if (fs == nil) {
                fs = [[FastString alloc] initWithId:lastStringId andWithStr:str];
                [stringsCollection setObject:fs forKey:str];
                lastStringId++;
            }
        }
    }
    
    return fs;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[FastString class]]) {
        FastString* fs = (FastString*)object;
        return fs.Id == self.Id;
    }
    
    return false;
}

- (NSUInteger)hash {
    return self.Id;
}

- (id)copyWithZone:(NSZone *)zone {
    FastString* fs = [[[self class] allocWithZone:zone] initWithId:self.Id andWithStr:self.String];
    return fs;
}

@end
