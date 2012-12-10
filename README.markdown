$1 Unistroke Gesture Recognizer for iOS
=======================================

[CMUnistrokeGestureRecognizer][1] is a port of the [$1 Unistroke Recognizer][2]
(aka Dollar Gesture Recognizer) to iOS by Chris Miles.

[1]: https://github.com/chrismiles/CMUnistrokeGestureRecognizer "CMUnistrokeGestureRecognizer"
[2]: http://depts.washington.edu/aimgroup/proj/dollar/ "$1 Unistroke Recognizer"

Read more about it at http://blog.chrismiles.info/2012/12/introducing-cmunistrokegesturerecognizer.html

The $1 Unistroke Recognizer was originally authored by:
  
  * Jacob O. Wobbrock, University of Washington
  * Andrew D. Wilson, Microsoft Research
  * Yang Li, University of Washington

CMUnistrokeGestureRecognizer is a UIGestureRecognizer subclass, able to recognize
any number of unistroke gestures configured by the user.  Stroke paths are registered
as UIBezierPath objects, making it easy to create and display paths.

The core unistroke recognizer algorithm is written in C, although uses GLKVector2
and GLKMath for high performance vector math on iOS devices. As such, the GLKit
framework is required. Unit tests are included.

CMUnistrokeGestureRecognizer is open source, released under an MIT license.

A demo iOS application is included, showing how CMUnistrokeGestureRecognizer can be used
and containing all the test strokes used by the algorithm authors. The demo app is open
source and released under a MIT license.

![CMUnistrokeGestureRecognizer](https://lh5.googleusercontent.com/-_j1H_Auebcw/UKqqXPOOdWI/AAAAAAAAAVw/eJUC6RWMS9g/s912/CMUnistrokeGestureRecognizer%2520star.png "CMUnistrokeGestureRecognizer")


Support
-------

CMUnistrokeGestureRecognizer is provided open source with no warranty and no guarantee
of support. However, best effort is made to address [issues][3] raised on Github.

If you would like assistance with integrating CMUnistrokeGestureRecognizer or modifying
it for your needs, contact the author Chris Miles <miles.chris@gmail.com> for consulting
opportunities.

[3]: https://github.com/chrismiles/CMUnistrokeGestureRecognizer/issues "CMUnistrokeGestureRecognizer issues on Github"


License
-------

CMUnistrokeGestureRecognizer is Copyright (c) Chris Miles 2012 and released
open source under a MIT license.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
