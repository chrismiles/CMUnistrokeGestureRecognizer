//
//  CMUDDrawView.m
//  CMUnistrokeDemo
//
//  Created by Chris Miles on 6/10/12.
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

#import "CMUDDrawView.h"
#import <CMUnistrokeGestureRecognizer/CMUnistrokeGestureRecognizer.h>

@interface CMUDDrawView () <CMUnistrokeGestureRecognizerDelegate>
@property (strong, nonatomic) CMUnistrokeGestureRecognizer *unistrokeGestureRecognizer;
@property (copy, nonatomic) UIBezierPath *drawPath;
@end

@implementation CMUDDrawView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
	self.contentMode = UIViewContentModeRedraw;
	
	self.unistrokeGestureRecognizer = [[CMUnistrokeGestureRecognizer alloc] initWithTarget:self action:@selector(unistrokeGestureRecognizer:)];
	self.unistrokeGestureRecognizer.unistrokeDelegate = self;
	[self addGestureRecognizer:self.unistrokeGestureRecognizer];
    }
    return self;
}


#pragma mark - Unistroke Gesture Recognizer

- (void)unistrokeGestureRecognizer:(CMUnistrokeGestureRecognizer *)unistrokeGestureRecognizer
{
    // A stroke was recognized
    
    //DLog(@"Recognized template: %@ (%f)", unistrokeGestureRecognizer.result.recognizedStrokeName, unistrokeGestureRecognizer.result.recognizedStrokeScore);
    
    self.drawPath = unistrokeGestureRecognizer.strokePath;
    [self.delegate drawView:self didRecognizeUnistrokeWithName:unistrokeGestureRecognizer.result.recognizedStrokeName score:unistrokeGestureRecognizer.result.recognizedStrokeScore];
    [self setNeedsDisplay];
}


#pragma mark - CMUnistrokeGestureRecognizerDelegate

- (void)unistrokeGestureRecognizer:(CMUnistrokeGestureRecognizer *)unistrokeGestureRecognizer isEvaluatingStrokePath:(UIBezierPath *)strokePath
{
#pragma unused(unistrokeGestureRecognizer)
#pragma unused(strokePath)
    
    self.drawPath = unistrokeGestureRecognizer.strokePath;
    [self.delegate drawViewDidStartRecognizingStroke:self];
    [self setNeedsDisplay];
}

- (void)unistrokeGestureRecognizerDidFailToRecognize:(CMUnistrokeGestureRecognizer *)unistrokeGestureRecognizer
{
#pragma unused(unistrokeGestureRecognizer)

    [self.delegate drawViewDidFailToRecognizeUnistroke:self];
}


#pragma mark - Unistroke registration

- (void)registerUnistrokeWithName:(NSString *)name bezierPath:(UIBezierPath *)path
{
    [self.unistrokeGestureRecognizer registerUnistrokeWithName:name bezierPath:path];
}

- (void)clearAllUnistrokes
{
    [self.unistrokeGestureRecognizer clearAllUnistrokes];
}


#pragma mark - Draw View

- (void)drawRect:(CGRect)rect
{
#pragma unused(rect)

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 3.0f);
    CGContextAddPath(ctx, self.drawPath.CGPath);
    CGContextStrokePath(ctx);
}

@end
