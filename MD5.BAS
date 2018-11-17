DECLARE FUNCTION rol22& (n AS LONG)
DECLARE FUNCTION rol17& (n AS LONG)
DECLARE FUNCTION rol12& (n AS LONG)
DECLARE FUNCTION rol7& (n AS LONG)
DECLARE FUNCTION rol& (n AS LONG, b AS INTEGER)
DECLARE FUNCTION add& (a AS LONG, b AS LONG)
DECLARE FUNCTION preparemessage$ (msg AS STRING)
DECLARE FUNCTION longtohex$ (n AS LONG)
DECLARE FUNCTION add4& (a AS LONG, b AS LONG, c AS LONG, d AS LONG)
DECLARE FUNCTION hashchunk$ (state AS STRING, chunkstr AS STRING)
DECLARE SUB tests ()
DECLARE FUNCTION md5$ (msg AS STRING)

' powers of two (2^0 ... 2^31) in hexadecimal
DATA 00000001,00000002,00000004,00000008,00000010,00000020,00000040,00000080
DATA 00000100,00000200,00000400,00000800,00001000,00002000,00004000,00008000
DATA 00010000,00020000,00040000,00080000,00100000,00200000,00400000,00800000
DATA 01000000,02000000,04000000,08000000,10000000,20000000,40000000,80000000

' powers of two, minus one (2^0-1 ... 2^31-1) in hexadecimal
DATA 00000000,00000001,00000003,00000007,0000000f,0000001f,0000003f,0000007f
DATA 000000ff,000001ff,000003ff,000007ff,00000fff,00001fff,00003fff,00007fff
DATA 0000ffff,0001ffff,0003ffff,0007ffff,000fffff,001fffff,003fffff,007fffff
DATA 00ffffff,01ffffff,03ffffff,07ffffff,0fffffff,1fffffff,3fffffff,7fffffff

DIM SHARED pow2(31) AS LONG  ' powers of two
DIM SHARED pow2m1(31) AS LONG  ' powers of two, minus one

DIM msg AS STRING  ' message to hash
DIM i AS INTEGER  ' loop index

' copy DATA to arrays
FOR i = 0 TO 31
    READ v$
    ' force VAL() to interpret hexadecimal 8000...FFFF as 32-bit
    IF LEFT$(v$, 4) = "0000" THEN v$ = v$ + "&"
    pow2(i) = VAL("&H" + v$)
NEXT
FOR i = 0 TO 31
    READ v$
    ' force VAL() to interpret hexadecimal 8000...FFFF as 32-bit
    IF LEFT$(v$, 4) = "0000" THEN v$ = v$ + "&"
    pow2m1(i) = VAL("&H" + v$)
NEXT

CLS
CALL tests

FUNCTION add& (a AS LONG, b AS LONG)
' Add two 32-bit unsigned integers a, b. Return sum modulo 2^32.

' How a full adder works:
'   The inputs: A, B, Cin (carry in)
'   The outputs:
'     Q = A XOR B XOR Cin
'     Cout (carry out) = (A AND B) OR (A AND Cin) OR (B AND Cin)

DIM sumlow AS LONG, carry AS LONG

' sum of bits 29...0 of a and b, with carry out in bit 30
sumlow = (a AND &H3FFFFFFF) + (b AND &H3FFFFFFF)

' carry for bit 31
carry = (a AND b) OR (a AND sumlow) OR (b AND sumlow)
carry = -(carry AND &H40000000) AND &H80000000

add = (sumlow OR carry) XOR ((a XOR b) AND &HC0000000)

END FUNCTION

FUNCTION add4& (a AS LONG, b AS LONG, c AS LONG, d AS LONG)
' Add four 32-bit unsigned integers a, b, c, d. Return sum modulo 2^32.

add4 = add(a, add(b, add(c, d)))

END FUNCTION

FUNCTION hashchunk$ (state AS STRING, chunkstr AS STRING)
' Hash one chunk of the message.
' state: the current state of the algorithm (4 long integers as 16 bytes)
' chunkstr: the chunk to hash (16 long integers as 64 bytes)
' return: the chunk's hash (4 long integers as 16 bytes)

