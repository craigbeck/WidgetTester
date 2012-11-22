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
#import "ProjectedDataPoint.h"

@implementation WidgetTestRunView
{
    NSPoint pointerPosition;
    NSColor *lineColor;
    NSColor *tickColor;
    NSColor *backgroundPrimary;
    NSColor *dataPointColor;
    NSColor *dataPointHighlightColor;
    NSColor *dataAreaColor;
    BOOL showTicks;
    BOOL showLine;
    BOOL showPoints;
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
        showLine = YES;
        showPoints = YES;
        showTicks = YES;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSUInteger drawingStyleNumber = [[NSUserDefaults standardUserDefaults] integerForKey:drawingStyleKey];
    NSArray *projectedObservations = [self projectObservations];
    
    
	switch (drawingStyleNumber) {
		case 0:
            backgroundPrimary = [NSColor colorWithCalibratedRed:0.1 green:0.2 blue:0.2 alpha:1.0];
            tickColor = [NSColor colorWithCalibratedRed:0.1 green:0.9 blue:0.6 alpha:0.5];
            lineColor = [NSColor colorWithCalibratedRed:0.1 green:0.9 blue:0.9 alpha:0.9];
            dataAreaColor = [NSColor colorWithCalibratedRed:0.1 green:0.7 blue:0.7 alpha:0.5];
            dataPointColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.7];
            dataPointHighlightColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.8];
			break;
		case 1:
            backgroundPrimary = [NSColor colorWithCalibratedRed:0.6 green:0.2 blue:0.2 alpha:1.0];
            tickColor = [NSColor colorWithCalibratedRed:0.9 green:0.1 blue:0.6 alpha:0.5];
            lineColor = [NSColor colorWithCalibratedRed:0.9 green:0.6 blue:0.3 alpha:0.9];
            dataAreaColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.2];
            dataPointColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.7];
            dataPointHighlightColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.8];
			break;
		case 2:
            backgroundPrimary = [NSColor colorWithCalibratedRed:0.1 green:0.2 blue:0.2 alpha:1.0];
            tickColor = [NSColor colorWithCalibratedRed:0.1 green:0.9 blue:0.6 alpha:0.5];
            lineColor = [NSColor colorWithCalibratedRed:1.0 green:7.0 blue:0.2 alpha:0.9];
            dataAreaColor = [NSColor colorWithCalibratedRed:0.1 green:0.3 blue:1.0 alpha:0.7];
            dataPointColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.7];
            dataPointHighlightColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:0.8];
			break;
	}
    
    [self drawTicks];
    [self drawLines:projectedObservations];
    [self drawPointer];
    [self drawDataPoints:projectedObservations];
    
	if (self.shouldDrawMouseInfo)
    {
        NSString *labelText = [[NSString alloc] initWithFormat:@"X: %f\nY: %f", pointerPosition.x, pointerPosition.y];
        [self drawLabel:labelText atPoint:NSMakePoint(8, 8)];
        [labelText release];
    }
}

- (double)xScaleFactor
{
    double xMax = self.widgetTester.timeMaximum;
    double xMin = self.widgetTester.timeMinimum;
    double xRange = xMax - xMin;
    return self.frame.size.width / xRange;
}

- (double)yScaleFactor
{
    double yMin = self.widgetTester.sensorMinimum;
    double yMax = self.widgetTester.sensorMaximum;
    double yRange = yMax - yMin;
    return self.frame.size.height / yRange * self.magnification;
}

- (NSArray*)projectObservations
{
    NSRect bounds = self.frame;
    double xScale = [self xScaleFactor];
    double yScale = [self yScaleFactor];
    
    NSMutableArray *projections = [[NSMutableArray alloc] initWithCapacity:[self.widgetTester.testData count]];
    
    for (WidgetTestObservationPoint *observation in self.widgetTester.testData)
    {
        double xProjected = (observation.observationTime - self.widgetTester.timeMinimum) * xScale;
        double yProjected = -1 * (((observation.voltage - self.widgetTester.sensorMinimum) * yScale) - bounds.size.height);
        NSPoint projected = NSMakePoint(xProjected, yProjected);
        ProjectedDataPoint *projectedPoint = [[[ProjectedDataPoint alloc] initWith:observation andPoint:projected] autorelease];
        [projections addObject:projectedPoint];
    }
    
    return [projections autorelease];
}

- (void)drawTicks
{
    NSRect bounds = [self frame];
    
    [backgroundPrimary set];
    [NSBezierPath fillRect:bounds];
    
    if (showTicks)
    {
        [tickColor set];
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
    }
}

