DECLARE FUNCTION hashchunk$ (s0 AS LONG, s1 AS LONG, s2 AS LONG, s3 AS LONG, chunk() AS LONG)
DECLARE FUNCTION prepmsg$ (msg AS STRING)
DECLARE SUB testspeed ()
DECLARE SUB test ()
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
DECLARE FUNCTION md5$ (msg AS STRING)
DECLARE FUNCTION binhex$ (str AS STRING)
' initial state
DATA &H67452301, &HEFCDAB89, &H98BADCFE, &H10325476
CLS
CALL test
'CALL testspeed

FUNCTION add& (a AS LONG, b AS LONG)
' Add two unsigned LONGs. See readme.
DIM losum AS LONG, carry AS LONG
losum = (a AND &H3FFFFFFF) + (b AND &H3FFFFFFF)
carry = (a AND b) OR (a AND losum) OR (b AND losum)
carry = -(carry AND &H40000000) AND &H80000000
add = (carry OR losum) XOR ((a XOR b) AND &HC0000000)
END FUNCTION

FUNCTION add4& (a AS LONG, b AS LONG, c AS LONG, d AS LONG)
' Add four unsigned LONGs.
DIM losum AS LONG, hisum AS LONG, temp AS LONG
losum = (a AND &HFFFF&) + (b AND &HFFFF&) + (c AND &HFFFF&) + (d AND &HFFFF&)
hisum = (a AND &HFFFF0000) \ &H10000 AND &HFFFF&
hisum = hisum + ((b AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((c AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((d AND &HFFFF0000) \ &H10000 AND &HFFFF&)
hisum = hisum + ((losum AND &HFFFF0000) \ &H10000 AND &HFFFF&)
temp = -(hisum AND &H8000&) AND &H80000000
hisum = temp OR (hisum AND &H7FFF&) * &H10000
add4 = hisum OR losum AND &HFFFF&
END FUNCTION

FUNCTION binhex$ (str AS STRING)
' Convert string into hexadecimal.
DIM hexa AS STRING, i AS INTEGER
hexa = ""
FOR i = 1 TO LEN(str)
    hexa = hexa + RIGHT$("0" + LCASE$(HEX$(ASC(MID$(str, i, 1)))), 2)
NEXT
binhex$ = hexa
END FUNCTION

FUNCTION hashchunk$ (s0 AS LONG, s1 AS LONG, s2 AS LONG, s3 AS LONG, chunk() AS LONG)
' Hash chunk. s0...s3 = state. chunk(): 16 items. Return 16 bytes.
DIM a AS LONG, b AS LONG, c AS LONG, d AS LONG
a = s0: b = s1: c = s2: d = s3
a = add(b, rol7(add4(d XOR (b AND (c XOR d)), chunk(0), &HD76AA478, a)))
d = add(a, rol12(add4(c XOR (a AND (b XOR c)), chunk(1), &HE8C7B756, d)))
c = add(d, rol17(add4(b XOR (d AND (a XOR b)), chunk(2), &H242070DB, c)))
b = add(c, rol22(add4(a XOR (c AND (d XOR a)), chunk(3), &HC1BDCEEE, b)))
a = add(b, rol7(add4(d XOR (b AND (c XOR d)), chunk(4), &HF57C0FAF, a)))
d = add(a, rol12(add4(c XOR (a AND (b XOR c)), chunk(5), &H4787C62A, d)))
c = add(d, rol17(add4(b XOR (d AND (a XOR b)), chunk(6), &HA8304613, c)))
b = add(c, rol22(add4(a XOR (c AND (d XOR a)), chunk(7), &HFD469501, b)))
a = add(b, rol7(add4(d XOR (b AND (c XOR d)), chunk(8), &H698098D8, a)))
d = add(a, rol12(add4(c XOR (a AND (b XOR c)), chunk(9), &H8B44F7AF, d)))
c = add(d, rol17(add4(b XOR (d AND (a XOR b)), chunk(10), &HFFFF5BB1, c)))
b = add(c, rol22(add4(a XOR (c AND (d XOR a)), chunk(11), &H895CD7BE, b)))
a = add(b, rol7(add4(d XOR (b AND (c XOR d)), chunk(12), &H6B901122, a)))
d = add(a, rol12(add4(c XOR (a AND (b XOR c)), chunk(13), &HFD987193, d)))
c = add(d, rol17(add4(b XOR (d AND (a XOR b)), chunk(14), &HA679438E, c)))
b = add(c, rol22(add4(a XOR (c AND (d XOR a)), chunk(15), &H49B40821, b)))
a = add(b, rol5(add4(c XOR (d AND (b XOR c)), chunk(1), &HF61E2562, a)))
d = add(a, rol9(add4(b XOR (c AND (a XOR b)), chunk(6), &HC040B340, d)))
c = add(d, rol14(add4(a XOR (b AND (d XOR a)), chunk(11), &H265E5A51, c)))
b = add(c, rol20(add4(d XOR (a AND (c XOR d)), chunk(0), &HE9B6C7AA, b)))
a = add(b, rol5(add4(c XOR (d AND (b XOR c)), chunk(5), &HD62F105D, a)))
d = add(a, rol9(add4(b XOR (c AND (a XOR b)), chunk(10), &H2441453, d)))
c = add(d, rol14(add4(a XOR (b AND (d XOR a)), chunk(15), &HD8A1E681, c)))
b = add(c, rol20(add4(d XOR (a AND (c XOR d)), chunk(4), &HE7D3FBC8, b)))
a = add(b, rol5(add4(c XOR (d AND (b XOR c)), chunk(9), &H21E1CDE6, a)))
d = add(a, rol9(add4(b XOR (c AND (a XOR b)), chunk(14), &HC33707D6, d)))
c = add(d, rol14(add4(a XOR (b AND (d XOR a)), chunk(3), &HF4D50D87, c)))
b = add(c, rol20(add4(d XOR (a AND (c XOR d)), chunk(8), &H455A14ED, b)))
a = add(b, rol5(add4(c XOR (d AND (b XOR c)), chunk(13), &HA9E3E905, a)))
d = add(a, rol9(add4(b XOR (c AND (a XOR b)), chunk(2), &HFCEFA3F8, d)))
c = add(d, rol14(add4(a XOR (b AND (d XOR a)), chunk(7), &H676F02D9, c)))
b = add(c, rol20(add4(d XOR (a AND (c XOR d)), chunk(12), &H8D2A4C8A, b)))
a = add(b, rol4(add4(b XOR c XOR d, chunk(5), &HFFFA3942, a)))
d = add(a, rol11(add4(a XOR b XOR c, chunk(8), &H8771F681, d)))
c = add(d, rol16(add4(d XOR a XOR b, chunk(11), &H6D9D6122, c)))
b = add(c, rol23(add4(c XOR d XOR a, chunk(14), &HFDE5380C, b)))
a = add(b, rol4(add4(b XOR c XOR d, chunk(1), &HA4BEEA44, a)))
d = add(a, rol11(add4(a XOR b XOR c, chunk(4), &H4BDECFA9, d)))
c = add(d, rol16(add4(d XOR a XOR b, chunk(7), &HF6BB4B60, c)))
b = add(c, rol23(add4(c XOR d XOR a, chunk(10), &HBEBFBC70, b)))
a = add(b, rol4(add4(b XOR c XOR d, chunk(13), &H289B7EC6, a)))
d = add(a, rol11(add4(a XOR b XOR c, chunk(0), &HEAA127FA, d)))
c = add(d, rol16(add4(d XOR a XOR b, chunk(3), &HD4EF3085, c)))
b = add(c, rol23(add4(c XOR d XOR a, chunk(6), &H4881D05, b)))
a = add(b, rol4(add4(b XOR c XOR d, chunk(9), &HD9D4D039, a)))
d = add(a, rol11(add4(a XOR b XOR c, chunk(12), &HE6DB99E5, d)))
c = add(d, rol16(add4(d XOR a XOR b, chunk(15), &H1FA27CF8, c)))
b = add(c, rol23(add4(c XOR d XOR a, chunk(2), &HC4AC5665, b)))
a = add(b, rol6(add4(c XOR (b OR NOT d), chunk(0), &HF4292244, a)))
d = add(a, rol10(add4(b XOR (a OR NOT c), chunk(7), &H432AFF97, d)))
c = add(d, rol15(add4(a XOR (d OR NOT b), chunk(14), &HAB9423A7, c)))
b = add(c, rol21(add4(d XOR (c OR NOT a), chunk(5), &HFC93A039, b)))
a = add(b, rol6(add4(c XOR (b OR NOT d), chunk(12), &H655B59C3, a)))
d = add(a, rol10(add4(b XOR (a OR NOT c), chunk(3), &H8F0CCC92, d)))
c = add(d, rol15(add4(a XOR (d OR NOT b), chunk(10), &HFFEFF47D, c)))
b = add(c, rol21(add4(d XOR (c OR NOT a), chunk(1), &H85845DD1, b)))
a = add(b, rol6(add4(c XOR (b OR NOT d), chunk(8), &H6FA87E4F, a)))
d = add(a, rol10(add4(b XOR (a OR NOT c), chunk(15), &HFE2CE6E0, d)))
c = add(d, rol15(add4(a XOR (d OR NOT b), chunk(6), &HA3014314, c)))
b = add(c, rol21(add4(d XOR (c OR NOT a), chunk(13), &H4E0811A1, b)))
a = add(b, rol6(add4(c XOR (b OR NOT d), chunk(4), &HF7537E82, a)))
d = add(a, rol10(add4(b XOR (a OR NOT c), chunk(11), &HBD3AF235, d)))
c = add(d, rol15(add4(a XOR (d OR NOT b), chunk(2), &H2AD7D2BB, c)))
b = add(c, rol21(add4(d XOR (c OR NOT a), chunk(9), &HEB86D391, b)))
hashchunk$ = MKL$(a) + MKL$(b) + MKL$(c) + MKL$(d)
END FUNCTION

FUNCTION md5$ (msg AS STRING)
' Compute MD5. Return 128 bits as 16 bytes.
DIM i AS INTEGER, s0 AS LONG, s1 AS LONG, s2 AS LONG, s3 AS LONG
DIM chunkpos AS INTEGER, chunk(15) AS LONG, chunkhash AS STRING
IF LEN(msg) > 8192 THEN PRINT "Message too long.": END
msg = prepmsg(msg)
RESTORE: READ s0, s1, s2, s3
FOR chunkpos = 1 TO LEN(msg) STEP 64
    FOR i = 0 TO 15: chunk(i) = CVL(MID$(msg, chunkpos + i * 4, 4)): NEXT
    chunkhash = hashchunk(s0, s1, s2, s3, chunk())
    s0 = add(s0, CVL(LEFT$(chunkhash, 4)))
    s1 = add(s1, CVL(MID$(chunkhash, 5, 4)))
    s2 = add(s2, CVL(MID$(chunkhash, 9, 4)))
    s3 = add(s3, CVL(RIGHT$(chunkhash, 4)))
NEXT
md5$ = MKL$(s0) + MKL$(s1) + MKL$(s2) + MKL$(s3)
END FUNCTION

FUNCTION prepmsg$ (msg AS STRING)
' Prepare message for hashing.
DIM leng AS INTEGER, pad AS INTEGER
leng = LEN(msg)
pad = (55 + 64 - leng MOD 64) MOD 64  ' pad to 64n bytes
prepmsg = msg + CHR$(&H80) + STRING$(pad, &H0) + MKL$(leng * 8&) + MKL$(0)
END FUNCTION

FUNCTION rol10& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFC00000) \ &H400000 AND &H3FF
b = -(n AND &H200000) AND &H80000000
c = (n AND &H1FFFFF) * &H400
rol10 = a OR b OR c
END FUNCTION

FUNCTION rol11& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFE00000) \ &H200000 AND &H7FF
b = -(n AND &H100000) AND &H80000000
c = (n AND &HFFFFF) * &H800
rol11 = a OR b OR c
END FUNCTION

FUNCTION rol12& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFF00000) \ &H100000 AND &HFFF
b = -(n AND &H80000) AND &H80000000
c = (n AND &H7FFFF) * &H1000
rol12 = a OR b OR c
END FUNCTION

FUNCTION rol14& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFC0000) \ &H40000 AND &H3FFF
b = -(n AND &H20000) AND &H80000000
c = (n AND &H1FFFF) * &H4000
rol14 = a OR b OR c
END FUNCTION

