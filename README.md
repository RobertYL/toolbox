# Toolbox

A (loose) collection of [MATLAB](https://www.mathworks.com/products/matlab.html) scripts to support research in multi-body astrodynamics.

## MEX

Some functions have been compiled using the C/C++ MEX API. Functions using the C API are treated as hot paths and there is **no argument validation**, so care must be taken when calling them directly. Functions using the C++ API include argument validation.

All functions using the C API are self-contained and can be compiled in MATLAB Command Window with
```
mex *.cpp
```

Compile with OpenMP with
```
mex CXXFLAGS="$CXXFLAGS -fopenmp" LDFLAGS="$LDFLAGS -fopenmp" *.cpp
```


