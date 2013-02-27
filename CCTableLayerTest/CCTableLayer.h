//
//  CCTableLayer.h
//  cocos2d
//
//  Created by apple on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCScrollLayer.h"
#import "CCTableLayerCell.h"
@class CCTableLayer;

@protocol CCTableLayerDelegate <CCScrollLayerDelegate>
- (CGFloat)tableLayer:(CCTableLayer *)tableLayer heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//配置单元格的高度
@optional
- (void)tableLayer:(CCTableLayer *)tableLayer didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableLayer:(CCTableLayer *)tableLayer cellNeedDelete:(CCTableLayerCell *)cell;
- (void)tableLayer:(CCTableLayer *)tableLayer cellTouchDownAtIndexPath:(NSIndexPath *)indexPath;
//单元格响应到用户点击时的事件回调
@end


@protocol CCTableLayerDataSource
- (NSInteger)tableLayer:(CCTableLayer *)tableLayer numberOfRowsInSection:(NSInteger)section;
//配置单元格的行数 
- (CCTableLayerCell *)tableLayer:(CCTableLayer *)tableLayer cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//配置具体的单元格，返回一个CCTableLayerCell类型的对象
@end


typedef enum
{
    CCTableLayerRowAnimationDefault,
}CCTableLayerRowAnimation;

@interface CCTableLayer : CCScrollLayer 
{
    id <CCTableLayerDataSource> _dataSource;
    NSMutableArray *_heightAry;                 //存储单元格高度
    NSMutableArray *_cellAry;                   //存储单元格
    NSMutableArray *_positionAry;               //存储单元格位置坐标
    NSMutableArray *_freeCells;                 //存储可重用的空闲单元格
    int _beginIndex;                            //目前显示的单元格的起始坐标
    int _endIndex;                              //目前显示的单元格的结束坐标
    BOOL _isReuse;                              //是否开启了重用
    CCTableLayerCell *_nullCell;
}

@property (nonatomic,assign) id <CCTableLayerDataSource> dataSource;
@property (nonatomic,assign) id <CCTableLayerDelegate> delegate;
- (CCTableLayerCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//根据index值获取单元格cell 

- (CCTableLayerCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
//通过id获取可重用的cell，返回为空时需要自己创建cell 

- (void)insertRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation;
//批量插入单元格，在插入之前需要修改数据源中单元格的总数量，否则会crash，和UITableView使用时一样。其中rang的location代表插入的地点，range的length代表插入的数量 

- (void)deleteRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation;
//批量删除，具体使用规则和插入一样 

- (void)reloadRowsInRange:(NSRange)range withRowAnimation:(CCTableLayerRowAnimation)animation;
//批量刷新单元格，具体使用规则和插入一样

- (void)scrollToIndex:(int)index animated:(BOOL)animated;
//使得列表滚动到指定的单元格索引 

- (void)reloadData;
//重新刷新列表的所有数据 

@end