FUNCTION rol15& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFE0000) \ &H20000 AND &H7FFF&
b = -(n AND &H10000) AND &H80000000
c = (n AND &HFFFF&) * &H8000&
rol15 = a OR b OR c
END FUNCTION

FUNCTION rol16& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFF0000) \ &H10000 AND &HFFFF&
b = -(n AND &H8000&) AND &H80000000
c = (n AND &H7FFF&) * &H10000
rol16 = a OR b OR c
END FUNCTION

FUNCTION rol17& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFF8000) \ &H8000& AND &H1FFFF
b = -(n AND &H4000) AND &H80000000
c = (n AND &H3FFF) * &H20000
rol17 = a OR b OR c
END FUNCTION

FUNCTION rol20& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFFF000) \ &H1000 AND &HFFFFF
b = -(n AND &H800) AND &H80000000
c = (n AND &H7FF) * &H100000
rol20 = a OR b OR c
END FUNCTION

FUNCTION rol21& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFFF800) \ &H800 AND &H1FFFFF
b = -(n AND &H400) AND &H80000000
c = (n AND &H3FF) * &H200000
rol21 = a OR b OR c
END FUNCTION

FUNCTION rol22& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFFFC00) \ &H400 AND &H3FFFFF
b = -(n AND &H200) AND &H80000000
c = (n AND &H1FF) * &H400000
rol22 = a OR b OR c
END FUNCTION

