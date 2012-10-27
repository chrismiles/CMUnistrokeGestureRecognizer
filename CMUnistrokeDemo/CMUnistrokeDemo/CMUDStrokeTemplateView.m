//
//  CMUDStrokeTemplateView.m
//  CMUnistrokeDemo
//
//  Created by Chris Miles on 19/10/12.
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

#import "CMUDStrokeTemplateView.h"

typedef struct {
    CGPoint startPoint;
    CGFloat scaleToFit;
    CGPoint translationToFit;
} CMUDBezierPathInfo;

typedef struct {
    CGRect pathRect;
    CGPoint startPoint;
} CMUDPathAnalysis;


static void
CMUDCGPathApplierFunc(void *info, const CGPathElement *element);


#pragma mark - Implementation

@implementation CMUDStrokeTemplateView

- (id)initWithName:(NSString *)name bezierPath:(UIBezierPath *)bezierPath
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.name = name;
	self.bezierPath = bezierPath;
	
	self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    rect = CGRectInset(rect, 5.0f, 5.0f);
    CMUDBezierPathInfo bezierPathInfo = [self bezierPathInfoToFitRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y);
    CGContextScaleCTM(ctx, bezierPathInfo.scaleToFit, bezierPathInfo.scaleToFit);
    CGContextTranslateCTM(ctx, bezierPathInfo.translationToFit.x, bezierPathInfo.translationToFit.y);
    
    UIColor *drawColor = (self.isHighlighted ? [UIColor greenColor] : [UIColor blackColor]);
    CGContextSetStrokeColorWithColor(ctx, drawColor.CGColor);
    CGContextSetFillColorWithColor(ctx, drawColor.CGColor);
    
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextStrokePath(ctx);
    
    CGFloat radius = 5.0f / bezierPathInfo.scaleToFit;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) radius *= 0.5f;
    CGContextFillEllipseInRect(ctx, CGRectMake(bezierPathInfo.startPoint.x - radius, bezierPathInfo.startPoint.y - radius, radius*2.0f, radius*2.0f));
}

- (CMUDBezierPathInfo)bezierPathInfoToFitRect:(CGRect)rect
{
    CMUDPathAnalysis pathAnalysis;
    pathAnalysis.pathRect = CGRectZero;
    pathAnalysis.startPoint = CGPointMake(-1.0f, -1.0f); // i.e. undefined
    
    CGPathApply(self.bezierPath.CGPath, &pathAnalysis, CMUDCGPathApplierFunc);
    
    CGFloat scale = fminf(rect.size.width / pathAnalysis.pathRect.size.width, rect.size.height / pathAnalysis.pathRect.size.height);
    CGPoint translation = CGPointMake(-pathAnalysis.pathRect.origin.x + (rect.size.width/2.0f - scale*pathAnalysis.pathRect.size.width/2.0f),
				      -pathAnalysis.pathRect.origin.y + (rect.size.height/2.0f - scale*pathAnalysis.pathRect.size.height/2.0f));
    
    CMUDBezierPathInfo bezierPathInfo;
    bezierPathInfo.startPoint = pathAnalysis.startPoint;
    bezierPathInfo.scaleToFit = scale;
    bezierPathInfo.translationToFit = translation;
    
    return bezierPathInfo;
}


#pragma mark - Highlighted

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

@end


#pragma mark - CGPathApply functions

static void
CGRectUnionWithPoint(CGRect *rect, CGPoint point)
{
    CGRect pointRect = CGRectMake(point.x, point.y, 1.0f, 1.0f);
    if (CGRectEqualToRect(*rect, CGRectZero)) {
	*rect = pointRect;
    }
    else {
	*rect = CGRectUnion(*rect, pointRect);
    }
}

static void
CMUDCGPathApplierFunc(void *info, const CGPathElement *element)
{
    CMUDPathAnalysis *pathAnalysis = (CMUDPathAnalysis *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    unsigned int numPoints = 0;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
	    numPoints = 1;
            break;
	    
        case kCGPathElementAddLineToPoint: // contains 1 point
	    numPoints = 1;
            break;
	    
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
	    numPoints = 2;
            break;
	    
        case kCGPathElementAddCurveToPoint: // contains 3 points
	    numPoints = 3;
            break;
	    
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
    
    for (unsigned int i=0; i<numPoints; i++) {
	if (i == 0 && pathAnalysis->startPoint.x < 0.0f) {
	    pathAnalysis->startPoint = points[0];
	}
	
	CGRectUnionWithPoint(&pathAnalysis->pathRect, points[i]);
    }

}
