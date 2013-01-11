//
//  WFMarkov.h
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import <Foundation/Foundation.h>

// Chiefly ported from http://blog.figmentengine.com/2008/10/markov-chain-code.html
// I have NO idea how efficient (or not) this is

@interface WFMarkovLink : NSObject {
    NSString *linkData;
    NSUInteger count;
    NSMutableDictionary *links;
}
@property (readonly) NSUInteger occurrences;
@property (readonly) NSString *linkData;
@end


// these are here since the original implementation used C# iterators.
typedef void(^WFMarkovFollowerEnumeration)(WFMarkovLink *link, NSUInteger idx, BOOL *keepGoing);
typedef void(^WFMarkovSequenceEnumeration)(NSString *part, NSUInteger idx, BOOL *keepGoing);

@interface WFMarkovChain : NSObject {
    WFMarkovLink *root;
    NSUInteger length;
}
+ (instancetype)chainWithInput:(NSArray *)input length:(NSUInteger)someLength;
- (void)generateLazilySequence:(WFMarkovSequenceEnumeration)enumeration
                       startAt:(NSString *)start
                           max:(NSUInteger)max;
- (void)generateLazilySequence:(WFMarkovSequenceEnumeration)enumeration
                           max:(NSUInteger)max;
@end
