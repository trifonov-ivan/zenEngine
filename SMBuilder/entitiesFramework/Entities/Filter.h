//
//  Filter.h
//  cocos2d-ios
//
//  Created by Andrei Ivanchikov on 11/4/13.
//
//

#import <Foundation/Foundation.h>

@interface Filter : NSObject<NSCopying> {
}

@property(nonatomic, assign) unsigned long long Mask;

- (id) initWithMask:(unsigned long long) aMask;

- (BOOL)isEqual:(id)object;

- (NSUInteger)hash;

@end
