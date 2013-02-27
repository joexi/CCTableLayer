//
//  CCScrollLayer.h
//  cocos2d
//
//  Created by apple on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define kDefaultRowDuration 0.4

#import <UIKit/UIKit.h>
#include "cocos2d.h"
#import "CCScrollContentLayer.h"
@class CCScrollLayer;
@protocol CCScrollLayerDelegate <NSObject>

@optional

- (void)scrollLayerDidScroll:(CCScrollLayer *)scrollLayer;//view被拖动
- (void)scrollLayerDidEndDragging:(CCScrollLayer *)scrollLayer willDecelerate:(BOOL)decelerate;//view拖动结束
- (void)scrollLayerDidEndDecelerating:(CCScrollLayer *)scrollLayer;//view滑动结束
@end

@interface CCScrollLayer : CCLayer <CCScrollContentLayerDelegate>
{
    CCScrollContentLayer *_contentLayer;//拖动内容层
    CGPoint _beginPoint;//点击开始点
    CGPoint _contentOffset;//拖动层相对于自身的偏移量
    BOOL _xEnable;
    BOOL _yEnable;
    BOOL _isDragging;    //是否在拖动中
    BOOL _pagedScroller;
    BOOL _isDecelerating;
    BOOL _decelerateEnable;
    
    NSTimeInterval _lastMoveTime;//上次移动时间
    NSTimeInterval _beginTime;
    
    id <CCScrollLayerDelegate> _delegate;
    int _priority;
}
@property (nonatomic, assign) BOOL pagedScroller;
@property (nonatomic, assign) BOOL decelerateEnable;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, readonly) CGPoint contentOffset;//获取拖动视图相对于主视图的偏移量 
@property (nonatomic, assign) id <CCScrollLayerDelegate> delegate;
@property (nonatomic, assign) BOOL xEnable;//设置x轴是否可以拖动
@property (nonatomic, assign) BOOL yEnable;//设置y轴是否可以拖动
@property (nonatomic, assign) CCScrollContentLayer *contentLayer;
@property (nonatomic, readonly) CGPoint touchPoint;
@property (nonatomic, assign) int priority;
@property (nonatomic, assign) BOOL isDecelerating;
#pragma mark - init

#pragma mark - display
- (void)setNeedsDisplay;

#pragma mark - scroll
- (BOOL)isTouchInside:(CGPoint)point;
- (void)scrollToTop:(BOOL)animated;//滚动到最上方
- (void)scrollToEnd:(BOOL)animated;//滚动到最下方
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated withDuration:(NSTimeInterval)duration;
- (void)resetContentOffset;
@end
