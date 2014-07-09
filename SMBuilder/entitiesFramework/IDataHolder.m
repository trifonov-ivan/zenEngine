//
//  IDataHolder.m
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import "IDataHolder.h"

@implementation ComponentsDataHolder

- (id) initWithData:(NSObject*)Data {
    if ((self = [super init])) {
        self.Data = Data;
    }
    
    return self;
}

- (void) dealloc {
    self.Data = nil;
}

- (Class) DataType {
    return [_Data class];
}

- (NSObject*) DataObject {
    return self.Data;
}

@end
