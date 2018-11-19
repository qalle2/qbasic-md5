# qbasic-md5
A Microsoft QBasic program that computes the MD5 hash of a string.

## References
* [MD5 pseudocode](http://en.wikipedia.org/wiki/MD5#Pseudocode) (Wikipedia)
* [another QBasic MD5 implementation](http://forum.qbasicnews.com/index.php?topic=13371.0) by Qbasicnews.com user stylin (I discovered this one only after publishing my program; however, I stole the idea of avoiding the many reassignments of the state variables `a`, `b`, `c` and `d` in `hashchunk()`)