DIM a AS LONG, b AS LONG, c AS LONG, d AS LONG  ' state of algorithm
DIM chunk(15) AS LONG  ' the chunk
DIM i AS INTEGER  ' loop variable
DIM t AS LONG  ' temporary variable

' convert the state of the algorithm into long integers
a = CVL(LEFT$(state, 4))
b = CVL(MID$(state, 5, 4))
c = CVL(MID$(state, 9, 4))
d = CVL(RIGHT$(state, 4))

' convert the chunk into long integers
FOR i = 0 TO 15
    chunk(i) = CVL(MID$(chunkstr, i * 4 + 1, 4))
NEXT

' rounds 0-15
t = add4(b AND c OR d AND NOT b, chunk(0), &HD76AA478, a)
a = d: d = c: c = b: b = add(b, rol7(t))
t = add4(b AND c OR d AND NOT b, chunk(1), &HE8C7B756, a)
a = d: d = c: c = b: b = add(b, rol12(t))
t = add4(b AND c OR d AND NOT b, chunk(2), &H242070DB, a)
a = d: d = c: c = b: b = add(b, rol17(t))
t = add4(b AND c OR d AND NOT b, chunk(3), &HC1BDCEEE, a)
a = d: d = c: c = b: b = add(b, rol22(t))
t = add4(b AND c OR d AND NOT b, chunk(4), &HF57C0FAF, a)
a = d: d = c: c = b: b = add(b, rol7(t))
t = add4(b AND c OR d AND NOT b, chunk(5), &H4787C62A, a)
a = d: d = c: c = b: b = add(b, rol12(t))
t = add4(b AND c OR d AND NOT b, chunk(6), &HA8304613, a)
a = d: d = c: c = b: b = add(b, rol17(t))
t = add4(b AND c OR d AND NOT b, chunk(7), &HFD469501, a)
a = d: d = c: c = b: b = add(b, rol22(t))
t = add4(b AND c OR d AND NOT b, chunk(8), &H698098D8, a)
a = d: d = c: c = b: b = add(b, rol7(t))
t = add4(b AND c OR d AND NOT b, chunk(9), &H8B44F7AF, a)
a = d: d = c: c = b: b = add(b, rol12(t))
t = add4(b AND c OR d AND NOT b, chunk(10), &HFFFF5BB1, a)
a = d: d = c: c = b: b = add(b, rol17(t))
t = add4(b AND c OR d AND NOT b, chunk(11), &H895CD7BE, a)
a = d: d = c: c = b: b = add(b, rol22(t))
t = add4(b AND c OR d AND NOT b, chunk(12), &H6B901122, a)
a = d: d = c: c = b: b = add(b, rol7(t))
t = add4(b AND c OR d AND NOT b, chunk(13), &HFD987193, a)
a = d: d = c: c = b: b = add(b, rol12(t))
t = add4(b AND c OR d AND NOT b, chunk(14), &HA679438E, a)
a = d: d = c: c = b: b = add(b, rol17(t))
t = add4(b AND c OR d AND NOT b, chunk(15), &H49B40821, a)
a = d: d = c: c = b: b = add(b, rol22(t))

' TODO: optimize the rest of the rotations: rol5(t) instead of rol(t, 5) etc.

