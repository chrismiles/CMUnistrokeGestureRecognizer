//
//  CMUnistrokeRecognizerTests.m
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

#import "CMUnistrokeRecognizerTests.h"
#import "CMUnistrokeRecognizer.h"
#import "CMUnistrokeRecognizerPrivate.h"
#import <GLKit/GLKMath.h>

#define FloatComparisonAccuracy 0.001f

@implementation CMUnistrokeRecognizerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testUnistrokeRecognizePathFromTemplates
{
    CMURTemplatesRef templates = CMURTemplatesNew();

    CMURPathRef templatePath1 = CMURPathNew();
    CMURPathRef templatePath2 = CMURPathNew();
    CMURPathRef templatePath3 = CMURPathNew();
    
    CMURPathAddPoint(templatePath1, 5.0f, 5.0f);
    CMURPathAddPoint(templatePath1, 15.0f, 10.0f);
    CMURPathAddPoint(templatePath1, 10.0f, 15.0f);
    
    CMURPathAddPoint(templatePath2, 0.0f, 0.0f);
    CMURPathAddPoint(templatePath2, 15.0f, 0.0f);
    CMURPathAddPoint(templatePath2, 0.0f, 15.0f);

    CMURPathAddPoint(templatePath3, 15.0f, 0.0f);
    CMURPathAddPoint(templatePath3, 0.0f, 0.0f);
    CMURPathAddPoint(templatePath3, 0.0f, 15.0f);
    
    CMURTemplatesAdd(templates, "template1", templatePath1, NULL);
    CMURTemplatesAdd(templates, "template2", templatePath2, NULL);
    CMURTemplatesAdd(templates, "template3", templatePath3, NULL);
    
    CMURPathDelete(templatePath1); templatePath1 = NULL;
    CMURPathDelete(templatePath2); templatePath2 = NULL;
    CMURPathDelete(templatePath3); templatePath3 = NULL;
    
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 1.0f, 0.5f);
    CMURPathAddPoint(path, 9.7f, 6.1f);
    CMURPathAddPoint(path, 4.8f, 10.3f);
    
    {
	// Disable Protractor (i.e. use Golden Section Search)
	CMURResultRef result = unistrokeRecognizePathFromTemplates(path, templates, NULL);
	
	STAssertEqualsWithAccuracy(result->score, 0.992384f, FloatComparisonAccuracy, @"unistrokeRecognizePathFromTemplates() returned invalid result score");
	STAssertTrue(strcmp(result->name, "template1") == 0, @"unistrokeRecognizePathFromTemplates() returned invalid result name");
	
	CMURResultDelete(result);
    }
    

    {
	// Enable Protractor
	CMUROptionsRef options = CMUROptionsNew();
	options->useProtractor = true;
	CMURResultRef result = unistrokeRecognizePathFromTemplates(path, templates, options);
	
	STAssertEqualsWithAccuracy(result->score, 0.987671f, FloatComparisonAccuracy, @"unistrokeRecognizePathFromTemplates() returned invalid result score");
	STAssertTrue(strcmp(result->name, "template1") == 0, @"unistrokeRecognizePathFromTemplates() returned invalid result name");
	
	CMURResultDelete(result);
	CMUROptionsDelete(options);
    }
    
    CMURTemplatesDelete(templates); templates = NULL;
    CMURPathDelete(path);
};

- (void)testUnistrokeRecognizerResample8
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);
    
    const unsigned int resampleLength = 8;
    CMURPathRef resampledPath = unistrokeRecognizerResample(path, resampleLength);
    
    STAssertEquals(resampleLength, resampledPath->length, @"Resampled path length not equal to requested length");

    GLKVector2 expectedPoints[resampleLength] = {
	GLKVector2Make(0.0f, 0.0f),
	GLKVector2Make(2.33207933f, 1.16603967f),
	GLKVector2Make(4.66415866f, 2.33207933f),
	GLKVector2Make(6.99623799f, 3.49811900f),
	GLKVector2Make(9.32831733f, 4.66415866f),
	GLKVector2Make(8.68734119f, 6.31265881f),
	GLKVector2Make(6.84367059f, 8.15632941f),
	GLKVector2Make(5.0f, 10.0f),
    };
    
    for (unsigned int i=0; i<resampledPath->length; i++) {
	STAssertEqualsWithAccuracy(resampledPath->pointList[i].x, expectedPoints[i].x, FloatComparisonAccuracy, @"unistrokeRecognizerResample() returned incorrect value: %@ != %@", NSStringFromGLKVector2(resampledPath->pointList[i]), NSStringFromGLKVector2(expectedPoints[i]));
	STAssertEqualsWithAccuracy(resampledPath->pointList[i].y, expectedPoints[i].y, FloatComparisonAccuracy, @"unistrokeRecognizerResample() returned incorrect value: %@ != %@", NSStringFromGLKVector2(resampledPath->pointList[i]), NSStringFromGLKVector2(expectedPoints[i]));
    }

    CMURPathDelete(path);
    CMURPathDelete(resampledPath);
}

