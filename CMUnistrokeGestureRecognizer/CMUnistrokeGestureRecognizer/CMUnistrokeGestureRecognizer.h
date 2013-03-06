//
//  CMUnistrokeGestureRecognizer.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CMUnistrokeGestureResult.h"


@protocol CMUnistrokeGestureRecognizerDelegate;


#pragma mark - CMUnistrokeGestureRecognizer

@interface CMUnistrokeGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<CMUnistrokeGestureRecognizerDelegate> unistrokeDelegate;

/** Minimum score required to successfully register a gesture as recognized.
    i.e. recognition sensitivity.
    Expects a value between 0.0 and 1.0.
 */
@property (nonatomic, assign) float minimumScoreThreshold;

/** Enables the Protractor method for calculating difference between gestures.
    The Protractor method can be faster, but results may vary.
    Defaults to not enabled.
 */
@property (nonatomic, assign) BOOL protactorMethodEnabled;

/** Determines whether gesture rotations are normalised.
    When enabled, gestures will be normalised to the same angle before
    recognition is attempted.
    Defaults to enabled.
 */
@property (nonatomic, assign) BOOL rotationNormalisationEnabled;	// default: YES

@property (nonatomic, strong, readonly) CMUnistrokeGestureResult *result;
@property (nonatomic, strong, readonly) UIBezierPath *strokePath;

- (void)registerUnistrokeWithName:(NSString *)name bezierPath:(UIBezierPath *)path;
- (void)registerUnistrokeWithName:(NSString *)name bezierPath:(UIBezierPath *)bezierPath bidirectional:(BOOL)bidirectional;
- (void)clearAllUnistrokes;

@end


#pragma mark - Protocols

@protocol CMUnistrokeGestureRecognizerDelegate <NSObject>

@optional
- (void)unistrokeGestureRecognizer:(CMUnistrokeGestureRecognizer *)unistrokeGestureRecognizer isEvaluatingStrokePath:(UIBezierPath *)strokePath;
- (void)unistrokeGestureRecognizerDidFailToRecognize:(CMUnistrokeGestureRecognizer *)unistrokeGestureRecognizer;

@end
