//
//  CCScrollLayer.m
//  cocos2d
//
//  Created by apple on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCScrollLayer.h"
#import "cocos2d.h"


@interface CCScrollLayer(Private)
- (void)contentLayerMoveTo:(CGPoint)point;
@end

@implementation CCScrollLayer
@synthesize scrollEnabled = _scrollEnabled;
@synthesize contentOffset = _contentOffset;
@synthesize xEnable = _xEnable;
@synthesize yEnable = _yEnable;
@synthesize delegate = _delegate;
@synthesize contentLayer = _contentLayer;
@synthesize decelerateEnable = _decelerateEnable;
@synthesize touchPoint = _beginPoint;
@synthesize priority = _priority;
@synthesize pagedScroller = _pagedScroller;
@synthesize isDecelerating = _isDecelerating;
- (id)init
{
    self = [super init];
    if(self)
    {
        self.contentLayer = [[[CCScrollContentLayer alloc]init]autorelease];
        self.contentLayer.delegate = self;
        _scrollEnabled = YES;
        _xEnable = YES;
        _yEnable = YES;
        _decelerateEnable = YES;
        
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    [self resetContentOffset];
}

- (void)onEnter
{
    [super onEnter];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:_priority swallowsTouches:YES];
}

- (void)onExit
{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}



- (void)setContentLayer:(CCScrollContentLayer *)contentLayer
{
    if(_contentLayer != contentLayer)
    {
        [_contentLayer removeFromParentAndCleanup:YES];
        [_contentLayer release];
        _contentLayer = [contentLayer retain];
        _contentLayer.delegate = self;
        [self addChild:_contentLayer];
    }
}

- (void)setNeedsDisplay
{
    [self scrollToTop:NO];
}

- (void)visit
{
    glPushMatrix();
    glEnable(GL_SCISSOR_TEST);
    glScissor([self convertToWorldSpace:CGPointZero].x * CC_CONTENT_SCALE_FACTOR(),
              [self convertToWorldSpace:CGPointZero].y * CC_CONTENT_SCALE_FACTOR(),
              self.contentSizeInPixels.width,
              self.contentSizeInPixels.height);
    [super visit];
    glDisable(GL_SCISSOR_TEST);
    glPopMatrix();
}

- (void)contentLayerMoveTo:(CGPoint)point
{
    CCMoveTo *acMove =  [CCMoveTo actionWithDuration:0.5
                                            position:point];
    CCEaseOut *acSpeed = [CCEaseOut actionWithAction:acMove
                                                rate:2];
    CCCallFuncN *acBack =  [CCCallFuncN actionWithTarget:self
                                                selector:@selector(deceleratingDidEnd:)];
    CCSequence *sequence = [CCSequence actions:acSpeed,acBack,nil];
    [_contentLayer runAction:sequence];
}

#pragma mark - content delegate
- (void)contentLayerDidMove
{
    [self resetContentOffset];
    if([_delegate respondsToSelector:@selector(scrollLayerDidScroll:)] && self.parent)
    {
        [_delegate scrollLayerDidScroll:self];
    }
}
#pragma mark - scroll
- (void)resetContentOffset
{
    _contentOffset = CGPointMake(-_contentLayer.position.x,
                                 _contentLayer.position.y + 
                                 _contentLayer.contentSize.height - self.contentSize.height);
}

- (CGPoint)convertPointToValid:(CGPoint)point
{
    CGPoint screenEdge = CGPointMake(_contentLayer.contentSize.width - self.contentSize.width, 
                                     _contentLayer.contentSize.height - self.contentSize.height);
    if(point.y > 0)
    {
        point.y = 0;
    }
    else if(point.y < -screenEdge.y)
    {
        point.y = -screenEdge.y;
    }
    if(point.x > 0)
    {
        point.x = 0;
    }
    else if(point.x < -screenEdge.x)
    {
        point.x = -screenEdge.x;
    }
    
    return point;
}

- (void)scrollToValidFrame
{
    CGPoint toPoint = _contentLayer.position;
    
    toPoint  = [self convertPointToValid:toPoint];
    if(CGPointEqualToPoint(_contentLayer.position, toPoint))
    {
        return;//拖动层在合理位置不需要矫正时直接返回
    }
    CCMoveTo *action = [CCMoveTo actionWithDuration:0.1 position:toPoint];
    CCCallFuncN *callBack = [CCCallFuncN actionWithTarget:self selector:@selector(deceleratingDidEnd:)];
    CCSequence *sequence = [CCSequence actions:action,callBack, nil];
    [_contentLayer runAction:sequence];
}

