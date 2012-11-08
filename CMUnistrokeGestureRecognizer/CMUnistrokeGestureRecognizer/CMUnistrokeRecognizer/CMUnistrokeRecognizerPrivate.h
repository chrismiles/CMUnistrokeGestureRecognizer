//
//  CMUnistrokeRecognizerPrivate.h
//  CMUnistrokeGestureRecognizer
//
//  Created by Chris Miles on 24/09/12.
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

#ifndef CMUnistrokeGestureRecognizer_Private_h
#define CMUnistrokeGestureRecognizer_Private_h

#include "CMUnistrokeRecognizerTypes.h"


struct _CMURPath {
    unsigned int length;	// number of points
    GLKVector2 *pointList;
    unsigned int pointListSize;	// size of array
};

struct _CMURTemplate {
    char *name;
    CMURPathRef path;
    CMURPathRef vector;
};
typedef struct _CMURTemplate *CMURTemplateRef;

typedef struct _CMURTemplates {
    unsigned int length;	    // number of templates
    CMURTemplateRef *templateList;
    unsigned int templateListSize;  // size of array
} CMURTemplates;

typedef struct {
    float x;
    float y;
    float width;
    float height;
} CMURRectangle;


/*
 CMURTemplate functions
 */

CMURTemplateRef
CMURTemplateNew(const char *name, CMURPathRef path);

void
CMURTemplateDelete(CMURTemplateRef template);


/*
 Recognizer helper functions
 */

CMURTemplateRef
unistrokeRecognizerResampledNormalisedTemplate(const char *name, CMURPathRef path, CMUROptionsRef options);

CMURPathRef
unistrokeRecognizerResample(CMURPathRef path, unsigned int sampleSize);

float
unistrokeRecognizerIndicativeAngle(CMURPathRef path);

float
unistrokeRecognizerDistanceAtBestAngle(CMURPathRef path, CMURTemplateRef template, float radiansA, float radiansB, float radiansDelta);

GLKVector2
unistrokeRecognizerCentroid(CMURPathRef path);

CMURPathRef
unistrokeRecognizerRotateBy(CMURPathRef path, float radians);

CMURRectangle
unistrokeRecognizerBoundingBox(CMURPathRef path);

void
unistrokeRecognizerScaleTo(CMURPathRef path, float size);

void
unistrokeRecognizerTranslateTo(CMURPathRef path, GLKVector2 k);

float
unistrokeRecognizerDistanceAtAngle(CMURPathRef path, CMURTemplateRef template, float radians);

float
unistrokeRecognizerPathDistance(CMURPathRef pathA, CMURPathRef pathB);

float
unistrokeRecognizerPathLength(CMURPathRef path);

CMURPathRef
unistrokeRecognizerVectorize(CMURPathRef path);

float
unistrokeRecognizerOptimalCosineDistance(CMURPathRef vector1, CMURPathRef vector2);

#endif
