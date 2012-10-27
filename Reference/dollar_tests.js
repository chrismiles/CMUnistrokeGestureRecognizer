//
//  Unit tests for JavaScript reference implementation of $1 Unistroke Recognizer
//
//  Open dollar_tests.html in a web browser to execute tests. See browser's
//  JavaScript console for test output.
//
//  Copyright (c) 2012 Chris Miles. All rights reserved.
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


////////////////////////////////////////////////////
// Simplified Recognizer
////////////////////////////////////////////////////

function SimpleRecognize(points, templates)
{
    var b = +Infinity;
    var t = 0;
    for (var i = 0; i < templates.length; i++) // for each unistroke template
    {
        // Golden Section Search (original $1)
        var d = DistanceAtBestAngle(points, templates[i], -AngleRange, +AngleRange, AnglePrecision);

        if (d < b)
        {
            b = d; // best (least) distance
            t = i; // unistroke template
        }
    }
    return new Result(templates[t].Name, 1.0 - b / HalfDiagonal);
}


////////////////////////////////////////////////////
// Testing Framework
////////////////////////////////////////////////////


function AssertEqualsWithAccuracy(value1, value2, accuracy, description)
{
    if (Math.abs(value1 - value2) <= accuracy) {
        // TRUE
        console.log(description + " OK")
        return 0;
    }
    else {
        // FALSE
        console.log(description + " FAILED: " + value1 + " != " + value2);
        return 1;
    }
}

function AssertEqual(value1, value2, description)
{
    if (value1 == value2) {
        // TRUE
        console.log(description + " OK")
        return 0;
    }
    else {
        // FALSE
        console.log(description + " FAILED: " + value1 + " != " + value2);
        return 1;
    }
}


////////////////////////////////////////////////////
// Tests
////////////////////////////////////////////////////

var FloatComparisonAccuracy = 0.001;

function RecognizeTests()
{
    // var templates = new Array();
    // templates[0] = new Template("template1", new Array(new Point(5,5),new Point(15,10),new Point(10,15)));
    // templates[1] = new Template("template2", new Array(new Point(0,0),new Point(15,0),new Point(0,15)));
    // templates[2] = new Template("template3", new Array(new Point(15,0),new Point(0,0),new Point(0,15)));

    var recognizer = new DollarRecognizer();
    
    // Clear the built-in templates for our test
    recognizer.Templates = new Array();
    
	recognizer.AddTemplate("template1", new Array(new Point(5,5),new Point(15,10),new Point(10,15)));
    recognizer.AddTemplate("template2", new Array(new Point(0,0),new Point(15,0),new Point(0,15)));
    recognizer.AddTemplate("template3", new Array(new Point(15,0),new Point(0,0),new Point(0,15)));
    
    var failures = 0;
    
    var points = new Array(new Point(1,0.5),new Point(9.7,6.1),new Point(4.8,10.3));
    var useProtractor = false;
    var result = recognizer.Recognize(points, useProtractor);
    var expectedResult = 0.992384;
    failures += AssertEqualsWithAccuracy(result.Score, expectedResult, FloatComparisonAccuracy, "RecognizeTests");
    failures += AssertEqual(result.Name, "template1", "RecognizeTests");
    
    var points = new Array(new Point(1,0.5),new Point(9.7,6.1),new Point(4.8,10.3));
    var useProtractor = true;
    var result = recognizer.Recognize(points, useProtractor);
    var expectedResult = 81.197183;
    failures += AssertEqualsWithAccuracy(result.Score, expectedResult, FloatComparisonAccuracy, "RecognizeTests");
    failures += AssertEqual(result.Name, "template1", "RecognizeTests");
    
    return failures;
}