- (void)scrollToPage:(int)page
{
    if(_xEnable)
    {
        CGFloat offsetX = page * self.contentSize.width;
        [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    else if(_yEnable)
    {
        CGFloat offsetY = page * self.contentSize.width;
        [self setContentOffset:CGPointMake(offsetY, 0) animated:YES];
    }
}

- (void)scrollToPage
{
    int withOffset = (int)_contentOffset.x% (int)self.contentSize.width;
    int page = (int)(_contentOffset.x/self.contentSize.width);
    if(withOffset > self.contentSize.width/2)
    {
        page++;
    }
    if(_contentLayer.contentSize.width >= (page + 1) * self.contentSize.width)
    {
        [self scrollToPage:page];
    }
    else {
        [self scrollToValidFrame];
    }
}

- (void)scrollToEnd:(BOOL)animated
{
    CGFloat offsetY = MAX(_contentLayer.contentSize.height - self.contentSize.height, 0);
    CGFloat offsetX = MAX(_contentLayer.contentSize.width - self.contentSize.width, 0);
    [self setContentOffset:CGPointMake(offsetX, offsetY) animated:animated];
}

- (void)scrollToTop:(BOOL)animated
{
    [self setContentOffset:CGPointZero animated:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [self setContentOffset:contentOffset 
                  animated:animated 
              withDuration:kDefaultRowDuration];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated withDuration:(NSTimeInterval)duration
{
    
    CGPoint toPoint = CGPointMake(-contentOffset.x,
                                  contentOffset.y + 
                                  self.contentSize.height - 
                                  _contentLayer.contentSize.height);
    if(animated)
    {
        CCMoveTo *action = [CCMoveTo actionWithDuration:duration position:toPoint];
        CCCallFunc *callBack = [CCCallFunc actionWithTarget:self selector:@selector(deceleratingDidEnd:)];
        CCSequence *sequence = [CCSequence actions:action,callBack, nil];
        [_contentLayer runAction:sequence];
    }
    else
    {
        [self resetContentOffset];
        _contentLayer.position = toPoint;
        [self scrollToValidFrame];
    }
}

#pragma mark - touch
- (BOOL)isTouchInside:(CGPoint)point
{
    point = [[CCDirector sharedDirector] convertToGL:point];
    point = [[self parent] convertToNodeSpace:point];
    if(!_scrollEnabled || !CGRectContainsPoint([self boundingBox],point ))
    {
        return NO;
    }
    return YES;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:touch.view];
    if(![self isTouchInside:point])
    {
        return NO;
    }
    _isDecelerating = NO;
    [_contentLayer stopAllActions];
    _beginTime = touch.timestamp;
    _beginPoint = point;
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint point = [touch locationInView:touch.view];
    CGPoint perpoint = [touch previousLocationInView:touch.view];
    if(![self isTouchInside:point])
    {
        if(_pagedScroller)
        {
            [self scrollToPage];
        }
        else 
        {
            [self scrollToValidFrame];
        }
        return;
    }
    _isDragging = YES;
    CGPoint toPoint = CGPointMake(_xEnable?
                                  _contentLayer.position.x + point.x - perpoint.x:
                                  _contentLayer.position.x,
                                  _yEnable?
                                  _contentLayer.position.y - point.y + perpoint.y:
                                  _contentLayer.position.y);
    _contentLayer.position = toPoint;
    [self resetContentOffset];
    _lastMoveTime = touch.timestamp;
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint endPoint = [touch locationInView:touch.view];
    if(!_pagedScroller)
    {
        //处理滑动
        double dx  = endPoint.x - _beginPoint.x;
        double dy  = endPoint.y - _beginPoint.y;
        double vx = dx/(touch.timestamp - _beginTime);
        double vy = dy/(touch.timestamp - _beginTime);
        CGPoint toPoint = _contentLayer.position;
        BOOL decelerating = NO;
        if(vx > 100 || vx < -100)
        {
            toPoint.x += _xEnable?vx * 0.2:0;
            decelerating = _xEnable?YES:decelerating;
        }
        if(vy > 100 || vy < -100)
        {
            toPoint.y -= _yEnable?vy * 0.2:0;
            decelerating = _yEnable?YES:decelerating;
        }
        
        if(decelerating && _decelerateEnable)//可以滑动
        {
            _isDecelerating = YES;
            toPoint = [self convertPointToValid:toPoint];
            [self contentLayerMoveTo:toPoint];
            
            
        }
        else
        {
            [self scrollToValidFrame];
        }
        if([_delegate respondsToSelector:@selector(scrollLayerDidEndDragging:willDecelerate:)]
           && self.parent)
        {
            [_delegate scrollLayerDidEndDragging:self willDecelerate:decelerating && _decelerateEnable];
        }
    }
    else 
    {
        if(_xEnable)
        {
            [self scrollToPage];
        }
    }
    _isDragging = NO;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self scrollToValidFrame];
    if([_delegate respondsToSelector:@selector(scrollLayerDidEndDecelerating:)] && self.parent)
    {
        [_delegate scrollLayerDidEndDecelerating:self];
    }
}

- (void)deceleratingDidEnd:(CCLayer *)layer//滑动结束
{
    _isDecelerating = NO;
    [_contentLayer stopAllActions];
    if([_delegate respondsToSelector:@selector(scrollLayerDidEndDecelerating:)] && self.parent)
    {
        [_delegate scrollLayerDidEndDecelerating:self];
    }
    [self scrollToValidFrame];
}

- (void)dealloc
{
    [_contentLayer release];
    [super dealloc];
}

@end
