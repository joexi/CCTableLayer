//
//  CCTableLayer.m
//  cocos2d
//
//  Created by apple on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCTableLayer.h"
@interface CCTableLayer (Provate)
- (void)addFromBelow;
- (void)addFromTop;
- (void)removeFromTop;
- (void)removeFromBelow;
@end
@implementation CCTableLayer
@dynamic delegate;
@synthesize dataSource = _dataSource;


- (id)init
{
    self = [super init];
    if(self)
    {
        _heightAry = [[NSMutableArray alloc]init];
        _cellAry = [[NSMutableArray alloc]init];
        _positionAry = [[NSMutableArray alloc]init];
        _freeCells = [[NSMutableArray alloc]init];
        _nullCell = [[CCTableLayerCell alloc]init];
        _xEnable = NO;
        _endIndex = -1;
    }
    return self;
}

- (void)initialize
{
    [_positionAry removeAllObjects];
    [_cellAry removeAllObjects];
    [_heightAry removeAllObjects];
    int cellCount = [_dataSource tableLayer:self numberOfRowsInSection:0];
    CGFloat contentHeight = 0.f;
    for (int i = 0; i<cellCount; i++) //获取高度数组
    {
        CGFloat height = [self.delegate tableLayer:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        contentHeight += height;
        [_heightAry addObject:[NSNumber numberWithFloat:height]];
    }
    CGFloat tempHeight = MAX(contentHeight, self.contentSize.height);
    for(NSNumber *height in _heightAry) 
    {
        tempHeight -= [height floatValue];
        [_positionAry addObject:[NSNumber numberWithFloat:tempHeight]];
        [_cellAry addObject:_nullCell]; 
    }    
    _contentLayer.contentSize = CGSizeMake(self.contentSize.width, MAX(contentHeight, self.contentSize.height));
}

- (void)resetCellInfo
{
    [_positionAry removeAllObjects];
    [_heightAry removeAllObjects];
    int cellCount = [_dataSource tableLayer:self numberOfRowsInSection:0];
    CGFloat contentHeight = 0.f;
    for(int i = 0; i<cellCount; i++) //获取高度数组
    {
        CGFloat height = [self.delegate tableLayer:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        contentHeight += height;
        [_heightAry addObject:[NSNumber numberWithFloat:height]];
    }
    CGFloat tempHeight = MAX(contentHeight, self.contentSize.height);
    for(NSNumber *height in _heightAry) 
    {
        tempHeight -= [height floatValue];

        [_positionAry addObject:[NSNumber numberWithFloat:tempHeight]];
    }
    _contentLayer.contentSize = CGSizeMake(self.contentSize.width, MAX(contentHeight, self.contentSize.height));
}
- (void)setDataSource:(id<CCTableLayerDataSource>)dataSource
{
    _dataSource = dataSource;
    if(self.delegate)
    {
        [self initialize];
        [self scrollToTop:NO];
    }
}

- (void)setDelegate:(id<CCTableLayerDelegate>)delegate
{
    _delegate = delegate;
    if(_dataSource)
    {
        [self initialize];
        [self scrollToTop:NO];
    }
}


- (void)dealloc
{
    [_nullCell release];
    [_positionAry release];
    [_freeCells release];
    [_cellAry release];
    [_heightAry release];
    [super dealloc];
}
#pragma mark - 内部工具方法


- (CGFloat)getPositionWithIndex:(int)index
{
    return [[_positionAry objectAtIndex:index]floatValue] - [[_heightAry objectAtIndex:index]floatValue];
}

- (int)indexOfPosition:(CGPoint)position
{
    int index = 0;
    CGFloat height = 0;
    while (position.y>= height) 
    {
        if(_heightAry.count <= index)
        {
            index = -1;
            break;
        }
        height += [[_heightAry objectAtIndex:index]floatValue];
        index++;
    }
    return index - 1;
}

- (int)indexOfTouchLocation:(CGPoint)position
{
    int index = 0;
    CGFloat height = 0;
    while (position.y + _contentOffset.y >= height) 
    {
        if(_heightAry.count <= index)
        {
            index = -1;
            break;
        }
        height += [[_heightAry objectAtIndex:index]floatValue];
        index++;
    }
    return index - 1;
}

- (void)insertEnd:(CCTableLayerCell *)cell
{
    [_contentLayer reorderChild:cell z:[_cellAry indexOfObject:cell]];
}

- (BOOL)hasEventSliderOccurred:(CGPoint)touchPoint
{
    if(abs(touchPoint.x - _beginPoint.x) > 50 && abs(touchPoint.y - _beginPoint.y) < 10)
    {
        return YES;
    }
    return NO;
}
#pragma mark - contentLayer delegate
- (void)contentLayerDidMove
{
    [super contentLayerDidMove];
    [self checkValidCell];
}
//添加cell

- (CCTableLayerCell *)addCellAtIndex:(int)index       
{
    CCTableLayerCell *cell = [self.dataSource tableLayer:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.index = index;
    CGFloat height = [[_heightAry objectAtIndex:index]floatValue];
    CGFloat yPosition = [[_positionAry objectAtIndex:index] floatValue];
    cell.position = ccp(0, yPosition);
    cell.contentSize = CGSizeMake(self.contentSize.width, height);
    [_contentLayer addChild:cell z:index];
    [_cellAry replaceObjectAtIndex:index withObject:cell];
    return cell;
}
//释放cell
- (void)releaseCellAtIndex:(int)index   
{
    CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
    [cell removeFromParentAndCleanup:YES];
    cell.isSelected = NO;
    [cell resetCell];
    [_freeCells addObject:cell];
    [_cellAry replaceObjectAtIndex:index withObject:_nullCell];
}
//释放不显示的cell
- (void)releaseUnusedCell
{
    for(int index = 0; index < _cellAry.count; index++)
    {
        CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        CGFloat height = [[_heightAry objectAtIndex:index]floatValue];
        if((yPosition + height < _contentLayer.contentSize.height - _contentOffset.y - self.contentSize.height || yPosition > _contentLayer.contentSize.height - _contentOffset.y) && ![cell isEqual:_nullCell])
        {
            [self releaseCellAtIndex:index];
        }
    }
}
//添加新cell
- (void)addNewCell          
{
    for(int index = 0; index < _cellAry.count; index++)
    {
        CCTableLayerCell *cell = [_cellAry objectAtIndex:index];
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        CGFloat height = [[_heightAry objectAtIndex:index]floatValue];
        if(yPosition + height >= _contentLayer.contentSize.height - _contentOffset.y - self.contentSize.height && yPosition <= _contentLayer.contentSize.height - _contentOffset.y && [cell isEqual:_nullCell])
        {
            [self addCellAtIndex:index];
        }
    }
}

- (void)checkValidCell
{
    if(_isReuse)//如果开启了cell的重用
    {
        [self releaseUnusedCell];   //释放不用的cell
    }
        [self addNewCell];          //添加需要显示的cell;
    
}


- (CGPoint)convertToVisableFrame:(CGPoint)point
{
    point = [[CCDirector sharedDirector] convertToGL:point];
    point = [self convertToNodeSpace:point];
    point.y = self.contentSize.height - point.y;
    return  point;
}

#pragma mark - 对外接口
- (void)scrollToIndex:(int)index animated:(BOOL)animated
{
    CGFloat indexPosition = 0;
    for(int i = 0;i < index;i++)
    {
        indexPosition += [[_heightAry objectAtIndex:i]floatValue];
    }
    
    if(indexPosition > _contentLayer.contentSize.height - self.contentSize.height)
    {
        indexPosition = _contentLayer.contentSize.height - self.contentSize.height;
    }
    [self setContentOffset:CGPointMake(0, indexPosition) animated:animated];
}

- (CCTableLayerCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    _isReuse = YES;
    for(CCTableLayerCell *cell in _freeCells)
    {
        if([cell.reuseIdentifier isEqualToString:identifier])
        {
            [cell retain];
            [_freeCells removeObject:cell];
            return [cell autorelease];
        }
    }
    return nil;
}

- (CCTableLayerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_cellAry.count <= indexPath.row)
    {
        return nil;
    }
    return [_cellAry objectAtIndex:indexPath.row];
}

- (void)insertRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation
{
    CGFloat height = _contentLayer.contentSize.height;
    [self resetCellInfo];
    [self setContentOffset:_contentOffset animated:NO];
    //填充空cell
    for(int index = range.location;index < range.location + range.length; index++)
    {
        [_cellAry insertObject:_nullCell atIndex:index];
    }
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        if(yPosition - cell.position.y != _contentLayer.contentSize.height - height)
        {
            [cell stopAllActions];
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:ccp(0, yPosition)];
            move.tag = 1;
            [cell runAction:move];
        }
        else {
            cell.position = ccp(0, yPosition);
        }
        
    }
    for(int index = range.location;index < range.location + range.length; index++)
    {
        CCTableLayerCell *cell = [self addCellAtIndex:index];
        cell.index = index;
        [_contentLayer reorderChild:cell z:-1];
        if(range.location > 0)
        {
            cell.position = ccp(0, [[_positionAry objectAtIndex:range.location - 1]floatValue]);
        }
        else {
            cell.position = ccp(0, [[_positionAry objectAtIndex:range.location]floatValue]);
        }
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:ccp(0, yPosition)];
        CCCallFuncN *insertEnd = [CCCallFuncN actionWithTarget:self selector:@selector(insertEnd:)];
        CCSequence *sequence = [CCSequence actions:move, insertEnd, nil];
        [cell runAction:sequence];
    }
    for(int index = range.location + range.length; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        [cell stopAllActions];
        cell.position = ccp(0, cell.position.y - height + _contentLayer.contentSize.height);
        destination.y = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        move.tag = 1;
        [cell runAction:move];
    }
}