' rounds 16-31
t = add4(d AND b OR c AND NOT d, chunk(1), &HF61E2562, a)
a = d: d = c: c = b: b = add(b, rol(t, 5))
t = add4(d AND b OR c AND NOT d, chunk(6), &HC040B340, a)
a = d: d = c: c = b: b = add(b, rol(t, 9))
t = add4(d AND b OR c AND NOT d, chunk(11), &H265E5A51, a)
a = d: d = c: c = b: b = add(b, rol(t, 14))
t = add4(d AND b OR c AND NOT d, chunk(0), &HE9B6C7AA, a)
a = d: d = c: c = b: b = add(b, rol(t, 20))
t = add4(d AND b OR c AND NOT d, chunk(5), &HD62F105D, a)
a = d: d = c: c = b: b = add(b, rol(t, 5))
t = add4(d AND b OR c AND NOT d, chunk(10), &H2441453, a)
a = d: d = c: c = b: b = add(b, rol(t, 9))
t = add4(d AND b OR c AND NOT d, chunk(15), &HD8A1E681, a)
a = d: d = c: c = b: b = add(b, rol(t, 14))
t = add4(d AND b OR c AND NOT d, chunk(4), &HE7D3FBC8, a)
a = d: d = c: c = b: b = add(b, rol(t, 20))
t = add4(d AND b OR c AND NOT d, chunk(9), &H21E1CDE6, a)
a = d: d = c: c = b: b = add(b, rol(t, 5))
t = add4(d AND b OR c AND NOT d, chunk(14), &HC33707D6, a)
a = d: d = c: c = b: b = add(b, rol(t, 9))
t = add4(d AND b OR c AND NOT d, chunk(3), &HF4D50D87, a)
a = d: d = c: c = b: b = add(b, rol(t, 14))
t = add4(d AND b OR c AND NOT d, chunk(8), &H455A14ED, a)
a = d: d = c: c = b: b = add(b, rol(t, 20))
t = add4(d AND b OR c AND NOT d, chunk(13), &HA9E3E905, a)
a = d: d = c: c = b: b = add(b, rol(t, 5))
t = add4(d AND b OR c AND NOT d, chunk(2), &HFCEFA3F8, a)
a = d: d = c: c = b: b = add(b, rol(t, 9))
t = add4(d AND b OR c AND NOT d, chunk(7), &H676F02D9, a)
a = d: d = c: c = b: b = add(b, rol(t, 14))
t = add4(d AND b OR c AND NOT d, chunk(12), &H8D2A4C8A, a)
a = d: d = c: c = b: b = add(b, rol(t, 20))

' rounds 32-47
t = add4(b XOR c XOR d, chunk(5), &HFFFA3942, a)
a = d: d = c: c = b: b = add(b, rol(t, 4))
t = add4(b XOR c XOR d, chunk(8), &H8771F681, a)
a = d: d = c: c = b: b = add(b, rol(t, 11))
t = add4(b XOR c XOR d, chunk(11), &H6D9D6122, a)
a = d: d = c: c = b: b = add(b, rol(t, 16))
t = add4(b XOR c XOR d, chunk(14), &HFDE5380C, a)
a = d: d = c: c = b: b = add(b, rol(t, 23))
t = add4(b XOR c XOR d, chunk(1), &HA4BEEA44, a)
a = d: d = c: c = b: b = add(b, rol(t, 4))
t = add4(b XOR c XOR d, chunk(4), &H4BDECFA9, a)
a = d: d = c: c = b: b = add(b, rol(t, 11))
t = add4(b XOR c XOR d, chunk(7), &HF6BB4B60, a)
a = d: d = c: c = b: b = add(b, rol(t, 16))
t = add4(b XOR c XOR d, chunk(10), &HBEBFBC70, a)
a = d: d = c: c = b: b = add(b, rol(t, 23))
t = add4(b XOR c XOR d, chunk(13), &H289B7EC6, a)
a = d: d = c: c = b: b = add(b, rol(t, 4))
t = add4(b XOR c XOR d, chunk(0), &HEAA127FA, a)
a = d: d = c: c = b: b = add(b, rol(t, 11))
t = add4(b XOR c XOR d, chunk(3), &HD4EF3085, a)
a = d: d = c: c = b: b = add(b, rol(t, 16))
t = add4(b XOR c XOR d, chunk(6), &H4881D05, a)
a = d: d = c: c = b: b = add(b, rol(t, 23))
t = add4(b XOR c XOR d, chunk(9), &HD9D4D039, a)
a = d: d = c: c = b: b = add(b, rol(t, 4))
t = add4(b XOR c XOR d, chunk(12), &HE6DB99E5, a)
a = d: d = c: c = b: b = add(b, rol(t, 11))
t = add4(b XOR c XOR d, chunk(15), &H1FA27CF8, a)
a = d: d = c: c = b: b = add(b, rol(t, 16))
t = add4(b XOR c XOR d, chunk(2), &HC4AC5665, a)
a = d: d = c: c = b: b = add(b, rol(t, 23))

