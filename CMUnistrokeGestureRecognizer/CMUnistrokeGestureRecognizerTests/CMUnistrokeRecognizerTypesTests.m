//
//  CMUnistrokeRecognizerTypesTests.m
//  CMUnistrokeGestureRecognizer
//
//  Created by Chris Miles on 13/10/12.
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

#import "CMUnistrokeRecognizerTypesTests.h"
#import "CMUnistrokeRecognizerPrivate.h"
#import "CMUnistrokeRecognizerTypes.h"

@implementation CMUnistrokeRecognizerTypesTests

- (void)testCMURTemplatesNew
{
    CMURTemplatesRef templates = CMURTemplatesNew();
    STAssertTrue(templates != NULL, @"CMURTemplatesNew() returned NULL");
    CMURTemplatesDelete(templates);
}

- (void)testCMURTemplatesAdd
{
    CMURTemplatesRef templates = CMURTemplatesNew();
    
    STAssertEquals(templates->length, (unsigned int)0, @"Incorrect initial templates length");
    
    CMURPathRef path1 = CMURPathNew();
    CMURTemplatesAdd(templates, "template1", path1, NULL);
    CMURPathDelete(path1);
    
    STAssertEquals(templates->length, (unsigned int)1, @"Incorrect templates length after CMURTemplatesAdd()");
    
    CMURTemplatesDelete(templates);
}

- (void)testCMURPathNew
{
    CMURPathRef path = CMURPathNew();
    STAssertTrue(path != NULL, @"CMURPathNew() returned NULL");
    CMURPathDelete(path);
}

- (void)testCMURPathNewWithSize
{
    CMURPathRef path = CMURPathNewWithSize(103);
    STAssertTrue(path != NULL, @"CMURPathNewWithSize() returned NULL");
    STAssertEquals(path->pointListSize, (unsigned int)103, @"Incorrect path pointListSize");
    CMURPathDelete(path);
}

- (void)testCMURPathNewWithPoints
{
#define pathLength 3
    GLKVector2 points[pathLength] = {
	GLKVector2Make(0.0f, 0.0f),
	GLKVector2Make(10.0f, 5.0f),
	GLKVector2Make(5.0f, 10.0f),
    };

    CMURPathRef path = CMURPathNewWithPoints(points, pathLength);
    STAssertTrue(path != NULL, @"CMURPathNewWithPoints() returned NULL");
    STAssertEquals(path->length, (unsigned int)pathLength, @"Incorrect path length");
    CMURPathDelete(path);
}

- (void)testCMURPathCopy
{
#define pathLength 3
    GLKVector2 points[pathLength] = {
	GLKVector2Make(0.0f, 0.0f),
	GLKVector2Make(10.0f, 5.0f),
	GLKVector2Make(5.0f, 10.0f),
    };
    
    CMURPathRef path1 = CMURPathNewWithPoints(points, pathLength);
    CMURPathRef path2 = CMURPathCopy(path1);
    STAssertTrue(path2 != NULL, @"CMURPathCopy() returned NULL");
    STAssertEquals(path2->length, (unsigned int)pathLength, @"Incorrect path length");
    CMURPathDelete(path1);
    CMURPathDelete(path2);
}

- (void)testCMURPathAddPoint
{
#define pathLength 3
    GLKVector2 points[pathLength] = {
	GLKVector2Make(0.0f, 0.0f),
	GLKVector2Make(10.0f, 5.0f),
	GLKVector2Make(5.0f, 10.0f),
    };
    
    CMURPathRef path = CMURPathNewWithPoints(points, pathLength);
    CMURPathAddPoint(path, 12.0f, 13.0f);
    STAssertEquals(path->length, (unsigned int)(pathLength + 1), @"Incorrect path length after CMURPathAddPoint()");
    CMURPathDelete(path);
}

- (void)testCMURTemplateNew
{
#define pathLength 3
    GLKVector2 points[pathLength] = {
	GLKVector2Make(0.0f, 0.0f),
	GLKVector2Make(10.0f, 5.0f),
	GLKVector2Make(5.0f, 10.0f),
    };
    CMURPathRef path = CMURPathNewWithPoints(points, pathLength);
    CMURTemplateRef template = CMURTemplateNew("testTemplate", path);
    
    STAssertTrue(template != NULL, @"CMURTemplateNew() returned NULL");
    STAssertEquals(template->path->length, path->length, @"Incorrect template path length");
    STAssertEquals(strcmp(template->name, "testTemplate"), 0, @"Incorrect template name");
    
    CMURPathDelete(path);
    CMURTemplateDelete(template);
}

- (void)testCMURResultNew
{
    CMURResultRef result = CMURResultNew("testResult", 0.85f);
    STAssertEquals(result->score, 0.85f, @"Incorrect result score");
    STAssertEquals(strcmp(result->name, "testResult"), 0, @"Incorrect result name");
    CMURResultDelete(result);
}

- (void)testCMUROptionsNew
{
    CMUROptionsRef options = CMUROptionsNew();
    STAssertTrue(options != NULL, @"CMUROptionsNew() returned NULL");
    
    if (options) {
	options->rotationNormalisationDisabled = true;
	options->useProtractor = true;
    }
    
    CMUROptionsDelete(options);
}

@end