- (void)testUnistrokeRecognizerResample64Length
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 15.0f, 0.0f);
    CMURPathAddPoint(path, 0.0f, 15.0f);
    
    const unsigned int resampleLength = 64;
    CMURPathRef resampledPath = unistrokeRecognizerResample(path, resampleLength);
    
    STAssertEquals(resampleLength, resampledPath->length, @"Resampled path length not equal to requested length");
    
    CMURPathDelete(path);
    CMURPathDelete(resampledPath);
}

- (void)testUnistrokeRecognizerIndicativeAngle
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);
    
    float angle = unistrokeRecognizerIndicativeAngle(path);
    CMURPathDelete(path);
    
    float expectedAngle = 0.785398f;
    
    STAssertEqualsWithAccuracy(angle, expectedAngle, FloatComparisonAccuracy, @"testUnistrokeRecognizerIndicativeAngle() returned incorrect value");
}

- (void)testUnistrokeRecognizerDistanceAtBestAngle
{
    CMURPathRef pathA = CMURPathNew();
    CMURPathAddPoint(pathA, 0.0f, 0.0f);
    CMURPathAddPoint(pathA, 10.0f, 5.0f);
    CMURPathAddPoint(pathA, 5.0f, 10.0f);

    CMURPathRef pathB = CMURPathNew();
    CMURPathAddPoint(pathB, 5.0f, 5.0f);
    CMURPathAddPoint(pathB, 15.0f, 10.0f);
    CMURPathAddPoint(pathB, 10.0f, 15.0f);
    
    CMURTemplateRef template = CMURTemplateNew("template", pathB);

    float distance = unistrokeRecognizerDistanceAtBestAngle(pathA, template, GLKMathDegreesToRadians(-45.0f), GLKMathDegreesToRadians(45.0f), GLKMathDegreesToRadians(0.1f));
    CMURTemplateDelete(template);
    CMURPathDelete(pathA);
    CMURPathDelete(pathB);
    
    float expectedDistance = 7.071068f;
    
    STAssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, @"unistrokeRecognizerDistanceAtBestAngle() returned incorrect value");
}

- (void)testUnistrokeRecognizerPathDistance
{
    CMURPathRef pathA = CMURPathNew();
    CMURPathAddPoint(pathA, 0.0f, 0.0f);
    CMURPathAddPoint(pathA, 10.0f, 5.0f);
    CMURPathAddPoint(pathA, 5.0f, 10.0f);
    
    CMURPathRef pathB = CMURPathNew();
    CMURPathAddPoint(pathB, 5.0f, 5.0f);
    CMURPathAddPoint(pathB, 15.0f, 10.0f);
    CMURPathAddPoint(pathB, 10.0f, 15.0f);

    float pathDistance = unistrokeRecognizerPathDistance(pathA, pathB);
    
    CMURPathDelete(pathA);
    CMURPathDelete(pathB);
    
    float expectedDistance = sqrtf(5.0f*5.0f + 5.0f*5.0f);
    
    STAssertEqualsWithAccuracy(pathDistance, expectedDistance, FloatComparisonAccuracy, @"unistrokeRecognizerPathDistance() returned incorrect value");
}

- (void)testunistrokeRecognizerPathLength
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    float length = unistrokeRecognizerPathLength(path);
    CMURPathDelete(path);
    
    float expectedLength = 18.2514077f;
    
    STAssertEqualsWithAccuracy(length, expectedLength, FloatComparisonAccuracy, @"testunistrokeRecognizerPathLength() returned incorrect value");
}