FUNCTION rol23& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFFFFFE00) \ &H200 AND &H7FFFFF
b = -(n AND &H100) AND &H80000000
c = (n AND &HFF) * &H800000
rol23 = a OR b OR c
END FUNCTION

FUNCTION rol4& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HF0000000) \ &H10000000 AND &HF
b = -(n AND &H8000000) AND &H80000000
c = (n AND &H7FFFFFF) * &H10
rol4 = a OR b OR c
END FUNCTION

FUNCTION rol5& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HF8000000) \ &H8000000 AND &H1F
b = -(n AND &H4000000) AND &H80000000
c = (n AND &H3FFFFFF) * &H20
rol5 = a OR b OR c
END FUNCTION

FUNCTION rol6& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFC000000) \ &H4000000 AND &H3F
b = -(n AND &H2000000) AND &H80000000
c = (n AND &H1FFFFFF) * &H40
rol6 = a OR b OR c
END FUNCTION

FUNCTION rol7& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFE000000) \ &H2000000 AND &H7F
b = -(n AND &H1000000) AND &H80000000
c = (n AND &HFFFFFF) * &H80
rol7 = a OR b OR c
END FUNCTION

FUNCTION rol9& (n AS LONG)
DIM a AS LONG, b AS LONG, c AS LONG
a = (n AND &HFF800000) \ &H800000 AND &H1FF
b = -(n AND &H400000) AND &H80000000
c = (n AND &H3FFFFF) * &H200
rol9 = a OR b OR c
END FUNCTION