- (void)deleteRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation
{
    CGFloat height = _contentLayer.contentSize.height;
    [self resetCellInfo];
    //填充空cell
    for(int index = range.location;index < range.location + range.length; index++)
    {
        [self releaseCellAtIndex:index];
    }
//    [self setContentOffset:_contentOffset animated:NO];
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        
        cell.position = ccp(0, yPosition);
    }
    [_cellAry removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    for(int index = range.location; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        cell.position = ccp(0, cell.position.y - height + _contentLayer.contentSize.height);
        destination.y = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        [cell runAction:move];
    }
    [self setContentOffset:_contentOffset animated:NO];
    
}

- (void)reloadRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation
{
    CGFloat height = _contentLayer.contentSize.height;
    [self resetCellInfo];
    [self setContentOffset:_contentOffset animated:NO];
    for(int index = 0;index < range.location; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGFloat yPosition = [[_positionAry objectAtIndex:index]floatValue];
        [cell stopAllActions];
        cell.position = ccp(0, yPosition);
    }
    for(int index = range.location;index < range.location + range.length; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        if(![cell isEqual:_nullCell])
        {
            [self releaseCellAtIndex:index];
            [self addCellAtIndex:index];
        }
    }
    for(int index = range.location + range.length; index<_cellAry.count; index++)
    {
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.index = index;
        CGPoint destination = CGPointZero;
        cell.position = ccp(0, cell.position.y - height + _contentLayer.contentSize.height);
        destination.y = [[_positionAry objectAtIndex:index]floatValue];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:destination];
        [cell runAction:move];
    }
}

