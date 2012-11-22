//
//  ProjectedDataPoint.m
//  Widget Test Plotter
//
//  Created by Craig Beck on 11/21/12.
//  Copyright (c) 2012 Hal Mueller. All rights reserved.
//

#import "ProjectedDataPoint.h"

@implementation ProjectedDataPoint
{
    WidgetTestObservationPoint *_data;
    NSPoint _projected;
}

- (id)initWith:(WidgetTestObservationPoint *)data andPoint:(NSPoint)point
{
    self = [super init];
    if (self)
    {
        _data = [data retain];
        _projected = point;
    }
    return self;
}

- (WidgetTestObservationPoint *)data
{
    return _data;
}

- (NSPoint)projected
{
    return _projected;
}


- (void)dealloc
{
    [_data release];
    [super dealloc];
}

@end
