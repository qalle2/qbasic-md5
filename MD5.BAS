DECLARE FUNCTION hashchunk$ (origstate&(), chunk&())
DECLARE FUNCTION prepmsg$ (msg$)
DECLARE SUB test ()
DECLARE FUNCTION add& (a&, b&)
DECLARE FUNCTION md5$ (msg$)
DECLARE FUNCTION binhex$ (stri$)
DECLARE FUNCTION sine& (r%)
DECLARE FUNCTION rol& (n&, r%)
DECLARE SUB testspeed ()

DIM SHARED pow2&(31), pow2m1&(31)
DIM SHARED sines&(63), chunkindexes%(63), rotcounts%(63)

' rotate counts
DATA 7,12,17,22, 5,9,14,20, 4,11,16,23, 6,10,15,21

' generate powers of 2
FOR i% = 0 TO 30: pow2&(i%) = 2 ^ i%: NEXT
pow2&(31) = &H80000000

' generate powers of 2 minus 1
FOR i% = 0 TO 31: pow2m1&(i%) = 2 ^ i% - 1: NEXT

' generate sine constant table
FOR i% = 0 TO 63: sines&(i%) = sine&(i%): NEXT

' generate chunk index table
FOR i% = 0 TO 63
    IF i% < 16 THEN
        chunkindexes%(i%) = i%
    ELSEIF i% < 32 THEN
        chunkindexes%(i%) = (i% * 5 + 1) MOD 16
    ELSEIF i% < 48 THEN
        chunkindexes%(i%) = (i% * 3 + 5) MOD 16
    ELSE
        chunkindexes%(i%) = i% * 7 MOD 16
    END IF
NEXT

' generate rotate counts table
FOR i% = 0 TO 3
    FOR j% = 0 TO 3
        READ rotcount%
        FOR k% = 0 TO 3
            rotcounts%(i% * 16 + k% * 4 + j%) = rotcount%
        NEXT
    NEXT
NEXT

CLS
CALL test
'CALL testspeed

FUNCTION add& (a&, b&)
' add two unsigned LONGs

' sum of bits 29-0
losum& = (a& AND &H3FFFFFFF) + (b& AND &H3FFFFFFF)

' carry for bit 31 (&H80000000 if at least two of a, b and losum have bit 30
' set)
carry& = (a& AND b&) OR (a& AND losum&) OR (b& AND losum&)
carry& = -(carry& AND &H40000000) AND &H80000000

' bits of sum:
' 31:   (a XOR b XOR carry) AND &H80000000
' 30:   (a XOR b XOR losum) AND &H40000000
' 29-0: losum AND &H3FFFFFFF
' 30-0: ((a XOR b) AND &H40000000) XOR losum
' 31-0:    ( ((a XOR b) AND &H80000000) XOR carry )
'       OR ( ((a XOR b) AND &H40000000) XOR losum )
'     =      ((a XOR b) AND &HC0000000) XOR (carry OR losum)

add& = ((a& XOR b&) AND &HC0000000) XOR (carry& OR losum&)

END FUNCTION

FUNCTION binhex$ (stri$)
' Convert string into hexadecimal.

hexa$ = ""
FOR i% = 1 TO LEN(stri$)
    hexa$ = hexa$ + RIGHT$("0" + LCASE$(HEX$(ASC(MID$(stri$, i%, 1)))), 2)
NEXT
binhex$ = hexa$

END FUNCTION

FUNCTION hashchunk$ (origstate&(), chunk&())
' Hash one chunk. state&(): 4 items, chunk&(): 16 items. Return 16 bytes.

DIM state&(3)

' only change copy of argument
FOR i% = 0 TO 3: state&(i%) = origstate&(i%): NEXT