' rounds 48-63
t = add4(c XOR (b OR NOT d), chunk(0), &HF4292244, a)
a = d: d = c: c = b: b = add(b, rol(t, 6))
t = add4(c XOR (b OR NOT d), chunk(7), &H432AFF97, a)
a = d: d = c: c = b: b = add(b, rol(t, 10))
t = add4(c XOR (b OR NOT d), chunk(14), &HAB9423A7, a)
a = d: d = c: c = b: b = add(b, rol(t, 15))
t = add4(c XOR (b OR NOT d), chunk(5), &HFC93A039, a)
a = d: d = c: c = b: b = add(b, rol(t, 21))
t = add4(c XOR (b OR NOT d), chunk(12), &H655B59C3, a)
a = d: d = c: c = b: b = add(b, rol(t, 6))
t = add4(c XOR (b OR NOT d), chunk(3), &H8F0CCC92, a)
a = d: d = c: c = b: b = add(b, rol(t, 10))
t = add4(c XOR (b OR NOT d), chunk(10), &HFFEFF47D, a)
a = d: d = c: c = b: b = add(b, rol(t, 15))
t = add4(c XOR (b OR NOT d), chunk(1), &H85845DD1, a)
a = d: d = c: c = b: b = add(b, rol(t, 21))
t = add4(c XOR (b OR NOT d), chunk(8), &H6FA87E4F, a)
a = d: d = c: c = b: b = add(b, rol(t, 6))
t = add4(c XOR (b OR NOT d), chunk(15), &HFE2CE6E0, a)
a = d: d = c: c = b: b = add(b, rol(t, 10))
t = add4(c XOR (b OR NOT d), chunk(6), &HA3014314, a)
a = d: d = c: c = b: b = add(b, rol(t, 15))
t = add4(c XOR (b OR NOT d), chunk(13), &H4E0811A1, a)
a = d: d = c: c = b: b = add(b, rol(t, 21))
t = add4(c XOR (b OR NOT d), chunk(4), &HF7537E82, a)
a = d: d = c: c = b: b = add(b, rol(t, 6))
t = add4(c XOR (b OR NOT d), chunk(11), &HBD3AF235, a)
a = d: d = c: c = b: b = add(b, rol(t, 10))
t = add4(c XOR (b OR NOT d), chunk(2), &H2AD7D2BB, a)
a = d: d = c: c = b: b = add(b, rol(t, 15))
t = add4(c XOR (b OR NOT d), chunk(9), &HEB86D391, a)
a = d: d = c: c = b: b = add(b, rol(t, 21))

' return the hash as a string
hashchunk$ = MKL$(a) + MKL$(b) + MKL$(c) + MKL$(d)

END FUNCTION

FUNCTION longtohex$ (n AS LONG)
' Convert a long into a hexadecimal string, with the bytes in little-endian
' order. E.g. &HABCD -> "cdab0000"

DIM bigendian AS STRING
DIM littleendian AS STRING
DIM byte AS INTEGER
DIM i AS INTEGER

bigendian = MKL$(n)
littleendian = ""
FOR i = 1 TO 4
    byte = ASC(MID$(bigendian, i, 1))
    littleendian = littleendian + RIGHT$("0" + LCASE$(HEX$(byte)), 2)
NEXT

longtohex$ = littleendian

END FUNCTION

FUNCTION md5$ (msg AS STRING)
' Compute MD5 hash.
' In: a prepared string (always 64 bytes, i.e., one MD5 chunk).

DIM a AS LONG, b AS LONG, c AS LONG, d AS LONG  ' state of algorithm
DIM statestr AS STRING  ' state of algorithm as bytes
DIM chunkhash AS STRING  ' hash of chunk
DIM newstate(3) AS LONG  ' integers to add to the state

' prepare the message
msg = preparemessage(msg)

' initialize the state
a = &H67452301
b = &HEFCDAB89
c = &H98BADCFE
d = &H10325476

' convert state into bytes
statestr = MKL$(a) + MKL$(b) + MKL$(c) + MKL$(d)

' hash the chunk
chunkhash = hashchunk(statestr, msg)

' add the chunk's hash to the current state
a = add(a, CVL(LEFT$(chunkhash, 4)))
b = add(b, CVL(MID$(chunkhash, 5, 4)))
c = add(c, CVL(MID$(chunkhash, 9, 4)))
d = add(d, CVL(RIGHT$(chunkhash, 4)))

