
@{{BLOCK(text)

@=======================================================================
@
@	text, 760x8@8, 
@	+ palette 2 entries, not compressed
@	+ 95 tiles not compressed
@	Total size: 4 + 6080 = 6084
@
@	Time-stamp: 2017-08-17, 19:31:31
@	Exported by Cearn's GBA Image Transmogrifier, v0.8.14
@	( http://www.coranac.com/projects/#grit )
@
@=======================================================================

	.section .rodata
	.align	2
	.global textTiles		@ 6080 unsigned chars
	.hidden textTiles
textTiles:
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x01000000,0x00000100,0x01000000,0x00000100,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x01000000,0x00000100,0x01000000,0x00000100,0x01010100,0x01010101,0x01000000,0x00000100
	.word 0x01010100,0x01010101,0x01000000,0x00000100,0x01000000,0x00000100,0x00000000,0x00000000

	.word 0x00000000,0x00000001,0x01000000,0x00010101,0x00010000,0x00000001,0x01000000,0x00000101
	.word 0x00000000,0x00010001,0x01010000,0x00000101,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x01010000,0x00010000,0x01010000,0x00000100,0x00000000,0x00000001
	.word 0x01000000,0x00010100,0x00010000,0x00010100,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x01000000,0x00000001,0x00010000,0x00000001,0x01000000,0x00000000,0x00010000,0x00000001
	.word 0x00000100,0x00010100,0x00000100,0x00000100,0x01010000,0x00010001,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000

	.word 0x00000000,0x00000100,0x00000000,0x00000001,0x01000000,0x00000000,0x01000000,0x00000000
	.word 0x01000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000100,0x00000000,0x00000000
	.word 0x01000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000100,0x00000000,0x00000100
	.word 0x00000000,0x00000100,0x00000000,0x00000001,0x01000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x00000100,0x01000001,0x00010000,0x00010001,0x01000000,0x00000101
	.word 0x00010000,0x00010001,0x00000100,0x01000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x01010100,0x01010101
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000

	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000100,0x00000000,0x00000001
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x01010100,0x01010101
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x01000000,0x00000000,0x00010000,0x00000000,0x00000100,0x00000000,0x00000001
	.word 0x01000000,0x00000000,0x00010000,0x00000000,0x00000100,0x00000000,0x00000000,0x00000000

	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010001
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x01000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00000000,0x00010000,0x00000000,0x00000100
	.word 0x00000000,0x00000001,0x01000000,0x00000000,0x01010000,0x00010101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00000000,0x00010000,0x00000000,0x00000101
	.word 0x00000000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x00000000,0x00000101,0x01000000,0x00000100,0x00010000,0x00000100,0x01010000,0x00010101
	.word 0x00000000,0x00000100,0x00000000,0x00000100,0x00000000,0x00010101,0x00000000,0x00000000
	.word 0x01010000,0x00010101,0x00010000,0x00000000,0x00010000,0x00000000,0x01010000,0x00000101
	.word 0x00000000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00000000,0x01010000,0x00000101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x01010000,0x00010101,0x00000000,0x00010000,0x00000000,0x00000100,0x00000000,0x00000001
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000000

	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00010101
	.word 0x00000000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000101,0x00000000,0x00000101,0x00000000,0x00000100,0x00000000,0x00000001

	.word 0x00000000,0x00000100,0x00000000,0x00000001,0x01000000,0x00000000,0x00010000,0x00000000
	.word 0x01000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000100,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01010100,0x01010101,0x00000000,0x00000000
	.word 0x01010100,0x01010101,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00010000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000100
	.word 0x00000000,0x00000001,0x01000000,0x00000000,0x00010000,0x00000000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00000000,0x00010000,0x00000000,0x00000100
	.word 0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000000

	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010101,0x00010000,0x00010001
	.word 0x00010000,0x00010101,0x00010000,0x00000000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00010101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x01010000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00000101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00000101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00000000,0x00010000,0x00000000
	.word 0x00010000,0x00000000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x01010000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00000101,0x00000000,0x00000000
	.word 0x01010000,0x00010101,0x00010000,0x00000000,0x00010000,0x00000000,0x01010000,0x00000101
	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x01010000,0x00010101,0x00000000,0x00000000
	.word 0x01010000,0x00010101,0x00010000,0x00000000,0x00010000,0x00000000,0x01010000,0x00010101
	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x00010000,0x00000000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00000000,0x00010000,0x00010101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00010101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00010101,0x00000000,0x00000100,0x00000000,0x00000100,0x00000000,0x00000100
	.word 0x00010000,0x00000100,0x00010000,0x00000100,0x01000000,0x00000001,0x00000000,0x00000000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00000100,0x01010000,0x00000001
	.word 0x00010000,0x00000100,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000

	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00010101,0x00000000,0x00000000
	.word 0x00000100,0x01000000,0x00010100,0x01010000,0x01000100,0x01000100,0x00000100,0x01000001
	.word 0x00000100,0x01000000,0x00000100,0x01000000,0x00000100,0x01000000,0x00000000,0x00000000
	.word 0x00010000,0x00010000,0x01010000,0x00010000,0x00010000,0x00010001,0x00010000,0x00010001
	.word 0x00010000,0x00010100,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x01000000,0x00000101,0x01000000,0x00010000,0x01000000,0x00010000,0x01000000,0x00000101
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00010100
	.word 0x01010000,0x00000101,0x00010000,0x00010000,0x00010000,0x00010000,0x01010000,0x00000101
	.word 0x00010000,0x00000001,0x00010000,0x00000100,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00010000,0x00010000,0x00010000,0x00000000,0x01000000,0x00000101
	.word 0x00000000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x01010000,0x00010101,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000100
	.word 0x01000000,0x00000100,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000100,0x01000000,0x00000100,0x01000000,0x00000100,0x01000000,0x00010000,0x00010001
	.word 0x00010000,0x00010001,0x01000000,0x00000100,0x01000000,0x00000100,0x00000000,0x00000000

	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000100,0x00000000,0x00000001
	.word 0x01000000,0x00000100,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000100,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x01010000,0x00010101,0x00000000,0x00010000,0x00000000,0x00000100,0x00000000,0x00000001
	.word 0x01000000,0x00000000,0x00010000,0x00000000,0x01010000,0x00010101,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x00000100,0x00000000,0x00010000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000001
	.word 0x00000000,0x00000100,0x00000000,0x00010000,0x00000000,0x01000000,0x00000000,0x00000000
	.word 0x01000000,0x00000101,0x00000000,0x00000100,0x00000000,0x00000100,0x00000000,0x00000100
	.word 0x00000000,0x00000100,0x00000000,0x00000100,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000001,0x01000000,0x00000100,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x01010100,0x01010101

	.word 0x01000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x01000000,0x00000101,0x00000000,0x00010000,0x01000000,0x00010101
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x01000101,0x00000000,0x00000000
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000101,0x01000000,0x00010000
	.word 0x01000000,0x00010000,0x01000000,0x00010000,0x00010000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00000101,0x00010000,0x00000000
	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x00000000,0x00010000,0x00000000,0x00010000,0x00000000,0x00010101,0x01000000,0x00010000
	.word 0x01000000,0x00010000,0x01000000,0x00010000,0x00000000,0x01000101,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00000101,0x00010000,0x00010000
	.word 0x01010000,0x00010101,0x00010000,0x00000000,0x01000000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000101,0x01000000,0x00010000,0x01000000,0x00000000,0x01010000,0x00000001
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x01000101,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x01000000,0x00010101,0x00000000,0x00010000,0x01000000,0x00000101

	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x00010000,0x00000101,0x01010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000000,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x01010000,0x00000000
	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x00010000,0x00000100,0x00010000,0x00000001
	.word 0x01010000,0x00000000,0x00010000,0x00000001,0x00010000,0x00000100,0x00000000,0x00000000

	.word 0x01000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01010001,0x00010100,0x00000100,0x01000001
	.word 0x00000100,0x01000001,0x00000100,0x01000000,0x00000100,0x01000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00000101,0x01000000,0x00010000
	.word 0x01000000,0x00010000,0x01000000,0x00010000,0x01000000,0x00010000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00000101,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x00010000,0x00010000,0x01000000,0x00000101,0x00000000,0x00000000

	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00000101,0x01000000,0x00010000
	.word 0x01000000,0x00010000,0x01000000,0x00000101,0x01000000,0x00000000,0x01000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00010001,0x00010000,0x00000100
	.word 0x00010000,0x00000100,0x01000000,0x00000101,0x00000000,0x00000100,0x00000000,0x00000100
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00000101,0x01010000,0x00000000
	.word 0x00010000,0x00000000,0x00010000,0x00000000,0x00010000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00000101,0x00010000,0x00000000
	.word 0x01000000,0x00000001,0x00000000,0x00000100,0x01010000,0x00000001,0x00000000,0x00000000

	.word 0x00000000,0x00000000,0x00000000,0x00000001,0x01000000,0x00000101,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00000100,0x00010000,0x00000100
	.word 0x00010000,0x00000100,0x00010000,0x00000100,0x01000000,0x00010001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00010000,0x00010000,0x00010000
	.word 0x00010000,0x00010000,0x01000000,0x00000100,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00000100,0x01000000,0x00000100,0x01000000
	.word 0x00000100,0x01000001,0x01000100,0x01000100,0x00010000,0x00010000,0x00000000,0x00000000

	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x00010000,0x00010000,0x01000000,0x00000100
	.word 0x00000000,0x00000001,0x01000000,0x00000100,0x00010000,0x00010000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01000000,0x00010000,0x01000000,0x00010000
	.word 0x01000000,0x00010000,0x00000000,0x00010101,0x00000000,0x00010000,0x01000000,0x00000101
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01010000,0x00000101,0x00000000,0x00000100
	.word 0x00000000,0x00000001,0x01000000,0x00000000,0x01010000,0x00000101,0x00000000,0x00000000
	.word 0x00000000,0x00000101,0x01000000,0x00000000,0x01000000,0x00000000,0x00010000,0x00000000
	.word 0x01000000,0x00000000,0x01000000,0x00000000,0x00000000,0x00000101,0x00000000,0x00000000

	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000000
	.word 0x01010000,0x00000000,0x00000000,0x00000001,0x00000000,0x00000001,0x00000000,0x00000100
	.word 0x00000000,0x00000001,0x00000000,0x00000001,0x01010000,0x00000000,0x00000000,0x00000000
	.word 0x00000000,0x00000000,0x00000000,0x00000000,0x01010000,0x00000000,0x00000100,0x01000001
	.word 0x00000000,0x00010100,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000

	.section .rodata
	.align	2
	.global textPal		@ 4 unsigned chars
	.hidden textPal
textPal:
	.hword 0x0000,0x7BFF

@}}BLOCK(text)
