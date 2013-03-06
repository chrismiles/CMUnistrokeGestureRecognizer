//
//  CMUnistrokeRecognizerTypes.h
//  CMUnistrokeGestureRecognizer
//
//  Created by Chris Miles on 8/10/12.
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

#ifndef CMUnistrokeGestureRecognizer_Types_h
#define CMUnistrokeGestureRecognizer_Types_h

/*
 GLKVector2, from the GLKit framework, is used to represent points so we
 can take advantage of the high performance GLKit math functions.
 */
#include <GLKit/GLKVector2.h>


typedef struct _CMURResult {
    char *name;
    float score;
} CMURResult;

typedef struct _CMUROptions {
    bool useProtractor;
    bool rotationNormalisationDisabled;
} CMUROptions;

typedef struct _CMUROptions *CMUROptionsRef;
typedef struct _CMURPath *CMURPathRef;
typedef struct _CMURResult *CMURResultRef;
typedef struct _CMURTemplates *CMURTemplatesRef;


/*
 CMURTemplates functions
 */

CMURTemplatesRef
CMURTemplatesNew(void);

void
CMURTemplatesDelete(CMURTemplatesRef templates);

void
CMURTemplatesAdd(CMURTemplatesRef templates, const char *name, CMURPathRef path, CMUROptionsRef options);


/*
 CMURPath functions
 */

CMURPathRef
CMURPathNew(void);

CMURPathRef
CMURPathNewWithSize(unsigned int size);

CMURPathRef
CMURPathNewWithPoints(GLKVector2 *points, unsigned int pointsLength);

CMURPathRef
CMURPathCopy(CMURPathRef sourcePath);

void
CMURPathDelete(CMURPathRef path);

void
CMURPathAddPoint(CMURPathRef path, float x, float y);

void
CMURPathReverse(CMURPathRef path);


/*
 CMURResult functions
 */

CMURResultRef
CMURResultNew(char *name, float score);

void
CMURResultDelete(CMURResultRef result);


/*
 CMUROptions functions
 */

CMUROptionsRef
CMUROptionsNew(void);

void
CMUROptionsDelete(CMUROptionsRef options);


#endif /* CMUnistrokeGestureRecognizer_Types_h */
