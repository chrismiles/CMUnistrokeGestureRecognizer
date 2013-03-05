//
//  CMUnistrokeRecognizer.c
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

/**
 * Parts based on JavaScript implemention of the $1 Unistroke Recognizer:
 *
 * Copyright (c) 2007-2011, Jacob O. Wobbrock, Andrew D. Wilson and Yang Li.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the names of the University of Washington nor Microsoft,
 *      nor the names of its contributors may be used to endorse or promote
 *      products derived from this software without specific prior written
 *      permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Jacob O. Wobbrock OR Andrew D. Wilson
 * OR Yang Li BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

#include "CMUnistrokeRecognizer.h"
#include "CMUnistrokeRecognizerPrivate.h"
#include <stdlib.h>
#include <stdbool.h>

#ifndef DEBUG
#define NDEBUG 1
#endif
#include <assert.h>


#define kDefaultPathSampleSize 64

static const float BoundingBoxSize = 250.0f;
static const float theta = 0.7853981634f;	    // 45°
static const float thetaThreshold = 0.034906585f;   // 2°


CMURResultRef
unistrokeRecognizePathFromTemplates(CMURPathRef path, CMURTemplatesRef templates, CMUROptionsRef options)
{
    float b = MAXFLOAT;
    CMURTemplateRef bestTemplate = NULL;
    
    if (path->length < 2) {
	return NULL;
    }
    
    CMURPathRef resampledPath = unistrokeRecognizerResample(path, kDefaultPathSampleSize);
    CMURPathRef normalisedPath;
    
    if (options && options->rotationNormalisationDisabled) {
	normalisedPath = CMURPathCopy(resampledPath);
    }
    else {
	float radians = unistrokeRecognizerIndicativeAngle(resampledPath);
	normalisedPath = unistrokeRecognizerRotateBy(resampledPath, -radians);
    }

    unistrokeRecognizerScaleTo(normalisedPath, BoundingBoxSize);
    GLKVector2 origin = GLKVector2Make(0.0f, 0.0f);
    unistrokeRecognizerTranslateTo(normalisedPath, origin);

    bool useProtractor = (options && options->useProtractor);
    
    CMURPathRef vector = NULL;
    if (useProtractor) vector = unistrokeRecognizerVectorize(normalisedPath);

    for (unsigned int i=0; i<templates->length; i++) {
	CMURTemplateRef template = templates->templateList[i];
	
	float d;
	if (useProtractor) {
	    // Protractor (faster)
	    d = unistrokeRecognizerOptimalCosineDistance(template->vector, vector);
	}
	else {
	    // Golden Section Search (original $1)
	    d = unistrokeRecognizerDistanceAtBestAngle(normalisedPath, template, -theta, theta, thetaThreshold);
	}
	
	if (d < b) {
	    b = d;
	    bestTemplate = template;
	}
    }
    
    CMURResultRef result = NULL;
    if (bestTemplate) {
	float score;
	if (useProtractor) {
	    score = 1.0f - b;
	}
	else {
	    score = 1.0f - b / (0.5f * sqrtf(BoundingBoxSize*BoundingBoxSize + BoundingBoxSize*BoundingBoxSize));
	}
	result = CMURResultNew(bestTemplate->name, score);
    }
    
    CMURPathDelete(normalisedPath);
    CMURPathDelete(resampledPath);
    if (vector) CMURPathDelete(vector);
    
    return result;
}

CMURTemplateRef
unistrokeRecognizerResampledNormalisedTemplate(const char *name, CMURPathRef path, CMUROptionsRef options)
{
    CMURPathRef resampledPath = unistrokeRecognizerResample(path, kDefaultPathSampleSize);
    CMURPathRef normalisedPath;
    
    if (options && options->rotationNormalisationDisabled) {
	normalisedPath = CMURPathCopy(resampledPath);
    }
    else {
	float radians = unistrokeRecognizerIndicativeAngle(resampledPath);
	normalisedPath = unistrokeRecognizerRotateBy(resampledPath, -radians);
    }
    
    unistrokeRecognizerScaleTo(normalisedPath, BoundingBoxSize);
    GLKVector2 origin = GLKVector2Make(0.0f, 0.0f);
    unistrokeRecognizerTranslateTo(normalisedPath, origin);
    
    CMURTemplateRef template = CMURTemplateNew(name, normalisedPath);

    CMURPathDelete(resampledPath);
    CMURPathDelete(normalisedPath);
    
    return template;
}

CMURPathRef
unistrokeRecognizerResample(CMURPathRef path, unsigned int sampleSize)
{
    float I = unistrokeRecognizerPathLength(path) / (float)(sampleSize -1 );
    float D = 0;
    
    CMURPathRef newPath = CMURPathNewWithSize(sampleSize);
    CMURPathAddPoint(newPath, path->pointList[0].x, path->pointList[0].y);
    
    unsigned int i = 1; // points index
    
    GLKVector2 prevPoint = path->pointList[0];
    GLKVector2 currentPoint = path->pointList[1];
    
    while (i < path->length) {
	float d = GLKVector2Distance(prevPoint, currentPoint);
	if (D + d >= I) {
	    float x = prevPoint.x + ((I - D) / d) * (currentPoint.x - prevPoint.x);
	    float y = prevPoint.y + ((I - D) / d) * (currentPoint.y - prevPoint.y);
	    CMURPathAddPoint(newPath, x, y);
	    
	    prevPoint.x = x;
	    prevPoint.y = y;
	    D = 0.0f;
	}
	else {
	    D += d;
	    i++;
	    prevPoint = path->pointList[i-1];
	    currentPoint = path->pointList[i];
	}
    }
    
    // sometimes we fall a rounding-error short of adding the last point, so add it if so
    if (newPath->length == sampleSize - 1) {
	CMURPathAddPoint(newPath, path->pointList[path->length - 1].x, path->pointList[path->length - 1].y);
    }

    return newPath;
}

float
unistrokeRecognizerIndicativeAngle(CMURPathRef path)
{
    GLKVector2 centroid = unistrokeRecognizerCentroid(path);
    float angle = atan2f(centroid.y - path->pointList[0].y, centroid.x - path->pointList[0].x); // for -pi <= angle <= pi
    return angle;
}

float
unistrokeRecognizerDistanceAtBestAngle(CMURPathRef path, CMURTemplateRef template, float radiansA, float radiansB, float radiansDelta)
{
    static float phi = 0.0f;
    
    if (phi == 0.0f) phi = 0.5f * (-1.0f + sqrtf(5.0f));
    
    float x1 = phi * radiansA + (1.0f - phi) * radiansB;
    float f1 = unistrokeRecognizerDistanceAtAngle(path, template, x1);
    float x2 = (1.0f - phi) * radiansA + phi * radiansB;
    float f2 = unistrokeRecognizerDistanceAtAngle(path, template, x2);
    while (fabsf(radiansB - radiansA) > radiansDelta) {
	if (f1 < f2) {
	    radiansB = x2;
	    x2 = x1;
	    f2 = f1;
	    x1 = phi * radiansA + (1.0f - phi) * radiansB;
	    f1 = unistrokeRecognizerDistanceAtAngle(path, template, x1);
	}
	else {
	    radiansA = x1;
	    x1 = x2;
	    f1 = f2;
	    x2 = (1.0f - phi) * radiansA + phi * radiansB;
	    f2 = unistrokeRecognizerDistanceAtAngle(path, template, x2);
	}
    }
    return fminf(f1, f2);
}

GLKVector2
unistrokeRecognizerCentroid(CMURPathRef path)
{
    float sumX = 0;
    float sumY = 0;
    
    for (unsigned int i=0; i < path->length; i++) {
	sumX += path->pointList[i].x;
	sumY += path->pointList[i].y;
    }
    
    GLKVector2 centroid = GLKVector2Make(sumX / (float)path->length, sumY / (float)path->length);
    return centroid;
}

CMURPathRef
unistrokeRecognizerRotateBy(CMURPathRef path, float radians)
{
    CMURPathRef newPath = NULL;
    
    if (path->length > 0) {
	GLKVector2 centroid = unistrokeRecognizerCentroid(path);
	float cos = cosf(radians);
	float sin = sinf(radians);
	
	newPath = CMURPathNewWithSize(path->length);
	for (unsigned int i=0; i < path->length; i++) {
	    GLKVector2 point = path->pointList[i];
	    float x = (point.x - centroid.x) * cos - (point.y - centroid.y) * sin + centroid.x;
	    float y = (point.x - centroid.x) * sin + (point.y - centroid.y) * cos + centroid.y;
	    CMURPathAddPoint(newPath, x, y);
	}
    }
    
    return newPath;
}

CMURRectangle
unistrokeRecognizerBoundingBox(CMURPathRef path)
{
    float minX = MAXFLOAT;
    float minY = MAXFLOAT;
    float maxX = -MAXFLOAT;
    float maxY = -MAXFLOAT;
    
    for (unsigned int i=0; i < path->length; i++) {
	if (path->pointList[i].x < minX) minX = path->pointList[i].x;
	if (path->pointList[i].x > maxX) maxX = path->pointList[i].x;
	if (path->pointList[i].y < minY) minY = path->pointList[i].y;
	if (path->pointList[i].y > maxY) maxY = path->pointList[i].y;
    }
    
    CMURRectangle result;
    result.x = minX;
    result.y = minY;
    result.width = maxX - minX;
    result.height = maxY - minY;
    
    return result;
}

void
unistrokeRecognizerScaleTo(CMURPathRef path, float size)
{
    CMURRectangle box = unistrokeRecognizerBoundingBox(path);
    
    for (unsigned int i=0; i < path->length; i++) {
	path->pointList[i].x *= size / box.width;
	path->pointList[i].y *= size / box.height;
    }
}

void
unistrokeRecognizerTranslateTo(CMURPathRef path, GLKVector2 k)
{
    GLKVector2 centroid = unistrokeRecognizerCentroid(path);
    
    for (unsigned int i=0; i < path->length; i++) {
	path->pointList[i].x += k.x - centroid.x;
	path->pointList[i].y += k.y - centroid.y;
    }
}

float
unistrokeRecognizerDistanceAtAngle(CMURPathRef path, CMURTemplateRef template, float radians)
{
    CMURPathRef rotatedPath = unistrokeRecognizerRotateBy(path, radians);
    
    assert(rotatedPath != NULL);
    if (rotatedPath == NULL) return MAXFLOAT;
    
    float d = unistrokeRecognizerPathDistance(rotatedPath, template->path);
    CMURPathDelete(rotatedPath);
    return d;
}

float
unistrokeRecognizerPathDistance(CMURPathRef pathA, CMURPathRef pathB)
{
    float d = 0.0f;
    
    assert(pathA->length == pathB->length);
    
    for (unsigned int i=0; i < pathA->length; i++) {
	float distance = GLKVector2Distance(pathA->pointList[i], pathB->pointList[i]);
	if (! isnan(distance)) d += distance;
    }
    
    return d / (float)pathA->length;
}

float
unistrokeRecognizerPathLength(CMURPathRef path)
{
    float d = 0.0f;
    for (unsigned int i=1; i < path->length; i++)
	d += GLKVector2Distance(path->pointList[i - 1], path->pointList[i]);
    return d;
}		


/*
 Functions for Protractor
*/

