//
//  HelloWorldLayer.h
//  CCTableLayerTest
//
//  Created by Joe on 13-2-27.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCTableLayer.h"
// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <CCTableLayerDelegate,CCTableLayerDataSource>
{
    CCTableLayer *_tableLayer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