SUB test
IF binhex(md5("")) <> "d41d8cd98f00b204e9800998ecf8427e" THEN STOP
IF binhex(md5("A")) <> "7fc56270e7a70fa81a5935b72eacbe29" THEN STOP
IF binhex(md5("password")) <> "5f4dcc3b5aa765d61d8327deb882cf99" THEN STOP
IF binhex(md5(CHR$(&H0) + CHR$(&HFF) + CHR$(&HF) + CHR$(&HF0) + CHR$(&H33) + CHR$(&HCC) + CHR$(&H55) + CHR$(&HAA))) <> "cb16906543c272af4b8dae1a4c5fe49e" THEN STOP
IF binhex(md5(STRING$(54, "a"))) <> "eced9e0b81ef2bba605cbc5e2e76a1d0" THEN STOP
IF binhex(md5(STRING$(55, "a"))) <> "ef1772b6dff9a122358552954ad0df65" THEN STOP
IF binhex(md5(STRING$(56, "a"))) <> "3b0c8ac703f828b04c6c197006d17218" THEN STOP
IF binhex(md5(STRING$(57, "a"))) <> "652b906d60af96844ebd21b674f35e93" THEN STOP
IF binhex(md5("ximaz")) <> "61529519452809720693702583126814" THEN STOP
IF binhex(md5("cbaabcdljdac")) <> "cadbfdfecdcdcdacdbbbfadbcccefabd" THEN STOP
PRINT "The md5() function works correctly."
END SUB

SUB testspeed
DIM starttime AS SINGLE, hash AS STRING, score AS LONG
IF TIMER > 86400 - 15 THEN PRINT "Wait 15 s and try again.": EXIT SUB
PRINT "Speed test running."
starttime = TIMER
DO
    hash = md5("password")
    score = score + 1
LOOP WHILE TIMER - starttime < 10
PRINT "Hashes computed in 10 seconds:"; score
END SUB

