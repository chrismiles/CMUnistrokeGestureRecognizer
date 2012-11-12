//
//  CMUDTemplateDataViewController.m
//  CMUnistrokeDemo
//
//  Created by Chris Miles on 12/11/12.
//  Copyright (c) 2012 Chris Miles. All rights reserved.
//
//  MIT Licensed (http://opensource.org/licenses/mit-license.php):
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMUDTemplateDataViewController.h"
#import "CMUDTemplate.h"

static void
CMUDTemplatePointsArrayApplierFunc(void *info, const CGPathElement *element);


@interface CMUDTemplateDataViewController ()

@property (weak, nonatomic) IBOutlet UITextView *dataTextView;

@end


@implementation CMUDTemplateDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableString *text = [NSMutableString string];
    
    [self.paths enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL __unused *stopDict) {
	NSString *name = (NSString *)key;
	NSArray *pathList = (NSArray *)obj;
	[pathList enumerateObjectsUsingBlock:^(id arrayObj, NSUInteger idx, BOOL __unused *stopArray) {
	    NSString *pathName = name;
	    if ([pathList count] > 1) {
		pathName = [name stringByAppendingFormat:@"%d", idx+1];
	    }
	    [text appendString:[self pathAsCGPointData:(UIBezierPath *)arrayObj withName:pathName]];
	}];
    }];
    self.dataTextView.text = text;
}

- (NSString *)pathAsCGPointData:(UIBezierPath *)path withName:(NSString *)name
{
    /*
     Example:
	 #define kStrokeNamePointsCount 5
	 CGPoint strokeNamePoints[kStrokeNamePointsCount] = {
	    {81.0f, 219.0f}, {84.0f, 218.0f}, {86.0f, 220.0f}, {88.0f, 220.0f}, {90.0f, 220.0f},
	 };
     */
    
    NSString *cleanName = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    CGPathApply(path.CGPath, (__bridge void *)(pointsArray), CMUDTemplatePointsArrayApplierFunc);

    NSMutableString *text = [NSMutableString stringWithFormat:@"\n#define kStroke%@PointsCount %d\n", cleanName, [pointsArray count]];
    [text appendFormat:@"CGPoint stroke%@Points[kStroke%@PointsCount] = {", cleanName, cleanName];
    [pointsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL __unused *stop) {
	if (idx % 5 == 0) [text appendString:@"\n   "];
	CGPoint point = [(NSValue *)obj CGPointValue];
	[text appendFormat:@" {%0.1ff, %0.1ff},", point.x, point.y];
    }];
    [text appendString:@"\n};\n"];
    
    return text;
}

@end


static void
CMUDTemplatePointsArrayApplierFunc(void *info, const CGPathElement *element)
{
    NSMutableArray *pointsArray = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
	    
        case kCGPathElementAddLineToPoint: // contains 1 point
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
	    
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[0]]];
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[1]]];
            break;
	    
        case kCGPathElementAddCurveToPoint: // contains 3 points
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[0]]];
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[1]]];
	    [pointsArray addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
	    
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}
