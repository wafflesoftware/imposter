//
//  WFMarkov.m
//  Imposter
//
//  Created by Jesper on 2013-01-09.
//  Copyright (c) 2013 Jesper. All rights reserved.
//

#import "WFMarkov.h"

@implementation WFMarkovLink
- (id)initWithLinkData:(NSString *)someLinkData {
    self = [super init];
    if (self) {
        linkData = someLinkData;
        links = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)linkWithData:(NSString *)someLinkData {
    WFMarkovLink *link = [[self alloc] initWithLinkData:someLinkData];
    return link;
}

- (void)processInput:(NSArray *)input length:(NSUInteger)length {
    NSMutableArray *window = [NSMutableArray arrayWithCapacity:length];
    for (NSString *part in input) {
        if (window.count == length) {
            [window removeObjectAtIndex:0];
        }
        [window addObject:part];
        
        [self processWindow:window];
    }
}

- (void)processWindow:(NSArray *)window {
    WFMarkovLink *link = self;
    
    for (NSString *part in window) {
        link = [link process:part];
    }
}

- (WFMarkovLink *)process:(NSString *)part {
    WFMarkovLink *link = [self findFollower:part];
    
    if (link == nil) {
        link = [WFMarkovLink linkWithData:part];
        [links setObject:link forKey:part];
    }
    
    [link seen];
    
    return link;
}

- (void)seen {
    count++;
}

- (NSString *)linkData {
    return linkData;
}

- (NSUInteger)occurrences {
    return count;
}

- (NSUInteger)childOccurrences {
    int result = 0;
    for (WFMarkovLink *link in links.allValues) {
        result += link.occurrences;
    }
    
    return result;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ x%ld>", NSStringFromClass(self.class), linkData, (unsigned long)count];
}

- (WFMarkovLink *)findFollower:(NSString *)follower {
    WFMarkovLink *link = links[follower];
    return link;
}


- (WFMarkovLink *)selectRandomLink {
    
    WFMarkovLink *link = nil;
    NSUInteger universe = self.childOccurrences;
    
    NSUInteger lowerBound = 1;
    NSUInteger upperBound = universe + 1;
    
    if (lowerBound == upperBound) return links.allValues.lastObject;
    
    NSUInteger rnd = lowerBound + arc4random() % (upperBound - lowerBound);
    
    NSUInteger total = 0;
    for (WFMarkovLink *child in links.allValues) {
        total += child.occurrences;
        
        if (total >= rnd) {
            link = child;
            break;
        }
    }
    
    return link;
}

- (WFMarkovLink *)findLink:(NSMutableArray *)window {
    WFMarkovLink *link = self;
    
    for (NSString *part in window) {
        link = [link findFollower:part];
        
        if (link == nil)
            break;
    }
    
    return link;
}

- (void)generateLazilyFollowers:(WFMarkovFollowerEnumeration)enumeration
                        startAt:(NSString *)start
                         length:(NSUInteger)length max:(NSUInteger)max {
    NSMutableArray *window = [NSMutableArray arrayWithCapacity:length];
    [window addObject:start];
    
    WFMarkovLink *link = nil;
    
    NSUInteger idx = 0;
    for (link = [self findLink:window]; link != nil && max != 0; link = [self findLink:window], max--) {
        WFMarkovLink *next = [link selectRandomLink];
        
        __block BOOL keepGoing = YES;
        enumeration(next, idx, &keepGoing);
        idx++;
        if (keepGoing == NO) return;
        
        if (window.count == length - 1) {
            [window removeObjectAtIndex:0];
        }
        if (next != nil) {
            [window addObject:next.linkData];
        }
    }
}

@end






@implementation WFMarkovChain
- (id)initWithInput:(NSArray *)input length:(NSUInteger)someLength
{
    self = [super init];
    if (self) {
        root = [WFMarkovLink linkWithData:nil];
        length = someLength;
        [root processInput:input length:someLength];
    }
    return self;
}

+ (instancetype)chainWithInput:(NSArray *)input length:(NSUInteger)someLength {
    WFMarkovChain *chain = [[self alloc] initWithInput:input length:someLength];
    return chain;
}

- (void)generateLazilySequence:(WFMarkovSequenceEnumeration)enumeration
                       startAt:(NSString *)start
                           max:(NSUInteger)max {
    [root generateLazilyFollowers:^(WFMarkovLink *link, NSUInteger idx, BOOL *keepGoing) {
        enumeration(link.linkData, idx, keepGoing);
    } startAt:start length:length max:max];
}

- (void)generateLazilySequence:(WFMarkovSequenceEnumeration)enumeration
                           max:(NSUInteger)max {
    [self generateLazilySequence:enumeration
                         startAt:[root selectRandomLink].linkData
                             max:max];
}

@end









