//
//  FastString.h
//  sloto
//
//  Created by Andrei Ivanchikov on 11/4/13.
//  Copyright (c) 2013 Andrei Ivanchikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FastString : NSObject<NSCopying> {
    
}

- (id) initWithId:(int)Id andWithStr:(NSString*)str;

@property(nonatomic, readonly) int Id;
@property(nonatomic, readonly, strong) NSString* String;

+ (FastString*) Make:(NSString*)str;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (id)copyWithZone:(NSZone *)zone;

@end
