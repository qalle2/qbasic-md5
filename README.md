# qbasic-md5
A Microsoft QBasic program that computes the MD5 hash of a string.

Note: after publishing my program, I discovered [a similar one](http://forum.qbasicnews.com/index.php?topic=13371.0) by Qbasicnews.com user stylin. My program seems faster, though.

## Comments on some procedures

### `add()` (add two 32-bit unsigned integers)

* `a` and `b`: the numbers to add
* `losum`: the sum of bits 29&hellip;0 of each argument (the carry out will be in bit 30)
* `carry`: carry for bit 31 from less-significant bits (`&H80000000` if at least two of `a`, `b` and `losum` have bit 30 set, otherwise `&H0`)
* the sum:
  * bit 31: `((a XOR b) AND &H80000000) XOR carry`
  * bit 30: `(a XOR b XOR losum) AND &H40000000`
  * bits 29&hellip;0: `losum AND &H3FFFFFFF`
  * bits 30&hellip;0: `((a XOR b) AND &H40000000) XOR losum`
  * bits 31&hellip;0: `( ((a XOR b) AND &H80000000) XOR carry ) OR ( ((a XOR b) AND &H40000000) XOR losum )`
  * bits 31&hellip;0 (reduced): `(carry OR losum) XOR ((a XOR b) AND &HC0000000)`

## References
* [MD5 pseudocode](http://en.wikipedia.org/wiki/MD5#Pseudocode) (Wikipedia)
* [full adder](http://en.wikipedia.org/wiki/Adder_(electronics)#Full_adder) (Wikipedia; for understanding how the `add()` function works)
* [another QBasic MD5 implementation](http://forum.qbasicnews.com/index.php?topic=13371.0) by Qbasicnews.com user stylin (I discovered this one only after publishing my program; however, I stole the idea of avoiding the many reassignments of the state variables `a`, `b`, `c` and `d` in `hashchunk()`)