- (void)testUnistrokeRecognizerCentroid
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    GLKVector2 centroid = unistrokeRecognizerCentroid(path);
    CMURPathDelete(path);
    
    GLKVector2 expected = GLKVector2Make(5.0f, 5.0f);
    
    STAssertEqualsWithAccuracy(centroid.x, expected.x, FloatComparisonAccuracy, @"unistrokeRecognizerCentroid() returned incorrect value");
    STAssertEqualsWithAccuracy(centroid.y, expected.y, FloatComparisonAccuracy, @"unistrokeRecognizerCentroid() returned incorrect value");
}

- (void)testUnistrokeRecognizerDistanceAtAngle
{
    CMURPathRef pathA = CMURPathNew();
    CMURPathAddPoint(pathA, 0.0f, 0.0f);
    CMURPathAddPoint(pathA, 10.0f, 5.0f);
    CMURPathAddPoint(pathA, 5.0f, 10.0f);
    
    CMURPathRef pathB = CMURPathNew();
    CMURPathAddPoint(pathB, 5.0f, 5.0f);
    CMURPathAddPoint(pathB, 15.0f, 10.0f);
    CMURPathAddPoint(pathB, 10.0f, 15.0f);
    
    CMURTemplateRef template = CMURTemplateNew("template", pathB);
    
    float distance = unistrokeRecognizerDistanceAtAngle(pathA, template, GLKMathDegreesToRadians(12.0f));
    
    CMURPathDelete(pathA);
    CMURPathDelete(pathB);
    CMURTemplateDelete(template);
    
    float expectedDistance = 7.148788f;
    
    STAssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, @"unistrokeRecognizerDistanceAtAngle() returned incorrect value");
}

