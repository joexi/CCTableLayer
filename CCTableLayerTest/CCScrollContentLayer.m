//
//  PAScrollContentLayer.m
//  EOW
//
//  Created by apple on 12-7-17.
//  Copyright (c) 2012年 Jason Zhang. All rights reserved.
//

#import "CCScrollContentLayer.h"

@implementation CCScrollContentLayer
@synthesize delegate = _delegate;
- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}


- (void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    if([_delegate respondsToSelector:@selector(contentLayerDidMove)])
    {
        [_delegate performSelector:@selector(contentLayerDidMove)];
    }
}

- (void)dealloc
{
    [super dealloc];
}
@end
