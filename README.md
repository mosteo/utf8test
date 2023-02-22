# utf8test

Test unicode input/output with `-gnatW8`

Besides the included examples, you can pass your own strings as arguments:
```
alr run --args <mystring>
```

The 'latin1' sample with GNAT.IO output is expected to fail in a UTF-8
terminal:

```
latin1 is 5 bytes: E1:E9:ED:F3:FA:
latin1  GIO image is: �����
latin1  TIO image is: áéíóú
latin1 WWIO image is: áéíóú
latin1 latin1->utf32 image is: áéíóú
```
