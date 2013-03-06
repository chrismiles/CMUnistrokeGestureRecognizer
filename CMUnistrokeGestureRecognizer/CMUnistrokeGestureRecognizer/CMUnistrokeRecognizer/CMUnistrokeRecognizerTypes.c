//
//  CMUnistrokeRecognizerTypes.c
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

#include <stdlib.h>
#include <string.h>

#include "CMUnistrokeRecognizerTypes.h"
#include "CMUnistrokeRecognizerPrivate.h"

#define kDefaultPathArraySize 32
#define kDefaultTemplatesArraySize 4


#pragma mark - struct CMURTemplates

CMURTemplatesRef
CMURTemplatesNew(void)
{
    CMURTemplatesRef templates = malloc(sizeof(CMURTemplates));

    templates->templateListSize = kDefaultTemplatesArraySize;
    templates->templateList = malloc(kDefaultTemplatesArraySize * sizeof(CMURTemplateRef));
    templates->length = 0;

    return templates;
}

void
CMURTemplatesDelete(CMURTemplatesRef templates)
{
    if (NULL == templates) return;

    if (templates->templateList) {
	for (unsigned int i=0; i < templates->length; i++) {
	    CMURTemplateDelete(templates->templateList[i]);
	}
	free(templates->templateList);
	templates->templateList = NULL;
    }
    templates->length = 0;
    templates->templateListSize = 0;
    
    free(templates);
}

void
CMURTemplatesAdd(CMURTemplatesRef templates, const char *name, CMURPathRef path, CMUROptionsRef options)
{
    if (templates->length >= templates->templateListSize) {
	templates->templateListSize *= 2;
	templates->templateList = realloc(templates->templateList, templates->templateListSize * sizeof(CMURTemplateRef));
    }
    
    CMURTemplateRef template = unistrokeRecognizerResampledNormalisedTemplate(name, path, options);
    template->vector = unistrokeRecognizerVectorize(template->path);
    
    templates->templateList[templates->length++] = template;
}


#pragma mark - CMURPath

CMURPathRef
CMURPathNew(void)
{
    return CMURPathNewWithSize(kDefaultPathArraySize);
}

CMURPathRef
CMURPathNewWithSize(unsigned int size)
{
    CMURPathRef path = malloc(sizeof(struct _CMURPath));
    path->length = 0;
    path->pointListSize = size;
    path->pointList = malloc(path->pointListSize * sizeof(GLKVector2));
    return path;
}

CMURPathRef
CMURPathNewWithPoints(GLKVector2 *points, unsigned int pointsLength)
{
    CMURPathRef path = CMURPathNewWithSize(pointsLength);
    for (unsigned int i=0; i<pointsLength; i++) {
	path->pointList[i] = points[i];
    }
    path->length = pointsLength;
    return path;
}

CMURPathRef
CMURPathCopy(CMURPathRef sourcePath)
{
    CMURPathRef copiedPath = CMURPathNewWithPoints(sourcePath->pointList, sourcePath->length);
    return copiedPath;
}

void
CMURPathDelete(CMURPathRef path)
{
    if (NULL == path) return;

    if (path->pointList) {
	free(path->pointList);
	path->pointList = NULL;
    }
    path->length = 0;
    path->pointListSize = 0;
    
    free(path);
}

void
CMURPathAddPoint(CMURPathRef path, float x, float y)
{
    if (path->length >= path->pointListSize) {
	path->pointListSize *= 2;
	path->pointList = realloc(path->pointList, path->pointListSize * sizeof(GLKVector2));
    }
    
    GLKVector2 vector = GLKVector2Make(x, y);
    path->pointList[path->length++] = vector;
}

void
CMURPathReverse(CMURPathRef path)
{
    for (unsigned int i=0; i<path->length/2; i++) {
	unsigned int indexA = i;
	unsigned int indexB = path->length-i-1;
	
	GLKVector2 pointA = path->pointList[indexA];
	GLKVector2 pointB = path->pointList[indexB];
	
	path->pointList[indexB] = pointA;
	path->pointList[indexA] = pointB;
    }
}


#pragma mark - CMURTemplate

CMURTemplateRef
CMURTemplateNew(const char *name, CMURPathRef path)
{
    CMURTemplateRef template = malloc(sizeof(struct _CMURTemplate));
    
    size_t nameSize = strlen(name);
    template->name = calloc(nameSize+1, sizeof(char));
    strncpy(template->name, name, nameSize);

    template->path = CMURPathCopy(path);
    template->vector = NULL;
    
    return template;
}

void
CMURTemplateDelete(CMURTemplateRef template)
{
    if (NULL == template) return;
    
    if (template->path) {
	CMURPathDelete(template->path);
	template->path = NULL;
    }
    if (template->name) {
	free(template->name);
	template->name = NULL;
    }
    if (template->vector) {
	CMURPathDelete(template->vector);
	template->vector = NULL;
    }
}


#pragma mark - Result

CMURResultRef
CMURResultNew(char *name, float score)
{
    CMURResultRef result = malloc(sizeof(struct _CMURResult));
    
    if (name) {
	size_t nameSize = strlen(name);
	result->name = calloc(nameSize+1, sizeof(char));
	strncpy(result->name, name, nameSize);
    }
    else {
	result->name = NULL;
    }
    
    result->score = score;
    
    return result;
}

void
CMURResultDelete(CMURResultRef result)
{
    if (NULL == result) return;
    
    if (result->name) {
	free(result->name);
	result->name = NULL;
    }
    result->score = 0.0f;
    
    free(result);
}


#pragma mark - Options

CMUROptionsRef
CMUROptionsNew(void)
{
    CMUROptionsRef options = calloc(1, sizeof(struct _CMUROptions));
    return options;
}

void
CMUROptionsDelete(CMUROptionsRef options)
{
    if (NULL == options) return;
    
    free(options);
}
