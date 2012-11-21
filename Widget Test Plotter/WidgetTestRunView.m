//
//  WidgetTestRunView.m
//  Widget Test Plotter
//
//  Created by CP120 on 10/31/12.
//  Copyright (c) 2012 Hal Mueller. All rights reserved.
//

#import "WidgetTestRunView.h"
#import "WidgetTester.h"
#import "WidgetTestObservationPoint.h"
#import "KeyStrings.h"
#import <AppKit/NSBezierPath.h>

@implementation WidgetTestRunView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        _magnification = 1.0;
        NSTrackingAreaOptions trackingOptions = NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingMouseMoved;
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:frame
                                                     options:trackingOptions
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect bounds = [self bounds];
//	MyLog(@"drawRect: bounds %@", NSStringFromRect(bounds)); // 615 x 482
    
    [[NSColor colorWithCalibratedRed:0.1 green:0.2 blue:0.2 alpha:1.0] set];
    [NSBezierPath fillRect:bounds];
	
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
    NSBezierPath *gradPath = [NSBezierPath bezierPath];
    
    [pointsPath setLineCapStyle:NSRoundLineCapStyle];
    [pointsPath setLineJoinStyle:NSRoundLineJoinStyle];
	
	NSUInteger drawingStyleNumber = [[NSUserDefaults standardUserDefaults] integerForKey:drawingStyleKey];
    double xMax = self.widgetTester.timeMaximum;
    double xMin = self.widgetTester.timeMinimum;
    double xRange = xMax - xMin;
    double xScale = bounds.size.width / xRange;
    
    double yMin = self.widgetTester.sensorMinimum;
    double yMax = self.widgetTester.sensorMaximum;
    double yRange = yMax - yMin;
    double yScale = bounds.size.height / yRange * self.magnification;
//    double yMid = yRange / 2.0;
    
    
    [[NSColor colorWithCalibratedRed:0.1 green:0.9 blue:0.6 alpha:0.5] set];
    for (int tick = 1; tick < 10; tick++)
    {
        double xTickScale = bounds.size.height/10;
        NSBezierPath *xTick = [NSBezierPath bezierPath];
        [xTick moveToPoint:NSMakePoint(bounds.origin.x, xTickScale * tick)];
        [xTick lineToPoint:NSMakePoint(bounds.size.width, xTickScale * tick)];
        [xTick setLineWidth:0.8];
        [xTick stroke];
        
        double yTickScale = bounds.size.width/10;
        NSBezierPath *yTick = [NSBezierPath bezierPath];
        [yTick moveToPoint:NSMakePoint(yTickScale * tick, bounds.origin.y)];
        [yTick lineToPoint:NSMakePoint(yTickScale * tick, bounds.size.width)];
        [yTick setLineWidth:0.8];
        [yTick stroke];
    }
    
    
//    MyLog(@"range x:%f y:%f, scale x:%f y:%f", xRange, yRange, xScale, yScale);
    [pointsPath moveToPoint:bounds.origin];
    [gradPath moveToPoint:bounds.origin];
    
    BOOL isFirstPoint = YES;
	for (WidgetTestObservationPoint *observation in self.widgetTester.testData)
    {
        double xProjected = (observation.observationTime - xMin) * xScale;
        double yProjected = -1 * (((observation.voltage - yMin) * yScale) - bounds.size.height);
		NSPoint projectedPoint = NSMakePoint(xProjected, yProjected);
        
        [pointsPath setFlatness:0.3];
        [pointsPath setMiterLimit:5.0];
        if (isFirstPoint)
        {
            [pointsPath moveToPoint:projectedPoint];
            isFirstPoint = NO;
        }
        else
        {
            [pointsPath lineToPoint:projectedPoint];
        }
        [gradPath lineToPoint:projectedPoint];
	}
    [pointsPath lineToPoint:NSMakePoint(bounds.size.width, bounds.origin.y)];
    [gradPath lineToPoint:NSMakePoint(bounds.size.width, bounds.origin.y)];
    NSBezierPath *xAxis = [NSBezierPath bezierPath];
    double zero = -1 * (((0.0 - yMin) * yScale) - bounds.size.height);
    [xAxis moveToPoint:NSMakePoint(bounds.origin.x, zero)];
    [xAxis lineToPoint:NSMakePoint(bounds.size.width, zero)];
    [[NSColor colorWithCalibratedRed:0.9 green:0 blue:0 alpha:0.7] set];
    [xAxis stroke];
    
    // apply style
    NSColor *gradStartColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3];
    NSColor *gradEndColor = [NSColor colorWithCalibratedRed:0.1 green:0.7 blue:0.7 alpha:0.5];
    NSGradient *grad = [[NSGradient alloc] initWithStartingColor:gradStartColor endingColor:gradEndColor];
    [grad drawInBezierPath:gradPath angle:90];
	
    
    [pointsPath setLineWidth:2.0];
    [[NSColor colorWithCalibratedRed:0.1 green:0.9 blue:0.9 alpha:0.9] set];
    [pointsPath stroke];
    
    [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0 alpha:0.05] endingColor:[NSColor colorWithCalibratedRed:0.5 green:0 blue:0 alpha:0.25]] drawInBezierPath:[NSBezierPath bezierPathWithRect:bounds] angle:270];
    
    
    [[NSColor colorWithCalibratedWhite:0.9 alpha:0.7] set];
    for (WidgetTestObservationPoint *observation in self.widgetTester.testData)
    {
        double xProjected = (observation.observationTime - xMin) * xScale;
        double yProjected = -1 * (((observation.voltage - yMin) * yScale) - bounds.size.height);
        double r = 3.0;
        NSBezierPath *dataPoint = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(xProjected-r, yProjected-r, r*2, r*2)];
        [dataPoint setLineWidth:2.0];
        [dataPoint stroke];
	}
    
    
	switch (drawingStyleNumber) {
		case 0:

			break;
		case 1:

			break;
		case 2:

			break;
	}
	if (self.shouldDrawMouseInfo) {
	
    }
}


#pragma mark - Mouse Events

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSLog(@"mouseMoved: %@", NSStringFromPoint(theEvent.locationInWindow));
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	NSLog(@"mouseEntered: %@", NSStringFromPoint(theEvent.locationInWindow));
}

- (void)mouseExited:(NSEvent *)theEvent
{
	NSLog(@"mouseExited: %@", NSStringFromPoint(theEvent.locationInWindow));
}

#pragma mark - Gesture Events

- (void)magnifyWithEvent:(NSEvent *)event
{
    double minMagnification = 0.25;
    double maxMagnification = 1.1;
    double newMagnification = self.magnification + (event.magnification * 0.7);
    newMagnification = MAX(newMagnification, minMagnification);
    newMagnification = MIN(newMagnification, maxMagnification);
    self.magnification = newMagnification;
    [self setNeedsDisplay:YES];
}

@end
