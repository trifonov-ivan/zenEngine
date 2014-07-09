//
//  IDataHolder.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IDataHolder<NSObject>

- (Class) DataType;
- (NSObject*) DataObject;

@end

@interface ComponentsDataHolder : NSObject<IDataHolder>

@property (nonatomic, retain) NSObject* Data;

- (id) initWithData:(NSObject*)Data;

- (Class) DataType;
- (NSObject*) DataObject;

@end
