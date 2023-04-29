/* Linker script for RISC-V */

ENTRY(_start)

SECTIONS {
    /* Set the code starting address to 0x80000000 */
    . = 0x80000000;
    .text : {
        *(.text)
    }

    /* Set the data starting address to 0x80001000 */
    . = 0x80001000;
    .data : {
        *(.data)
    }
}


