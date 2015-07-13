# CCTableLayer
A **UITableView** in Cocos2D for iPhone.
## Provide
* Draging and Scrolling
* Costomed TableCell
  * Height
  * Count
  * Style
* Cell Reuse

## How To Use
The way using CCTableLayer is almost the as UITableView & UITableViewCell
``` objective-c

-(id) init
{
	if( (self=[super init])) {
		    _tableLayer = [[CCTableLayer alloc]init];
        _tableLayer.delegate = self;
        _tableLayer.dataSource = self;
        _tableLayer.contentSize = self.contentSize;
        [self addChild:_tableLayer];
	}
	return self;
}

- (CGFloat)tableLayer:(CCTableLayer *)tableLayer heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (int)tableLayer:(CCTableLayer *)tableLayer numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CCTableLayerCell *)tableLayer:(CCTableLayer *)tableLayer cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCTableLayerCell *cell = [tableLayer dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CCTableLayerCell alloc]initWithReuseIdentifier:@"cell"];
        
    }
    [cell removeAllChildrenWithCleanup:YES];
    CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",indexPath.row] fontName:@"GillSans" fontSize:10];
    label.anchorPoint = CGPointZero;
    label.color = ccWHITE;
    [cell addChild:label];
    return cell;
}

- (void)tableLayer:(CCTableLayer *)tableLayer cellNeedDelete:(CCTableLayerCell *)cell
{
    
}
```