function Resample8Tests()
{
    var points = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    var resampledPoints = Resample(points, 8);

    failures += AssertEqual(8, resampledPoints.length, "Resample8Tests");
    
    var expectedPoints = new Array(
		new Point(0.0, 0.0),
		new Point(2.33207933, 1.16603967),
		new Point(4.66415866, 2.33207933),
		new Point(6.99623799, 3.49811900),
		new Point(9.32831733, 4.66415866),
		new Point(8.68734119, 6.31265881),
		new Point(6.84367059, 8.15632941),
		new Point(5.00000000, 10.00000000)
    );
    
    var failures = 0;
    for (var i=0; i<expectedPoints.length; i++) {
        failures += AssertEqualsWithAccuracy(resampledPoints[i].X, expectedPoints[i].X, FloatComparisonAccuracy, "Resample8Tests");
        failures += AssertEqualsWithAccuracy(resampledPoints[i].Y, expectedPoints[i].Y, FloatComparisonAccuracy, "Resample8Tests");
    }
    
    return failures;
}

function Resample64LengthTests()
{
    var points = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    var resampledPoints = Resample(points, 64);

    var failures = 0;
    failures += AssertEqual(64, resampledPoints.length, "Resample64Tests");
    
    return failures;
}

function SimpleRecognizeTests()
{
    var pathA = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    var template1Points = new Array(new Point(5.0, 5.0),new Point(15.0, 10.0),new Point(10.0, 15.0));
    var template2Points = new Array(new Point(0.0, 0.0),new Point(15.0, 0.0),new Point(0.0, 15.0));
    var template3Points = new Array(new Point(15.0, 0.0),new Point(0.0, 0.0),new Point(0.0, 15.0));
    
    var template1 = new Template("template1", new Array(new Point(0.0, 0.0)) );
    template1.Points = new Array(new Point(5.0, 5.0),new Point(15.0, 10.0),new Point(10.0, 15.0)); // override resampled points
    
    var template2 = new Template("template2", new Array(new Point(0.0, 0.0)) );
    template2.Points = new Array(new Point(0.0, 0.0),new Point(15.0, 0.0),new Point(0.0, 15.0)); // override resampled points
    
    var template3 = new Template("template3", new Array(new Point(0.0, 0.0)) );
    template3.Points = new Array(new Point(15.0, 0.0),new Point(0.0, 0.0),new Point(0.0, 15.0)); // override resampled points
    
    var templates = new Array( template1, template2, template3 );
    
    var result = SimpleRecognize(pathA, templates);
    
    var failures = 0;
    failures += AssertEqualsWithAccuracy(result.Score, 0.973301, FloatComparisonAccuracy, "SimpleRecognizeTests()");
    failures += AssertEqual(result.Name, "template2", "SimpleRecognizeTests()");
    return failures;
}

function DistanceAtBestAngleTests()
{
    var points = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    
    var template1 = new Template("template1", new Array(new Point(0.0, 0.0)) );
    template1.Points = new Array(new Point(5.0, 5.0),new Point(15.0, 10.0),new Point(10.0, 15.0)); // override resampled points
    
    var distance = DistanceAtBestAngle(points, template1, Deg2Rad(-45.0), Deg2Rad(45.0), Deg2Rad(0.1));
    var expectedDistance = 7.071068;
    
    return AssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, "DistanceAtBestAngle");
}

function PathDistanceTests()
{
    var pathA = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    var pathB = new Array(new Point(5.0, 5.0),new Point(15.0, 10.0),new Point(10.0, 15.0));
    
    var pathDistance = PathDistance(pathA, pathB);
    var expectedDistance = Math.sqrt(5.0*5.0 + 5.0*5.0);

    return AssertEqualsWithAccuracy(pathDistance, expectedDistance, FloatComparisonAccuracy, "PathDistanceTests");
}

function PathLengthTests()
{
  var path = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    
  var length = PathLength(path);
  var expectedLength = 18.2514077;

  return AssertEqualsWithAccuracy(length, expectedLength, FloatComparisonAccuracy, "PathLengthTests");
}

function CentroidTests()
{
    var pathA = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));

    var centroid = Centroid(pathA);
    
    var expected = new Point(5.0, 5.0);
    
    var failures = 0;
    failures += AssertEqualsWithAccuracy(centroid.X, expected.X, FloatComparisonAccuracy, "Centroid");
    failures += AssertEqualsWithAccuracy(centroid.Y, expected.Y, FloatComparisonAccuracy, "Centroid");
    return failures;
}