- (void)testUnistrokeRecognizerRotateBy
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    CMURPathRef rotatedPath = unistrokeRecognizerRotateBy(path, GLKMathDegreesToRadians(12.0f));
    
    CMURPathRef expectedPath = CMURPathNew();
    CMURPathAddPoint(expectedPath, 1.14882f, -0.930296f);
    CMURPathAddPoint(expectedPath, 9.89074f, 6.03956f);
    CMURPathAddPoint(expectedPath, 3.96044f, 9.89074f);

    for (unsigned int i=0; i < rotatedPath->length; i++) {
	STAssertEqualsWithAccuracy(rotatedPath->pointList[i].x, expectedPath->pointList[i].x, FloatComparisonAccuracy, @"unistrokeRecognizerRotateBy() returned incorrect value: %@ != %@", NSStringFromGLKVector2(rotatedPath->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
	STAssertEqualsWithAccuracy(rotatedPath->pointList[i].y, expectedPath->pointList[i].y, FloatComparisonAccuracy, @"unistrokeRecognizerRotateBy() returned incorrect value: %@ != %@", NSStringFromGLKVector2(rotatedPath->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
    }
    
    CMURPathDelete(rotatedPath);
    CMURPathDelete(expectedPath);
    CMURPathDelete(path);
}

- (void)testUnistrokeRecognizerBoundingBox
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    CMURRectangle box = unistrokeRecognizerBoundingBox(path);
    
    CMURPathDelete(path);
    
    STAssertEqualsWithAccuracy(box.x, 0.0f, FloatComparisonAccuracy, @"testUnistrokeRecognizerBoundingBox() returned incorrect value x: %f != %f", box.x, 0.0f);
    STAssertEqualsWithAccuracy(box.y, 0.0f, FloatComparisonAccuracy, @"testUnistrokeRecognizerBoundingBox() returned incorrect value y: %f != %f", box.y, 0.0f);
    STAssertEqualsWithAccuracy(box.width, 10.0f, FloatComparisonAccuracy, @"testUnistrokeRecognizerBoundingBox() returned incorrect value width: %f != %f", box.width, 10.0f);
    STAssertEqualsWithAccuracy(box.height, 10.0f, FloatComparisonAccuracy, @"testUnistrokeRecognizerBoundingBox() returned incorrect value height: %f != %f", box.height, 10.0f);
}

- (void)testUnistrokeRecognizerScaleTo
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);
    
    unistrokeRecognizerScaleTo(path, 250.0f);
    
    CMURPathRef expectedPath = CMURPathNew();
    CMURPathAddPoint(expectedPath, 0.0f, 0.0f);
    CMURPathAddPoint(expectedPath, 250.0f, 125.0f);
    CMURPathAddPoint(expectedPath, 125.0f, 250.0f);

    for (unsigned int i=0; i < path->length; i++) {
	STAssertEqualsWithAccuracy(path->pointList[i].x, expectedPath->pointList[i].x, FloatComparisonAccuracy, @"testUnistrokeRecognizerScaleTo() returned incorrect value: %@ != %@", NSStringFromGLKVector2(path->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
	STAssertEqualsWithAccuracy(path->pointList[i].y, expectedPath->pointList[i].y, FloatComparisonAccuracy, @"testUnistrokeRecognizerScaleTo() returned incorrect value: %@ != %@", NSStringFromGLKVector2(path->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
    }
    
    CMURPathDelete(path);
    CMURPathDelete(expectedPath);
}

- (void)testUnistrokeRecognizerTranslateTo
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    GLKVector2 offset = GLKVector2Make(25.0f, 35.0f);
    
    unistrokeRecognizerTranslateTo(path, offset);
    
    CMURPathRef expectedPath = CMURPathNew();
    CMURPathAddPoint(expectedPath, 20.0f, 30.0f);
    CMURPathAddPoint(expectedPath, 30.0f, 35.0f);
    CMURPathAddPoint(expectedPath, 25.0f, 40.0f);

    for (unsigned int i=0; i < path->length; i++) {
	STAssertEqualsWithAccuracy(path->pointList[i].x, expectedPath->pointList[i].x, FloatComparisonAccuracy, @"testUnistrokeRecognizerTranslateTo() returned incorrect value: %@ != %@", NSStringFromGLKVector2(path->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
	STAssertEqualsWithAccuracy(path->pointList[i].y, expectedPath->pointList[i].y, FloatComparisonAccuracy, @"testUnistrokeRecognizerTranslateTo() returned incorrect value: %@ != %@", NSStringFromGLKVector2(path->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
    }
    
    CMURPathDelete(path);
    CMURPathDelete(expectedPath);
}

- (void)testUnistrokeRecognizerVectorize
{
    CMURPathRef path = CMURPathNew();
    CMURPathAddPoint(path, 0.0f, 0.0f);
    CMURPathAddPoint(path, 10.0f, 5.0f);
    CMURPathAddPoint(path, 5.0f, 10.0f);

    CMURPathRef vectorized = unistrokeRecognizerVectorize(path);
    
    CMURPathRef expectedPath = CMURPathNew();
    CMURPathAddPoint(expectedPath, 0.0f, 0.0f);
    CMURPathAddPoint(expectedPath, 0.632456f, 0.316228f);
    CMURPathAddPoint(expectedPath, 0.316228f, 0.632456f);
    
    for (unsigned int i=0; i < vectorized->length; i++) {
	STAssertEqualsWithAccuracy(vectorized->pointList[i].x, expectedPath->pointList[i].x, FloatComparisonAccuracy, @"testUnistrokeRecognizerVectorize() returned incorrect value: %@ != %@", NSStringFromGLKVector2(vectorized->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
	STAssertEqualsWithAccuracy(vectorized->pointList[i].y, expectedPath->pointList[i].y, FloatComparisonAccuracy, @"testUnistrokeRecognizerVectorize() returned incorrect value: %@ != %@", NSStringFromGLKVector2(vectorized->pointList[i]), NSStringFromGLKVector2(expectedPath->pointList[i]));
    }
    
    CMURPathDelete(vectorized);
    CMURPathDelete(path);
}

- (void)testUnistrokeRecognizerOptimalCosineDistance
{
    CMURPathRef pathA = CMURPathNew();
    CMURPathAddPoint(pathA, 0.0f, 0.0f);
    CMURPathAddPoint(pathA, 10.0f, 5.0f);
    CMURPathAddPoint(pathA, 5.0f, 10.0f);

    CMURPathRef pathB = CMURPathNew();
    CMURPathAddPoint(pathB, 1.0f, 2.0f);
    CMURPathAddPoint(pathB, 9.0f, 4.5f);
    CMURPathAddPoint(pathB, 5.0f, 11.0f);
    
    CMURPathRef vectorA = unistrokeRecognizerVectorize(pathA);
    CMURPathRef vectorB = unistrokeRecognizerVectorize(pathB);
    
    float distance = unistrokeRecognizerOptimalCosineDistance(vectorA, vectorB);
    
    CMURPathDelete(pathA);
    CMURPathDelete(pathB);
    CMURPathDelete(vectorA);
    CMURPathDelete(vectorB);
    
    float expectedDistance = 0.1688662f;
    
    STAssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, @"testUnistrokeRecognizerOptimalCosineDistance() returned incorrect value");
}

@end
