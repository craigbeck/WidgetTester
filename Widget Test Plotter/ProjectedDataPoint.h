//
//  ProjectedDataPoint.h
//  Widget Test Plotter
//
//  Created by Craig Beck on 11/21/12.
//  Copyright (c) 2012 Hal Mueller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WidgetTestObservationPoint.h"

@interface ProjectedDataPoint : NSObject

- (id)initWith:(WidgetTestObservationPoint*)data andPoint:(NSPoint)point;
- (WidgetTestObservationPoint *)data;
- (NSPoint)projected;
@end
