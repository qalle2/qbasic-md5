DECLARE FUNCTION rol21& (n AS LONG)
DECLARE FUNCTION rol15& (n AS LONG)
DECLARE FUNCTION rol10& (n AS LONG)
DECLARE FUNCTION rol6& (n AS LONG)
DECLARE FUNCTION rol23& (n AS LONG)
DECLARE FUNCTION rol16& (n AS LONG)
DECLARE FUNCTION rol11& (n AS LONG)
DECLARE FUNCTION rol4& (n AS LONG)
DECLARE FUNCTION rol20& (n AS LONG)
DECLARE FUNCTION rol14& (n AS LONG)
DECLARE FUNCTION rol9& (n AS LONG)
DECLARE FUNCTION rol5& (n AS LONG)
DECLARE FUNCTION rol22& (n AS LONG)
DECLARE FUNCTION rol17& (n AS LONG)
DECLARE FUNCTION rol12& (n AS LONG)
DECLARE FUNCTION rol7& (n AS LONG)
DECLARE FUNCTION add& (a AS LONG, b AS LONG)
DECLARE FUNCTION add4& (a AS LONG, b AS LONG, c AS LONG, d AS LONG)
DECLARE FUNCTION hashchunk$ (state() AS LONG, chunk() AS LONG)
DECLARE SUB tests ()
DECLARE FUNCTION md5$ (message AS STRING)
DECLARE FUNCTION binhex$ (bin AS STRING)
DECLARE FUNCTION preparemessage$ (message AS STRING)

' Note: the functions rolX rotate a 32-bit unsigned integer left X bits.

' the initial state of the algorithm
DATA &H67452301, &HEFCDAB89, &H98BADCFE, &H10325476

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

DIM losum AS LONG, hisum AS LONG, temp AS LONG

' add lower half of each argument together
losum = (a AND &HFFFF&) + (b AND &HFFFF&) + (c AND &HFFFF&) + (d AND &HFFFF&)

