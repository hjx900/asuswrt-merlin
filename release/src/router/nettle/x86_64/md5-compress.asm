C x86_64/md5-compress.asm

ifelse(<
   Copyright (C) 2005, 2013 Niels Möller

   This file is part of GNU Nettle.

   GNU Nettle is free software: you can redistribute it and/or
   modify it under the terms of either:

     * the GNU Lesser General Public License as published by the Free
       Software Foundation; either version 3 of the License, or (at your
       option) any later version.

   or

     * the GNU General Public License as published by the Free
       Software Foundation; either version 2 of the License, or (at your
       option) any later version.

   or both in parallel, as here.

   GNU Nettle is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received copies of the GNU General Public License and
   the GNU Lesser General Public License along with this program.  If
   not, see http://www.gnu.org/licenses/.
>)

C Registers:

define(<STATE>, <%rdi>)
define(<INPUT>, <%rsi>)
define(<SA>,<%rax>)
define(<SB>,<%rbx>)
define(<SC>,<%rcx>)
define(<SD>,<%rbp>)
define(<TMP>, <%r8>)

C F1(x,y,z) = (z ^ (x & (y ^ z)))
define(<F1>, <
	movl	XREG($3), XREG(TMP)
	xorl	XREG($2), XREG(TMP)
	andl	XREG($1), XREG(TMP)
	xorl	XREG($3), XREG(TMP)>)

define(<F2>,<F1($3, $1, $2)>)

C F3(x,y,z) = x ^ y ^ z
define(<F3>,<
	movl	XREG($1), XREG(TMP)
	xorl	XREG($2), XREG(TMP)
	xorl	XREG($3), XREG(TMP)>)

C F4(x,y,z) = y ^ (x | ~z)
define(<F4>,<
	movl	XREG($3), XREG(TMP)
	notl	XREG(TMP)
	orl	XREG($1), XREG(TMP)
	xorl	XREG($2), XREG(TMP)>)

C Index to 4*i, or to the empty string if zero
define(<REF>,<ifelse($1,0,,eval(4*$1))(INPUT)>)

C ROUND(f, w, x, y, z, k, data, s):
C	w += f(x,y,z) + data + k
C	w <<< s
C	w += x
define(<ROUND>,<
	addl	<$>$7, XREG($2)
	$1($3, $4, $5)
	addl	$6, XREG($2)
	addl	XREG(TMP), XREG($2)
	roll	<$>$8, XREG($2)
	addl	XREG($3), XREG($2)>)

	.file "md5-compress.asm"

	C _nettle_md5_compress(uint32_t *state, uint8_t *input)
	.text
	ALIGN(16)