- (void)drawLines:(NSArray *)data
{
    NSRect bounds = self.frame;
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
    NSBezierPath *gradPath = [NSBezierPath bezierPath];
    
    [pointsPath setLineCapStyle:NSRoundLineCapStyle];
    [pointsPath setLineJoinStyle:NSRoundLineJoinStyle];
    [pointsPath moveToPoint:bounds.origin];
    [gradPath moveToPoint:bounds.origin];
    
    BOOL isFirstPoint = YES;
	for (ProjectedDataPoint *dataPoint in data)
    {
        [pointsPath setMiterLimit:5.0];
        if (isFirstPoint)
        {
            [pointsPath moveToPoint:dataPoint.projected];
            isFirstPoint = NO;
        }
        else
        {
            [pointsPath lineToPoint:dataPoint.projected];
        }
        [gradPath lineToPoint:dataPoint.projected];
	}
    [pointsPath lineToPoint:NSMakePoint(bounds.size.width, bounds.origin.y)];
    [gradPath lineToPoint:NSMakePoint(bounds.size.width, bounds.origin.y)];
    
    // apply style
    NSColor *gradStartColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3];
    NSColor *gradEndColor = dataAreaColor;
    NSGradient *grad = [[NSGradient alloc] initWithStartingColor:gradStartColor endingColor:gradEndColor];
    [grad drawInBezierPath:gradPath angle:90];
	[grad release];
    
    grad = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0 alpha:0.05] endingColor:[NSColor colorWithCalibratedRed:0.5 green:0 blue:0 alpha:0.25]];
    [grad drawInBezierPath:[NSBezierPath bezierPathWithRect:bounds] angle:270];
    [grad release];
    
    [pointsPath setLineWidth:2.0];
    [lineColor set];
    if (showLine) [pointsPath stroke];
}

- (void)drawDataPoints:(NSArray *)data
{
    for (ProjectedDataPoint *point in data)
    {
        [dataPointColor set];
        
        double r = 3.0;
        NSBezierPath *dataPoint = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(point.projected.x - r, point.projected.y - r, r*2, r*2)];
        [dataPoint setLineWidth:2.0];
        if ([dataPoint containsPoint:pointerPosition])
        {
            // draw data point value label
            NSString *labelText = [[NSString alloc] initWithFormat:@"time: %f\nvoltage: %f", point.data.observationTime, point.data.voltage];
            
            [self drawLabel:labelText forDataPoint:pointerPosition];
            [labelText release];
            [dataPointHighlightColor set];
            [dataPoint setLineWidth:3.0];
        }
        if (showPoints) [dataPoint stroke];
	}
}

- (void)drawLabel:(NSString *)string forDataPoint:(NSPoint)point
{
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSFont fontWithName:@"Monaco" size:11],
                                NSFontAttributeName,
                                [NSColor whiteColor],
                                NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *label = [[NSAttributedString alloc] initWithString:string attributes: attributes];
    NSSize size = [label size];
    
    double rightOffset = point.x + 4;
    double leftOffset = point.x - 12 - size.width;
    double upOffest = point.y + 4;
    double downOffset = point.y - 38;
    
    double xOffset = rightOffset;
    double yOffset = downOffset;
    
    if (rightOffset + size.width > self.bounds.size.width - 8.0) xOffset = leftOffset;
    if (downOffset < 8.0) yOffset = upOffest;
    
    NSPoint labelPosition = NSMakePoint(xOffset, yOffset);
    
    [self drawAttributedString:label atPoint:labelPosition];
    
    [label release];
    [attributes release];
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
    
    
    [self drawAttributedString:label atPoint:NSMakePoint(point.x + 4, point.y + 2)];
    
    [label release];
    [attributes release];
}

- (void)drawAttributedString:(NSAttributedString *)string atPoint:(NSPoint)point
{
    NSSize size = [string size];
    
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.6] set];
    [NSBezierPath fillRect:NSMakeRect(point.x, point.y, size.width + 8, size.height + 4)];
    [string drawAtPoint:NSMakePoint(point.x + 4, point.y + 2)];
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

-(void)keyDown:(NSEvent *)theEvent
{
    NSString *key = [theEvent charactersIgnoringModifiers];
    if ([key isCaseInsensitiveLike:@"L"]) showLine = !showLine;
    if ([key isCaseInsensitiveLike:@"P"]) showPoints = !showPoints;
    if ([key isCaseInsensitiveLike:@"T"]) showTicks = !showTicks;
    [self setNeedsDisplay:YES];
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