' take arguments and losum, shift each one right 16 bits, add together
hisum = (a AND &HFFFF0000) \ &H10000 AND &HFFFF&
hisum = hisum + ((b AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((c AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((d AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((losum AND &HFFFF0000) \ &H10000 AND &HFFFF&)

' shift hisum left 16 bits
temp = -(hisum AND &H8000&) AND &H80000000
hisum = temp OR (hisum AND &H7FFF&) * &H10000

' combine hisum with low 32 bits of losum
add4 = hisum OR losum AND &HFFFF&

END FUNCTION

FUNCTION binhex$ (bin AS STRING)
' Convert a string into hexadecimal. E.g. "AB" -> "4142".

hexa$ = ""
FOR i% = 1 TO LEN(bin)
    hexa$ = hexa$ + RIGHT$("0" + LCASE$(HEX$(ASC(MID$(bin, i%, 1)))), 2)
NEXT

binhex$ = hexa$

END FUNCTION

FUNCTION hashchunk$ (state() AS LONG, chunk() AS LONG)
' Hash one chunk of the message. Optimized for speed.
' state(): the current state of the algorithm (4 LONGs as 16 bytes)
' chunk(): the chunk to hash (16 LONGs as 64 bytes)
' return: the hash of the chunk (4 LONGs as 16 bytes)

DIM a AS LONG, b AS LONG, c AS LONG, d AS LONG  ' state of algorithm
DIM t AS LONG                                   ' temporary variable

' copy the state to variables
a = state(0): b = state(1): c = state(2): d = state(3)

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

' rounds 16-31
t = add4(d AND b OR c AND NOT d, chunk(1), &HF61E2562, a)
a = d: d = c: c = b: b = add(b, rol5(t))
t = add4(d AND b OR c AND NOT d, chunk(6), &HC040B340, a)
a = d: d = c: c = b: b = add(b, rol9(t))
t = add4(d AND b OR c AND NOT d, chunk(11), &H265E5A51, a)
a = d: d = c: c = b: b = add(b, rol14(t))
t = add4(d AND b OR c AND NOT d, chunk(0), &HE9B6C7AA, a)
a = d: d = c: c = b: b = add(b, rol20(t))
t = add4(d AND b OR c AND NOT d, chunk(5), &HD62F105D, a)
a = d: d = c: c = b: b = add(b, rol5(t))
t = add4(d AND b OR c AND NOT d, chunk(10), &H2441453, a)
a = d: d = c: c = b: b = add(b, rol9(t))
t = add4(d AND b OR c AND NOT d, chunk(15), &HD8A1E681, a)
a = d: d = c: c = b: b = add(b, rol14(t))
t = add4(d AND b OR c AND NOT d, chunk(4), &HE7D3FBC8, a)
a = d: d = c: c = b: b = add(b, rol20(t))
t = add4(d AND b OR c AND NOT d, chunk(9), &H21E1CDE6, a)
a = d: d = c: c = b: b = add(b, rol5(t))
t = add4(d AND b OR c AND NOT d, chunk(14), &HC33707D6, a)
a = d: d = c: c = b: b = add(b, rol9(t))
t = add4(d AND b OR c AND NOT d, chunk(3), &HF4D50D87, a)
a = d: d = c: c = b: b = add(b, rol14(t))
t = add4(d AND b OR c AND NOT d, chunk(8), &H455A14ED, a)
a = d: d = c: c = b: b = add(b, rol20(t))
t = add4(d AND b OR c AND NOT d, chunk(13), &HA9E3E905, a)
a = d: d = c: c = b: b = add(b, rol5(t))
t = add4(d AND b OR c AND NOT d, chunk(2), &HFCEFA3F8, a)
a = d: d = c: c = b: b = add(b, rol9(t))
t = add4(d AND b OR c AND NOT d, chunk(7), &H676F02D9, a)
a = d: d = c: c = b: b = add(b, rol14(t))
t = add4(d AND b OR c AND NOT d, chunk(12), &H8D2A4C8A, a)
a = d: d = c: c = b: b = add(b, rol20(t))

' rounds 32-47
t = add4(b XOR c XOR d, chunk(5), &HFFFA3942, a)
a = d: d = c: c = b: b = add(b, rol4(t))
t = add4(b XOR c XOR d, chunk(8), &H8771F681, a)
a = d: d = c: c = b: b = add(b, rol11(t))
t = add4(b XOR c XOR d, chunk(11), &H6D9D6122, a)
a = d: d = c: c = b: b = add(b, rol16(t))
t = add4(b XOR c XOR d, chunk(14), &HFDE5380C, a)
a = d: d = c: c = b: b = add(b, rol23(t))
t = add4(b XOR c XOR d, chunk(1), &HA4BEEA44, a)
a = d: d = c: c = b: b = add(b, rol4(t))
t = add4(b XOR c XOR d, chunk(4), &H4BDECFA9, a)
a = d: d = c: c = b: b = add(b, rol11(t))
t = add4(b XOR c XOR d, chunk(7), &HF6BB4B60, a)
a = d: d = c: c = b: b = add(b, rol16(t))
t = add4(b XOR c XOR d, chunk(10), &HBEBFBC70, a)
a = d: d = c: c = b: b = add(b, rol23(t))
t = add4(b XOR c XOR d, chunk(13), &H289B7EC6, a)
a = d: d = c: c = b: b = add(b, rol4(t))
t = add4(b XOR c XOR d, chunk(0), &HEAA127FA, a)
a = d: d = c: c = b: b = add(b, rol11(t))
t = add4(b XOR c XOR d, chunk(3), &HD4EF3085, a)
a = d: d = c: c = b: b = add(b, rol16(t))
t = add4(b XOR c XOR d, chunk(6), &H4881D05, a)
a = d: d = c: c = b: b = add(b, rol23(t))
t = add4(b XOR c XOR d, chunk(9), &HD9D4D039, a)
a = d: d = c: c = b: b = add(b, rol4(t))
t = add4(b XOR c XOR d, chunk(12), &HE6DB99E5, a)
a = d: d = c: c = b: b = add(b, rol11(t))
t = add4(b XOR c XOR d, chunk(15), &H1FA27CF8, a)
a = d: d = c: c = b: b = add(b, rol16(t))
t = add4(b XOR c XOR d, chunk(2), &HC4AC5665, a)
a = d: d = c: c = b: b = add(b, rol23(t))

' rounds 48-63
t = add4(c XOR (b OR NOT d), chunk(0), &HF4292244, a)
a = d: d = c: c = b: b = add(b, rol6(t))
t = add4(c XOR (b OR NOT d), chunk(7), &H432AFF97, a)
a = d: d = c: c = b: b = add(b, rol10(t))
t = add4(c XOR (b OR NOT d), chunk(14), &HAB9423A7, a)
a = d: d = c: c = b: b = add(b, rol15(t))
t = add4(c XOR (b OR NOT d), chunk(5), &HFC93A039, a)
a = d: d = c: c = b: b = add(b, rol21(t))
t = add4(c XOR (b OR NOT d), chunk(12), &H655B59C3, a)
a = d: d = c: c = b: b = add(b, rol6(t))
t = add4(c XOR (b OR NOT d), chunk(3), &H8F0CCC92, a)
a = d: d = c: c = b: b = add(b, rol10(t))
t = add4(c XOR (b OR NOT d), chunk(10), &HFFEFF47D, a)
a = d: d = c: c = b: b = add(b, rol15(t))
t = add4(c XOR (b OR NOT d), chunk(1), &H85845DD1, a)
a = d: d = c: c = b: b = add(b, rol21(t))
t = add4(c XOR (b OR NOT d), chunk(8), &H6FA87E4F, a)
a = d: d = c: c = b: b = add(b, rol6(t))
t = add4(c XOR (b OR NOT d), chunk(15), &HFE2CE6E0, a)
a = d: d = c: c = b: b = add(b, rol10(t))
t = add4(c XOR (b OR NOT d), chunk(6), &HA3014314, a)
a = d: d = c: c = b: b = add(b, rol15(t))
t = add4(c XOR (b OR NOT d), chunk(13), &H4E0811A1, a)
a = d: d = c: c = b: b = add(b, rol21(t))
t = add4(c XOR (b OR NOT d), chunk(4), &HF7537E82, a)
a = d: d = c: c = b: b = add(b, rol6(t))
t = add4(c XOR (b OR NOT d), chunk(11), &HBD3AF235, a)
a = d: d = c: c = b: b = add(b, rol10(t))
t = add4(c XOR (b OR NOT d), chunk(2), &H2AD7D2BB, a)
a = d: d = c: c = b: b = add(b, rol15(t))
t = add4(c XOR (b OR NOT d), chunk(9), &HEB86D391, a)
a = d: d = c: c = b: b = add(b, rol21(t))

' return the hash as a string
hashchunk$ = MKL$(a) + MKL$(b) + MKL$(c) + MKL$(d)

END FUNCTION

FUNCTION md5$ (message AS STRING)
' Compute an MD5 hash.
' In: a string (0 to 55 bytes).
' Out: the hash as bytes (128 bits as 16 bytes).

DIM state(3) AS LONG     ' the state of the algorithm
DIM statestr AS STRING   ' the state of the algorithm as bytes
DIM chunkhash AS STRING  ' the hash of one chunk
DIM chunkpos AS INTEGER
DIM chunk(15) AS LONG
DIM i AS INTEGER

' pad the message to a multiple of 64 bytes
message = preparemessage(message)

' initialize the state of the algorithm (128 bits)
RESTORE
FOR i = 0 TO 3
    READ state(i)
NEXT

' process the message in chunks of 64 bytes (512 bits)
FOR chunkpos = 1 TO LEN(message) STEP 64
    ' convert the chunk into long integers
    FOR i = 0 TO 15
        chunk(i) = CVL(MID$(message, chunkpos + i * 4, 4))
    NEXT

    ' hash the chunk with the current state
    ' (the output is 4 long integers in 16 bytes)
    chunkhash = hashchunk(state(), chunk())

    ' add each long integer of the chunk hash to the current state
    FOR i = 0 TO 3
        state(i) = add(state(i), CVL(MID$(chunkhash, 4 * i + 1, 4)))
    NEXT
NEXT

' the final state is the hash of the message; return it as bytes
statestr = ""
FOR i = 0 TO 3
    statestr = statestr + MKL$(state(i))
NEXT
md5$ = statestr

END FUNCTION

FUNCTION preparemessage$ (message AS STRING)
' Prepare the message for hashing.
' The output is always a multiple of 64 bytes.

DIM origbits AS LONG
DIM padsize AS INTEGER

' store original length of message in bits
origbits = LEN(message) * 8

' append the byte &H80
message = message + CHR$(&H80)

' pad the message length to the next n*64+56 bytes using byte &H00
padsize = (56 + 64 - LEN(message) MOD 64) MOD 64
message = message + STRING$(padsize, &H0)

' append original length in bits (8 bytes, little endian)
preparemessage = message + MKL$(origbits) + MKL$(&H0)

END FUNCTION

FUNCTION rol10& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFC00000) \ &H400000 AND &H3FF  ' bits 31-22 -> 9-0
target2 = -(n AND &H200000) AND &H80000000         ' bit 21 -> 31
target3 = (n AND &H1FFFFF) * &H400                 ' bits 20-0 -> 30-10
rol10 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol11& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFE00000) \ &H200000 AND &H7FF  ' bits 31-21 -> 10-0
target2 = -(n AND &H100000) AND &H80000000         ' bit 20 -> 31
target3 = (n AND &HFFFFF) * &H800                  ' bits 19-0 -> 30-11
rol11 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol12& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFF00000) \ &H100000 AND &HFFF  ' bits 31-20 -> 11-0
target2 = -(n AND &H80000) AND &H80000000          ' bit 19 -> 31
target3 = (n AND &H7FFFF) * &H1000                 ' bits 18-0 -> 30-12
rol12 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol14& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFC0000) \ &H40000 AND &H3FFF  ' bits 31-18 -> 13-0
target2 = -(n AND &H20000) AND &H80000000          ' bit 17 -> 31
target3 = (n AND &H1FFFF) * &H4000                 ' bits 16-0 -> 30-14
rol14 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol15& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFE0000) \ &H20000 AND &H7FFF&  ' bits 31-17 -> 14-0
target2 = -(n AND &H10000) AND &H80000000           ' bit 16 -> 31
target3 = (n AND &HFFFF&) * &H8000&                 ' bits 15-0 -> 30-15
rol15 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol16& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFF0000) \ &H10000 AND &HFFFF&  ' bits 31-16 -> 15-0
target2 = -(n AND &H8000&) AND &H80000000           ' bit 15 -> 31
target3 = (n AND &H7FFF&) * &H10000                 ' bits 14-0 -> 30-16
rol16 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol17& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFF8000) \ &H8000& AND &H1FFFF  ' bits 31-15 -> 16-0
target2 = -(n AND &H4000) AND &H80000000            ' bit 14 -> 31
target3 = (n AND &H3FFF) * &H20000                  ' bits 13-0 -> 30-17
rol17 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol20& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFFF000) \ &H1000 AND &HFFFFF  ' bits 31-12 -> 19-0
target2 = -(n AND &H800) AND &H80000000            ' bit 11 -> 31
target3 = (n AND &H7FF) * &H100000                 ' bits 10-0 -> 30-20
rol20 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol21& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFFF800) \ &H800 AND &H1FFFFF  ' bits 31-11 -> 20-0
target2 = -(n AND &H400) AND &H80000000            ' bit 10 -> 31
target3 = (n AND &H3FF) * &H200000                 ' bits 9-0 -> 30-21
rol21 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol22& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFFFC00) \ &H400 AND &H3FFFFF  ' bits 31-10 -> 21-0
target2 = -(n AND &H200) AND &H80000000            ' bit 9 -> 31
target3 = (n AND &H1FF) * &H400000                 ' bits 8-0 -> 30-22
rol22 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol23& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFFFFFE00) \ &H200 AND &H7FFFFF  ' bits 31-9 -> 22-0
target2 = -(n AND &H100) AND &H80000000            ' bit 8 -> 31
target3 = (n AND &HFF) * &H800000                  ' bits 7-0 -> 30-23
rol23 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol4& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HF0000000) \ &H10000000 AND &HF  ' bits 31-28 -> 3-0
target2 = -(n AND &H8000000) AND &H80000000        ' bit 27 -> 31
target3 = (n AND &H7FFFFFF) * &H10                 ' bits 26-0 -> 30-4
rol4 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol5& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HF8000000) \ &H8000000 AND &H1F  ' bits 31-27 -> 4-0
target2 = -(n AND &H4000000) AND &H80000000        ' bit 26 -> 31
target3 = (n AND &H3FFFFFF) * &H20                 ' bits 25-0 -> 30-5
rol5 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol6& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFC000000) \ &H4000000 AND &H3F  ' bits 31-26 -> 5-0
target2 = -(n AND &H2000000) AND &H80000000        ' bit 25 -> 31
target3 = (n AND &H1FFFFFF) * &H40                 ' bits 24-0 -> 30-6
rol6 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol7& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFE000000) \ &H2000000 AND &H7F  ' bits 31-25 -> 6-0
target2 = -(n AND &H1000000) AND &H80000000        ' bit 24 -> 31
target3 = (n AND &HFFFFFF) * &H80                  ' bits 23-0 -> 30-7
rol7 = target1 OR target2 OR target3
END FUNCTION