PROLOGUE(_nettle_md5_compress)
	W64_ENTRY(2,0)
	C save all registers that need to be saved
	push	%rbp
	push	%rbx

	C load the state vector
	movl	(STATE),   XREG(SA)
	movl	4(STATE),  XREG(SB)
	movl	8(STATE),  XREG(SC)
	movl	12(STATE), XREG(SD)

	ROUND(<F1>, SA, SB, SC, SD, REF( 0), 0xd76aa478, 7)
	ROUND(<F1>, SD, SA, SB, SC, REF( 1), 0xe8c7b756, 12)
	ROUND(<F1>, SC, SD, SA, SB, REF( 2), 0x242070db, 17)
	ROUND(<F1>, SB, SC, SD, SA, REF( 3), 0xc1bdceee, 22)
	ROUND(<F1>, SA, SB, SC, SD, REF( 4), 0xf57c0faf, 7)
	ROUND(<F1>, SD, SA, SB, SC, REF( 5), 0x4787c62a, 12)
	ROUND(<F1>, SC, SD, SA, SB, REF( 6), 0xa8304613, 17)
	ROUND(<F1>, SB, SC, SD, SA, REF( 7), 0xfd469501, 22)
	ROUND(<F1>, SA, SB, SC, SD, REF( 8), 0x698098d8, 7)
	ROUND(<F1>, SD, SA, SB, SC, REF( 9), 0x8b44f7af, 12)
	ROUND(<F1>, SC, SD, SA, SB, REF(10), 0xffff5bb1, 17)
	ROUND(<F1>, SB, SC, SD, SA, REF(11), 0x895cd7be, 22)
	ROUND(<F1>, SA, SB, SC, SD, REF(12), 0x6b901122, 7)
	ROUND(<F1>, SD, SA, SB, SC, REF(13), 0xfd987193, 12)
	ROUND(<F1>, SC, SD, SA, SB, REF(14), 0xa679438e, 17)
	ROUND(<F1>, SB, SC, SD, SA, REF(15), 0x49b40821, 22)

	ROUND(<F2>, SA, SB, SC, SD, REF( 1), 0xf61e2562, 5)
	ROUND(<F2>, SD, SA, SB, SC, REF( 6), 0xc040b340, 9)
	ROUND(<F2>, SC, SD, SA, SB, REF(11), 0x265e5a51, 14)
	ROUND(<F2>, SB, SC, SD, SA, REF( 0), 0xe9b6c7aa, 20)
	ROUND(<F2>, SA, SB, SC, SD, REF( 5), 0xd62f105d, 5)
	ROUND(<F2>, SD, SA, SB, SC, REF(10), 0x02441453, 9)
	ROUND(<F2>, SC, SD, SA, SB, REF(15), 0xd8a1e681, 14)
	ROUND(<F2>, SB, SC, SD, SA, REF( 4), 0xe7d3fbc8, 20)
	ROUND(<F2>, SA, SB, SC, SD, REF( 9), 0x21e1cde6, 5)
	ROUND(<F2>, SD, SA, SB, SC, REF(14), 0xc33707d6, 9)
	ROUND(<F2>, SC, SD, SA, SB, REF( 3), 0xf4d50d87, 14)
	ROUND(<F2>, SB, SC, SD, SA, REF( 8), 0x455a14ed, 20)
	ROUND(<F2>, SA, SB, SC, SD, REF(13), 0xa9e3e905, 5)
	ROUND(<F2>, SD, SA, SB, SC, REF( 2), 0xfcefa3f8, 9)
	ROUND(<F2>, SC, SD, SA, SB, REF( 7), 0x676f02d9, 14)
	ROUND(<F2>, SB, SC, SD, SA, REF(12), 0x8d2a4c8a, 20)

	ROUND(<F3>, SA, SB, SC, SD, REF( 5), 0xfffa3942, 4)
	ROUND(<F3>, SD, SA, SB, SC, REF( 8), 0x8771f681, 11)
	ROUND(<F3>, SC, SD, SA, SB, REF(11), 0x6d9d6122, 16)
	ROUND(<F3>, SB, SC, SD, SA, REF(14), 0xfde5380c, 23)
	ROUND(<F3>, SA, SB, SC, SD, REF( 1), 0xa4beea44, 4)
	ROUND(<F3>, SD, SA, SB, SC, REF( 4), 0x4bdecfa9, 11)
	ROUND(<F3>, SC, SD, SA, SB, REF( 7), 0xf6bb4b60, 16)
	ROUND(<F3>, SB, SC, SD, SA, REF(10), 0xbebfbc70, 23)
	ROUND(<F3>, SA, SB, SC, SD, REF(13), 0x289b7ec6, 4)
	ROUND(<F3>, SD, SA, SB, SC, REF( 0), 0xeaa127fa, 11)
	ROUND(<F3>, SC, SD, SA, SB, REF( 3), 0xd4ef3085, 16)
	ROUND(<F3>, SB, SC, SD, SA, REF( 6), 0x04881d05, 23)
	ROUND(<F3>, SA, SB, SC, SD, REF( 9), 0xd9d4d039, 4)
	ROUND(<F3>, SD, SA, SB, SC, REF(12), 0xe6db99e5, 11)
	ROUND(<F3>, SC, SD, SA, SB, REF(15), 0x1fa27cf8, 16)
	ROUND(<F3>, SB, SC, SD, SA, REF( 2), 0xc4ac5665, 23)

	ROUND(<F4>, SA, SB, SC, SD, REF( 0), 0xf4292244, 6)
	ROUND(<F4>, SD, SA, SB, SC, REF( 7), 0x432aff97, 10)
	ROUND(<F4>, SC, SD, SA, SB, REF(14), 0xab9423a7, 15)
	ROUND(<F4>, SB, SC, SD, SA, REF( 5), 0xfc93a039, 21)
	ROUND(<F4>, SA, SB, SC, SD, REF(12), 0x655b59c3, 6)
	ROUND(<F4>, SD, SA, SB, SC, REF( 3), 0x8f0ccc92, 10)
	ROUND(<F4>, SC, SD, SA, SB, REF(10), 0xffeff47d, 15)
	ROUND(<F4>, SB, SC, SD, SA, REF( 1), 0x85845dd1, 21)
	ROUND(<F4>, SA, SB, SC, SD, REF( 8), 0x6fa87e4f, 6)
	ROUND(<F4>, SD, SA, SB, SC, REF(15), 0xfe2ce6e0, 10)
	ROUND(<F4>, SC, SD, SA, SB, REF( 6), 0xa3014314, 15)
	ROUND(<F4>, SB, SC, SD, SA, REF(13), 0x4e0811a1, 21)
	ROUND(<F4>, SA, SB, SC, SD, REF( 4), 0xf7537e82, 6)
	ROUND(<F4>, SD, SA, SB, SC, REF(11), 0xbd3af235, 10)
	ROUND(<F4>, SC, SD, SA, SB, REF( 2), 0x2ad7d2bb, 15)
	ROUND(<F4>, SB, SC, SD, SA, REF( 9), 0xeb86d391, 21)

	C Update the state vector
	addl	XREG(SA), (STATE)
	addl	XREG(SB), 4(STATE)
	addl	XREG(SC), 8(STATE)
	addl	XREG(SD), 12(STATE)

	pop	%rbx
	pop	%rbp
	W64_EXIT(2,0)

	ret
EPILOGUE(_nettle_md5_compress)
