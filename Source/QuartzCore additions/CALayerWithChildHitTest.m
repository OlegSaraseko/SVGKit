//
//  CALayerWithChildHitTest.m
//  SVGKit
//
//

#import "CALayerWithChildHitTest.h"

#import "CAShapeLayerWithHitTest.h"

@implementation CALayerWithChildHitTest

- (id)init {
	if ((self = [super init])) {
		self.userInteractionsEnabled = YES;
	}
	return self;
}

- (void)setUserInteractionsEnabled:(BOOL)enabled
{
	if (_userInteractionsEnabled != enabled) {
		_userInteractionsEnabled = enabled;
		
		// set child's userInteractionsEnabled flag
		[self setRecurentlyUserInteractionsFlagForLayer:self];
	}
}

- (void)setRecurentlyUserInteractionsFlagForLayer:(CALayer*)aLayer
{
	if (!aLayer) return;
	
	if ([aLayer isKindOfClass:[CAShapeLayerWithHitTest class]]) {
		((CAShapeLayerWithHitTest*)aLayer).userInteractionsEnabled = _userInteractionsEnabled;
	}
	
	for (CALayer* sublayer in aLayer.sublayers) {
		[self setRecurentlyUserInteractionsFlagForLayer:sublayer];
	}
}

- (BOOL) containsPoint:(CGPoint)p
{
	BOOL boundsContains = CGRectContainsPoint(self.bounds, p); // must be BOUNDS because Apple pre-converts the point to local co-ords before running the test
	
	if( self.userInteractionsEnabled && boundsContains )
	{
		BOOL atLeastOneChildContainsPoint = FALSE;
		
		for( CALayer* subLayer in self.sublayers )
		{
			// must pre-convert the point to local co-ords before running the test because Apple defines "containsPoint" in that fashion
			
			CGPoint pointInSubLayer = [self convertPoint:p toLayer:subLayer];
			
			if( [subLayer containsPoint:pointInSubLayer] )
			{
				atLeastOneChildContainsPoint = TRUE;
				break;
			}
		}
		
		return atLeastOneChildContainsPoint;
	}
	
	return NO;
}

@end