FUNCTION rol9& (n AS LONG)
DIM target1 AS LONG, target2 AS LONG, target3 AS LONG
target1 = (n AND &HFF800000) \ &H800000 AND &H1FF  ' bits 31-23 -> 8-0
target2 = -(n AND &H400000) AND &H80000000         ' bit 22 -> 31
target3 = (n AND &H3FFFFF) * &H200                 ' bits 21-0 -> 30-9
rol9 = target1 OR target2 OR target3
END FUNCTION

SUB tests

IF binhex(md5("")) <> "d41d8cd98f00b204e9800998ecf8427e" THEN STOP
IF binhex(md5("A")) <> "7fc56270e7a70fa81a5935b72eacbe29" THEN STOP
IF binhex(md5("password")) <> "5f4dcc3b5aa765d61d8327deb882cf99" THEN STOP
IF binhex(md5(CHR$(&H0) + CHR$(&HFF) + CHR$(&HF) + CHR$(&HF0) + CHR$(&H33) + CHR$(&HCC) + CHR$(&H55) + CHR$(&HAA))) <> "cb16906543c272af4b8dae1a4c5fe49e" THEN STOP

' near the length of one chunk
IF binhex(md5(STRING$(54, "a"))) <> "eced9e0b81ef2bba605cbc5e2e76a1d0" THEN STOP
IF binhex(md5(STRING$(55, "a"))) <> "ef1772b6dff9a122358552954ad0df65" THEN STOP
IF binhex(md5(STRING$(56, "a"))) <> "3b0c8ac703f828b04c6c197006d17218" THEN STOP
IF binhex(md5(STRING$(57, "a"))) <> "652b906d60af96844ebd21b674f35e93" THEN STOP

' interesting hashes
IF binhex(md5("ximaz")) <> "61529519452809720693702583126814" THEN STOP
IF binhex(md5("cbaabcdljdac")) <> "cadbfdfecdcdcdacdbbbfadbcccefabd" THEN STOP

PRINT "Tests passed."

END SUB

