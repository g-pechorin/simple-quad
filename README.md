Peter LaValle / 2016-01-19

# Stoopid-Quad buffered example using GLFW3

This is a [quad-buffered](https://en.wikipedia.org/wiki/Multiple_buffering#Quad_buffering) example program written against [GLFW3/OpenGL](http://www.glfw.org/docs/latest/quick.html#quick_example).
(GLSE 2? GLSE 3? whatever - nobody notices the desktop version's changes)

Draws a **red bar on the left side and in the left eye,** a blue bar on the right and in the right eye.
Also draws a pair of overlapping spinning gradient-style triangles.

Really it's just meant to check if Quad-Buffered OpenGL is working

If it doesn't work - your graphics card might not allow quad-buffering.
