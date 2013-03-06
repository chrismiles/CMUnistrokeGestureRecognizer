//
//  CMUnistrokeGestureRecognizer.m
//  CMUnistrokeGestureRecognizer
//
//  Created by Chris Miles on 23/09/12.
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

#import "CMUnistrokeGestureRecognizer.h"
#import "CMUnistrokeRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static void
CMURCGPathApplierFunc(void *info, const CGPathElement *element);


#pragma mark - CMUnistrokeGestureRecognizer class extension

@interface CMUnistrokeGestureRecognizer () {
    CMUROptionsRef _options;
    CMURTemplatesRef _unistrokeTemplates;
}
@property (nonatomic, strong, readwrite) CMUnistrokeGestureResult *result;
@property (nonatomic, strong, readwrite) UIBezierPath *strokePath;
@property (nonatomic, strong) UITouch *trackedTouch;
@end


#pragma mark - CMUnistrokeGestureRecognizer implementation

@implementation CMUnistrokeGestureRecognizer

@dynamic protactorMethodEnabled;
@dynamic rotationNormalisationEnabled;


- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
	_unistrokeTemplates = CMURTemplatesNew();
	
	_options = CMUROptionsNew();
	_options->useProtractor = false;
	_options->rotationNormalisationDisabled = false;
    }
    return self;
}

- (void)dealloc
{
    if (_options) {
	CMUROptionsDelete(_options); _options = NULL;
    }
    if (_unistrokeTemplates) {
	CMURTemplatesDelete(_unistrokeTemplates); _unistrokeTemplates = NULL;
    }
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.result = nil;
    
    self.trackedTouch = [touches anyObject];
    self.strokePath = [[UIBezierPath alloc] init];
    
    self.state = UIGestureRecognizerStatePossible;
    
    CGPoint location = [self.trackedTouch locationInView:self.view];
    [self.strokePath moveToPoint:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ([touches containsObject:self.trackedTouch]) {
	CGPoint location = [self.trackedTouch locationInView:self.view];
	[self.strokePath addLineToPoint:location];
	
	id<CMUnistrokeGestureRecognizerDelegate> unistrokeDelegate = self.unistrokeDelegate;
	if ([unistrokeDelegate respondsToSelector:@selector(unistrokeGestureRecognizer:isEvaluatingStrokePath:)]) {
	    [unistrokeDelegate unistrokeGestureRecognizer:self isEvaluatingStrokePath:self.strokePath];
	}
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self recognizeUnistroke];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self recognizeUnistroke];
}


#pragma mark - Reset

- (void)reset
{
    [super reset];
    
    self.strokePath = nil;
    self.trackedTouch = nil;
}


#pragma mark - Unistroke recognizer options

- (void)setProtactorMethodEnabled:(BOOL)protactorMethodEnabled
{
    _options->useProtractor = protactorMethodEnabled;
}

- (BOOL)protactorMethodEnabled
{
    return _options->useProtractor;
}

- (void)setRotationNormalisationEnabled:(BOOL)rotationNormalisationEnabled
{
    _options->rotationNormalisationDisabled = (! rotationNormalisationEnabled);
}

- (BOOL)rotationNormalisationEnabled
{
    return (! _options->rotationNormalisationDisabled);
}


#pragma mark - Recognize Unistroke

- (void)recognizeUnistroke
{
    if ([self isUnistrokeRecognized]) {
	self.state = UIGestureRecognizerStateRecognized;
    }
    else {
	self.state = UIGestureRecognizerStateFailed;
	
	id<CMUnistrokeGestureRecognizerDelegate> unistrokeDelegate = self.unistrokeDelegate;
	if ([unistrokeDelegate respondsToSelector:@selector(unistrokeGestureRecognizerDidFailToRecognize:)]) {
	    [unistrokeDelegate unistrokeGestureRecognizerDidFailToRecognize:self];
	}
    }
}

- (BOOL)isUnistrokeRecognized
{
    CMURPathRef path = [self pathFromBezierPath:self.strokePath];
    CMURResultRef result = unistrokeRecognizePathFromTemplates(path, _unistrokeTemplates, _options);
    CMURPathDelete(path);
    
    BOOL isRecognized;
    if (result && result->score >= self.minimumScoreThreshold) {
	isRecognized = YES;
	self.result = [[CMUnistrokeGestureResult alloc] initWithName:[NSString stringWithCString:result->name encoding:NSUTF8StringEncoding] score:result->score];
	CMUGRLog(@"Recognized: result->score = %f result->name = '%s'", result->score, result->name);
    }
    else {
	isRecognized = NO;
	self.result = nil;
	CMUGRLog(@"NOT Recognized");
    }
    
    CMURResultDelete(result);
    
    return isRecognized;
}

- (CMURPathRef)pathFromBezierPath:(UIBezierPath *)bezierPath
{
    CMURPathRef path = CMURPathNew();
    CGPathApply(bezierPath.CGPath, path, CMURCGPathApplierFunc);

    return path;
}


#pragma mark - Stroke templates

- (void)registerUnistrokeWithName:(NSString *)name bezierPath:(UIBezierPath *)bezierPath
{
    [self registerUnistrokeWithName:name bezierPath:bezierPath bidirectional:NO];
}

- (void)registerUnistrokeWithName:(NSString *)name bezierPath:(UIBezierPath *)bezierPath bidirectional:(BOOL)bidirectional
{
    CMURPathRef path = [self pathFromBezierPath:bezierPath];
    CMURTemplatesAdd(_unistrokeTemplates, [name cStringUsingEncoding:NSUTF8StringEncoding], path, _options);
    
    if (bidirectional) {
	CMURPathReverse(path);
	CMURTemplatesAdd(_unistrokeTemplates, [name cStringUsingEncoding:NSUTF8StringEncoding], path, _options);
    }
    
    CMURPathDelete(path);
}

- (void)clearAllUnistrokes
{
    if (_unistrokeTemplates) {
	CMURTemplatesDelete(_unistrokeTemplates);
    }
    _unistrokeTemplates = CMURTemplatesNew();
}

@end


static void
CMURCGPathApplierFunc(void *info, const CGPathElement *element)
{
    CMURPathRef path = (CMURPathRef)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
	    CMURPathAddPoint(path, points[0].x, points[0].y);
            break;
	    
        case kCGPathElementAddLineToPoint: // contains 1 point
	    CMURPathAddPoint(path, points[0].x, points[0].y);
            break;
	    
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
	    CMURPathAddPoint(path, points[0].x, points[0].y);
	    CMURPathAddPoint(path, points[1].x, points[1].y);
            break;
	    
        case kCGPathElementAddCurveToPoint: // contains 3 points
	    CMURPathAddPoint(path, points[0].x, points[0].y);
	    CMURPathAddPoint(path, points[1].x, points[1].y);
	    CMURPathAddPoint(path, points[2].x, points[2].y);
            break;
	    
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}
