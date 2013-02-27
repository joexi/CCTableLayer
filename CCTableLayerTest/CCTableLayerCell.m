//
//  CCTableLayerCell.m
//  cocos2d
//
//  Created by apple on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCTableLayerCell.h"

@implementation CCTableLayerCell
@synthesize isSelected = _isSelected;
@synthesize index = _index;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize isTouchDown = _isTouchDown;

- (id)initWithReuseIdentifier:(NSString *)identifier;
{
    self = [self initWithColor:ccc4(0, 0, 0, 0)];
    if(self)
    {
        _isSelected = NO;
        _reuseIdentifier = [identifier retain];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
}


- (id)init
{
    self = [self initWithColor:ccc4(0, 0, 0, 0)];
    if(self)
    {
        _isSelected = NO;
    }
    return self;
}

- (void)resetCell
{
    
}

- (void)touchDown
{
    _isTouchDown = YES;
}

- (void)touchUp
{
    _isTouchDown = NO;
}


- (void)dealloc
{
    [_reuseIdentifier release];
    [super dealloc];
}
#pragma mark - 重写opacity方法
//add by david 12/11/16
- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		squareColors_[i].r = color_.r;
		squareColors_[i].g = color_.g;
		squareColors_[i].b = color_.b;
		squareColors_[i].a = opacity_;
	}
}

-(void) setOpacity: (GLubyte) opacity
{
    for( CCNode *node in [self children] )
    {
        if( [node conformsToProtocol:@protocol( CCRGBAProtocol)] )
        {
            if (opacity == 0) {
                return;
            }
            [(id<CCRGBAProtocol>) node setOpacity: opacity];
        }
    }
    opacity_ = opacity;
	[self updateColor];
}

- (void)draw
{
//    [super draw];
}

@end
