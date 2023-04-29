OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
    . = 0x80000000;
    .text : { *(.text) }

    . = 0x80001000;
    .data : { *(.data) }

    . = ALIGN(0x10000);
    .tohost : { *(.tohost) }

    . = ALIGN(0x10000);
    .data.string : { *(.data.string)}

    .bss : { *(.bss) }
    _end = .;
}
