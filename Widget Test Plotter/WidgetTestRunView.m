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
{
    NSPoint pointerPosition;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _magnification = 1.0;
        if (NSPointInRect([self mousePositionViewCoordinates], frame))
        {
            pointerPosition = [self mousePositionViewCoordinates];
        }
        [self addTrackingArea:[[self newTrackingArea] autorelease]];
        [self.window makeFirstResponder:self];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = [self bounds];
    
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
    
    
    [self drawPointer];
    
    NSColor *dataPointColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.7];
    NSColor *dataPointHighlightColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.8];
    for (WidgetTestObservationPoint *observation in self.widgetTester.testData)
    {
        [dataPointColor set];
        
        NSPoint projected;
        projected.x = (observation.observationTime - xMin) * xScale;
        projected.y = -1 * (((observation.voltage - yMin) * yScale) - bounds.size.height);
        
        double r = 3.0;
        NSBezierPath *dataPoint = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(projected.x - r, projected.y - r, r*2, r*2)];
        [dataPoint setLineWidth:2.0];
        if ([dataPoint containsPoint:pointerPosition])
        {
            // draw data point value label
            NSString *labelText = [[NSString alloc] initWithFormat:@"time: %f\nvoltage: %f", observation.observationTime, observation.voltage];

            [self drawLabel:labelText forDataPoint:pointerPosition];
            [dataPointHighlightColor set];
            [dataPoint setLineWidth:3.0];
        }
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
	if (self.shouldDrawMouseInfo)
    {
        NSString *labelText = [[NSString alloc] initWithFormat:@"X: %f\nY: %f", pointerPosition.x, pointerPosition.y];
        [self drawLabel:labelText atPoint:NSMakePoint(8, 8)];
        [labelText release];
    }
}

- (void)drawLabel:(NSString *)string forDataPoint:(NSPoint)point
{
    NSPoint labelPosition = { point.x + 4, point.y - 38 };
//    labelPosition.x = point.x + 4;
//    labelPosition.y = point.y - 36;
    [self drawLabel:string atPoint:labelPosition];
}

- (void)drawLabel:(NSString *)string atPoint:(NSPoint)point
{
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSFont fontWithName:@"Monaco" size:11],
                                NSFontAttributeName,
                                [NSColor whiteColor],
                                NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *label = [[NSAttributedString alloc] initWithString:string attributes: attributes];
    
    NSSize size = [label size];
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.6] set];
    
    [NSBezierPath fillRect:NSMakeRect(point.x, point.y, size.width + 8, size.height + 4)];
    
    [label drawAtPoint:NSMakePoint(point.x + 4, point.y + 2)];
    [label release];
    [attributes release];
}

- (void)drawPointer
{
    [[NSColor colorWithCalibratedWhite:0.9 alpha:0.5] set];
    
    NSRect bounds = [self frame];
    NSBezierPath *targetingVertical = [NSBezierPath bezierPath];
    [targetingVertical moveToPoint:NSMakePoint(pointerPosition.x, bounds.origin.y)];
    [targetingVertical lineToPoint:NSMakePoint(pointerPosition.x, bounds.size.height)];
    [targetingVertical setLineWidth:1.0];
    [targetingVertical stroke];
    
    NSBezierPath *targetingHorizontal = [NSBezierPath bezierPath];
    [targetingHorizontal moveToPoint:NSMakePoint(bounds.origin.x, pointerPosition.y)];
    [targetingHorizontal lineToPoint:NSMakePoint(bounds.size.width, pointerPosition.y)];
    [targetingHorizontal setLineWidth:1.0];
    [targetingHorizontal stroke];
}

- (NSTrackingArea *)newTrackingArea
{
    NSTrackingAreaOptions trackingOptions = NSTrackingCursorUpdate | NSTrackingEnabledDuringMouseDrag | NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingMouseMoved | NSTrackingInVisibleRect;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
                                                                options:trackingOptions
                                                                  owner:self
                                                               userInfo:nil];
    return trackingArea;
}

#pragma mark - Mouse Events

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    pointerPosition = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [NSCursor hide];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [NSCursor unhide];
}

#pragma mark - Keyboard Events

- (void)flagsChanged:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSShiftKeyMask)
    {
        self.shouldDrawMouseInfo = YES;
        [self setNeedsDisplay:YES];
    }
    else
    {
        self.shouldDrawMouseInfo = NO;
        [self setNeedsDisplay:YES];
    }
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

- (void)swipeWithEvent:(NSEvent *)event
{
    NSLog(@"swipe event: %@", event);
}

@end