CMURPathRef
unistrokeRecognizerVectorize(CMURPathRef path)
{
    float sum = 0.0f;
    CMURPathRef vector = CMURPathNew();
    for (unsigned int i=0; i < path->length; i++) {
	float x = path->pointList[i].x;
	float y = path->pointList[i].y;
	CMURPathAddPoint(vector, x, y);
	sum += path->pointList[i].x * path->pointList[i].x + path->pointList[i].y * path->pointList[i].y;
    }
    float magnitude = sqrtf(sum);
    float invMagnitude = 1.0f / magnitude;
    
    for (unsigned int i=0; i < vector->length; i++) {
	vector->pointList[i] = GLKVector2MultiplyScalar(vector->pointList[i], invMagnitude);
    }
    return vector;
}

float
unistrokeRecognizerOptimalCosineDistance(CMURPathRef vector1, CMURPathRef vector2)
{
    assert(vector1->length == vector2->length);
    
    float a = 0.0f;
    float b = 0.0f;
    for (unsigned int i = 0; i < vector1->length; i++)
    {
	a += vector1->pointList[i].x * vector2->pointList[i].x + vector1->pointList[i].y * vector2->pointList[i].y;
	b += vector1->pointList[i].x * vector2->pointList[i].y - vector1->pointList[i].y * vector2->pointList[i].x;
    }
    float angle = atanf(b / a);
    float z = a * cosf(angle) + b * sinf(angle);
    float distance = acosf(z);
    return distance;
}