' run 64 rounds
FOR r% = 0 TO 63
    IF r% < 16 THEN
        temp& = ((state&(2) XOR state&(3)) AND state&(1)) XOR state&(3)
    ELSEIF r% < 32 THEN
        temp& = ((state&(1) XOR state&(2)) AND state&(3)) XOR state&(2)
    ELSEIF r% < 48 THEN
        temp& = state&(1) XOR state&(2) XOR state&(3)
    ELSE
        temp& = (state&(1) OR NOT state&(3)) XOR state&(2)
    END IF

    temp& = add(temp&, state&(0))
    temp& = add(temp&, sines&(r%))
    temp& = add(temp&, chunk&(chunkindexes%(r%)))
    temp& = rol(temp&, rotcounts%(r%))
    temp& = add(temp&, state&(1))
      
    state&(0) = state&(3)
    state&(3) = state&(2)
    state&(2) = state&(1)
    state&(1) = temp&
NEXT

FOR i% = 0 TO 3: hash$ = hash$ + MKL$(state&(i%)): NEXT
hashchunk$ = hash$

END FUNCTION

FUNCTION md5$ (msg$)
' Compute MD5. Return 128 bits as 16 bytes.

DIM state&(3)   ' state of MD5 algorithm
DIM chunk&(15)  ' one chunk of padded message

IF LEN(msg) > 8192 THEN PRINT "Message too long.": END

' prepare message
msg$ = prepmsg(msg$)

' set initial state
state&(0) = &H67452301
state&(1) = &HEFCDAB89
state&(2) = &H98BADCFE
state&(3) = &H10325476

' for each 64-byte chunk...
FOR chunkpos% = 1 TO LEN(msg$) STEP 64
    ' split into 16 * 32-bit ints
    FOR i% = 0 TO 15
        chunk&(i%) = CVL(MID$(msg$, chunkpos% + i% * 4, 4))
    NEXT
    ' hash it
    chunkh$ = hashchunk(state&(), chunk&())
    ' add to state
    FOR i% = 0 TO 3
        state&(i%) = add(state&(i%), CVL(MID$(chunkh$, i% * 4 + 1, 4)))
    NEXT
NEXT

' hash = final state
FOR i% = 0 TO 3: hash$ = hash$ + MKL$(state&(i%)): NEXT
md5$ = hash$

END FUNCTION

FUNCTION prepmsg$ (msg$)
' Prepare message for hashing.

leng% = LEN(msg$)
pad% = (55 + 64 - (leng% MOD 64)) MOD 64  ' pad to 64n bytes
prepmsg = msg$ + CHR$(&H80) + STRING$(pad%, &H0) + MKL$(leng% * 8&) + MKL$(0)

END FUNCTION

FUNCTION rol& (n&, r%)
' rotate n& left by r% bits

' example: r% = 4:
'   bits: aaaa bccc cccc cccc cccc cccc cccc cccc
'   ->    bccc cccc cccc cccc cccc cccc cccc aaaa
'
'   a& =  (n& AND &HF0000000) \ &H10000000 AND &HF
'   b& = -(n& AND &H08000000)              AND &H80000000
'   c& =  (n& AND &H07FFFFFF) * &H10
'   rol& = a& OR b& OR c&

' shift r% MSBs to LSBs
a& = (n& AND NOT pow2m1&(32 - r%)) \ pow2&(32 - r%) AND pow2m1&(r%)

' shift correct bit to MSB
b& = -(n& AND pow2&(31 - r%)) AND &H80000000

' shift the rest left
c& = (n& AND pow2m1&(31 - r%)) * pow2&(r%)

' combine
rol& = a& OR b& OR c&

END FUNCTION

FUNCTION sine& (r%)
' get sine constant for round n% (0-63)

temp# = ABS(SIN(r% + 1)) * &H10000
hi& = INT(temp#)
lo& = INT((temp# - hi&) * &H10000)
sine& = rol(hi&, 16) OR lo&

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

PRINT "Speed test running."
starttime! = TIMER

DO
    hash$ = md5("password")
    score& = score& + 1
LOOP WHILE TIMER - starttime! < 10

PRINT "Hashes computed in 10 seconds:"; score&
END SUB