function DistanceAtAngleTests()
{
    var pathA = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    
    var template1 = new Template("template1", new Array(new Point(0.0, 0.0)) );
    template1.Points = new Array(new Point(5.0, 5.0),new Point(15.0, 10.0),new Point(10.0, 15.0)); // override resampled points
    
    var distance = DistanceAtAngle(pathA, template1, Deg2Rad(12.0));
    var expectedDistance = 7.148788;
    
    return AssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, "DistanceAtAngleTests");
}

function RotateByTests()
{
    var path = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
    var rotatedPath = RotateBy(path, Deg2Rad(12.0));
    
    var expectedPath = new Array(new Point(1.14882, -0.930296), new Point(9.89074, 6.03956), new Point(3.96044, 9.89074));
    
    var failures = 0;
    for (var i=0; i<expectedPath.length; i++) {
        failures += AssertEqualsWithAccuracy(rotatedPath[i].X, expectedPath[i].X, FloatComparisonAccuracy, "RotateByTests");
        failures += AssertEqualsWithAccuracy(rotatedPath[i].Y, expectedPath[i].Y, FloatComparisonAccuracy, "RotateByTests");
    }
    
    return failures;
}

function ScaleToTests()
{
	var path = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
	var scaledPath = ScaleTo(path, 250.0);
	
	var expectedPath = new Array(new Point(0.0, 0.0), new Point(250.0, 125.0), new Point(125.0, 250.0));
    
	var failures = 0;
	for (var i=0; i<expectedPath.length; i++) {
		failures += AssertEqualsWithAccuracy(scaledPath[i].X, expectedPath[i].X, FloatComparisonAccuracy, "ScaleToTests");
		failures += AssertEqualsWithAccuracy(scaledPath[i].Y, expectedPath[i].Y, FloatComparisonAccuracy, "ScaleToTests");
	}
  
	return failures;
}

function TranslateToTests()
{
	var path = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
	var translatedPath = TranslateTo(path, new Point(25.0, 35.0));
	
	var expectedPath = new Array(new Point(20.0, 30.0), new Point(30.0, 35.0), new Point(25.0, 40.0));
    
	var failures = 0;
	for (var i=0; i<expectedPath.length; i++) {
		failures += AssertEqualsWithAccuracy(translatedPath[i].X, expectedPath[i].X, FloatComparisonAccuracy, "TranslateToTests");
		failures += AssertEqualsWithAccuracy(translatedPath[i].Y, expectedPath[i].Y, FloatComparisonAccuracy, "TranslateToTests");
	}
  
	return failures;
}

function VectorizeTests()
{
	var path = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
	var vectorized = Vectorize(path);
	
	var expectedPath = new Array(0.0, 0.0, 0.632456, 0.316228, 0.316228, 0.632456);
    
	var failures = 0;
	for (var i=0; i<expectedPath.length; i++) {
		failures += AssertEqualsWithAccuracy(vectorized[i], expectedPath[i], FloatComparisonAccuracy, "VectorizeTests");
	}
  
	return failures;
}

function OptimalCosineDistanceTests()
{
	var pathA = new Array(new Point(0.0, 0.0),new Point(10.0, 5.0),new Point(5.0, 10.0));
	var pathB = new Array(new Point(1.0, 2.0),new Point(9.0, 4.5),new Point(5.0, 11.0));
    
    var vectorA = Vectorize(pathA);
    var vectorB = Vectorize(pathB);
    
    var distance = OptimalCosineDistance(vectorA, vectorB);
    
    var expectedDistance = 0.1688662;
    
    return AssertEqualsWithAccuracy(distance, expectedDistance, FloatComparisonAccuracy, "OptimalCosineDistanceTests");
}

function RunTests()
{
    var failures = 0;
    failures += PathDistanceTests();
    failures += DistanceAtAngleTests();
    failures += PathLengthTests();
    failures += RotateByTests();
    failures += ScaleToTests();
    failures += TranslateToTests();
    failures += CentroidTests();
    failures += DistanceAtBestAngleTests();
    failures += SimpleRecognizeTests();
    failures += Resample8Tests();
    failures += Resample64LengthTests();
    failures += RecognizeTests();
    failures += VectorizeTests();
    failures += OptimalCosineDistanceTests();
    
    console.log(failures + " failures");
}
