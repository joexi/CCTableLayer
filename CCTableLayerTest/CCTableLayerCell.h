//
//  CCTableLayerCell.h
//  cocos2d
//
//  Created by apple on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
@interface CCTableLayerCell : CCLayerColor
{
    BOOL _isSelected;
    int _index;
    NSString *_reuseIdentifier;
    BOOL _isTouchDown;
}

@property (nonatomic, assign) BOOL isSelected;               //是否被点击
@property (nonatomic, assign) int index;                     //坐标
@property (nonatomic, assign) NSString *reuseIdentifier;     //重用id

@property (nonatomic, readonly) BOOL isTouchDown;
- (id)initWithReuseIdentifier:(NSString *)identifier;       //初始化方法
- (void)resetCell;
- (void)touchDown;
- (void)touchUp;
@end