' return the hash as a hexadecimal string
md5$ = longtohex(a) + longtohex(b) + longtohex(c) + longtohex(d)

END FUNCTION

FUNCTION preparemessage$ (msg AS STRING)
' Prepare a message for hashing.
' msg: 0-55 bytes
' return: 64 bytes

DIM origlen AS INTEGER

origlen = LEN(msg)

' append the byte &H80
msg = msg + CHR$(&H80)

' pad to 56 bytes using byte &H00
msg = msg + STRING$(56 - LEN(msg), &H0)

' append original length in bits (8 bytes, little endian)
preparemessage$ = msg + MKL$(origlen% * 8) + STRING$(4, &H0)

END FUNCTION

FUNCTION rol& (n AS LONG, b AS INTEGER)
' Rotate 32-bit unsigned integer n left b bits (1-31).

DIM target1 AS LONG, target2 AS LONG, target3 AS LONG

' bits 31...32-b -> b-1...0
target1 = (n AND NOT pow2m1(32 - b)) \ pow2(32 - b) AND pow2m1(b)

' bit 31-b -> 31
target2 = -(n AND pow2(31 - b)) AND &H80000000

' bits 30-b...0 -> 30...b (only if b < 31)
target3 = (n AND pow2m1(31 - b)) * pow2(b)

rol = target1 OR target2 OR target3

END FUNCTION

FUNCTION rol12& (n AS LONG)
' Rotate 32-bit unsigned integer n left 12 bits.

DIM target1 AS LONG, target2 AS LONG, target3 AS LONG

target1 = (n AND &HFFF00000) \ &H100000 AND &HFFF  ' bits 31-20 -> 11-0
target2 = -(n AND &H80000) AND &H80000000          ' bit 19 -> 31
target3 = (n AND &H7FFFF) * &H1000                 ' bits 18-0 -> 30-12

rol12 = target1 OR target2 OR target3

END FUNCTION

FUNCTION rol17& (n AS LONG)
' Rotate 32-bit unsigned integer n left 17 bits.

DIM target1 AS LONG, target2 AS LONG, target3 AS LONG

target1 = (n AND &HFFFF8000) \ &H8000& AND &H1FFFF  ' bits 31-15 -> 16-0
target2 = -(n AND &H4000&) AND &H80000000           ' bit 14 -> 31
target3 = (n AND &H3FFF) * &H20000                  ' bits 13-0 -> 30-17

rol17 = target1 OR target2 OR target3

END FUNCTION

FUNCTION rol22& (n AS LONG)
' Rotate 32-bit unsigned integer n left 22 bits.

DIM target1 AS LONG, target2 AS LONG, target3 AS LONG

target1 = (n AND &HFFFFFC00) \ &H400 AND &H3FFFFF  ' bits 31-10 -> 21-0
target2 = -(n AND &H200) AND &H80000000            ' bit 9 -> 31
target3 = (n AND &H1FF) * &H400000                 ' bits 8-0 -> 30-22

rol22 = target1 OR target2 OR target3

END FUNCTION

FUNCTION rol7& (n AS LONG)
' Rotate 32-bit unsigned integer n left 7 bits.

DIM target1 AS LONG, target2 AS LONG, target3 AS LONG

target1 = (n AND &HFE000000) \ &H2000000 AND &H7F  ' bits 31-25 -> 6-0
target2 = -(n AND &H1000000) AND &H80000000        ' bit 24 -> 31
target3 = (n AND &HFFFFFF) * &H80                  ' bits 23-0 -> 30-7

rol7 = target1 OR target2 OR target3

END FUNCTION

SUB tests

IF md5("") <> "d41d8cd98f00b204e9800998ecf8427e" THEN STOP
IF md5("A") <> "7fc56270e7a70fa81a5935b72eacbe29" THEN STOP
IF md5("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabc") <> "0d7ae056b2f015cd7dc67494efd658f1" THEN STOP
IF md5("ximaz") <> "61529519452809720693702583126814" THEN STOP

PRINT "Tests passed."

END SUB