- (void)reloadData
{
    [_contentLayer removeAllChildrenWithCleanup:YES];
    [_contentLayer stopAllActions];
    [_cellAry removeAllObjects];
    [_freeCells removeAllObjects];
    [_heightAry removeAllObjects];
    [_positionAry removeAllObjects];
    _beginIndex = -1;
    _endIndex = -1;
    _contentOffset = CGPointZero;
    [self initialize];
    [self scrollToTop:NO];
}
#pragma mark -
#pragma mark - dynamic cell processing

#pragma mark - touch
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:touch.view];
    point = [self convertToVisableFrame:point];
    
    if([super ccTouchBegan:touch withEvent:event])
    {
        
        int index = [self indexOfTouchLocation:point];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        CCTableLayerCell *cell = [self cellForRowAtIndexPath:indexPath];
    
        if(!self.isDecelerating)
        {
            [cell touchDown];//播放按下动画
        }
        if([_delegate respondsToSelector:@selector(tableLayer:cellTouchDownAtIndexPath:)])
        {
            [_delegate performSelector:@selector(tableLayer:cellTouchDownAtIndexPath:) withObject:self withObject:indexPath];
        }
        return YES;
    }
    return NO;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    [_contentLayer stopAllActions];
    CGPoint point = [touch locationInView:touch.view];
    CGPoint oriPoint = point;
    [super ccTouchMoved:touch withEvent:event];
    if(![super isTouchInside:point])
    {
        return;
    }
    point = [self convertToVisableFrame:point];
    int index = [self indexOfTouchLocation:point];
    for(CCTableLayerCell *cell in _cellAry)//效率有待优化
    {
        if(cell.isTouchDown)
        {
            [cell touchUp];
        }
    }
    if(abs(oriPoint.x - _beginPoint.x) > 50 && abs(oriPoint.y - _beginPoint.y) < 10)
    {
        if(index >= 0 && [_delegate respondsToSelector:@selector(tableLayer:cellNeedDelete:)])
        {
            CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [self.delegate tableLayer:self cellNeedDelete:cell];
        }
    }
}



- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL isDragging = _isDragging;
    [super ccTouchEnded:touch withEvent:event];
    CGPoint point = [touch locationInView:touch.view];
    if(![super isTouchInside:point])
    {
//        [super ccTouchEnded:touch withEvent:event];
        return;
    }
   
    point = [self convertToVisableFrame:point];
    
    int index = [self indexOfTouchLocation:point];
    if(index >= 0 && !isDragging && !self.isDecelerating)
    {
        if([self.delegate respondsToSelector:@selector(tableLayer:didSelectRowAtIndexPath:)] && index>=0 && index<_cellAry.count)
        {
            //设置是否点击
            for(CCTableLayerCell *cell in _cellAry)
            {
                cell.isSelected = NO;
            }
            CCTableLayerCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            cell.isSelected = YES;
            [cell touchUp];
            [self.delegate tableLayer:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    
}
@end
