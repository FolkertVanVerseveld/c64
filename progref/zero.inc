#importonce
/* Zero Page Memory Map */
.const d6510   = $0000 //              6510 On-Chip Data-Direction Register
.const r6510   = $0001 //              6510 On-Chip 8-Bit Input/Output Register
//               $0002 //              Unused
.const adray1l = $0003 // Low  Byte of Jump Vector: Convert Floating - Integer
.const adray1h = $0004 // High Byte of Jump Vector: Convert Floating - Integer
.const adray2l = $0005 // Low  Byte of Jump Vector: Convert Integer  - Float
.const adray2h = $0006 // High Byte of Jump Vector: Convert Integer  - Float
.const charac  = $0007 //              Search Character
.const endchr  = $0008 //              Flag: Scan for Quote at End of String
.const trmpos  = $0009 //              Screen Column From Last TAB
.const verck   = $000a //              Flag: 0 = Load, 1 = Verify
.const count   = $000b //              Input Buffer Pointer / No. of Subscripts
.const dimflg  = $000c //              Flag: Default Array DIMension
.const valtyp  = $000d //              Data Type: $FF = String, $00 = Numeric
.const intflg  = $000e //              Data Type: $80 = String, $00 = Floating
.const garbfl  = $000f //              Flag: DATA scan/LIST quote/Garbage Coll
.const subflg  = $0010 //              Flag: Subscript Ref / User Function Call
.const inpflg  = $0011 //              Flag: $00 = INPUT, $40 = GET, $98 = READ
.const tansgn  = $0012 //              Flag: TAN sign / Comparison Result
//               $0013 //              Flag: INPUT Prompt
.const linnuml = $0014 // Low  Byte of Temp: Integer Value
.const linnumh = $0015 // High Byte of Temp: Integer Value
.const temppt  = $0016 //              Pointer: Temporary String Stack
.const lastptl = $0017 // Low  Byte of Last Temp String Address
.const lastpth = $0018 // High Byte of Last Temp String Address
.const tempst  = $0019 //              Stack for Temporary Strings
//               $001a
//               $001b
//               $001c
//               $001d
//               $001e
//               $001f
//               $0020
//               $0021
.const index   = $0022 //              Utility Pointer Area
//               $0023
//               $0024
//               $0025
.const resho   = $0026 //              Floating-Point Product of Multiply
//               $0027
//               $0028
//               $0029
//               $002a
.const txttabl = $002b // Low  Byte of Pointer: Start of BASIC Text
.const txttabh = $002c // High Byte of Pointer: Start of BASIC Text
.const vartabl = $002d // Low  Byte of Pointer: Start of BASIC Variables
.const vartabh = $002e // High Byte of Pointer: Start of BASIC Variables
.const arytabl = $002f // Low  Byte of Pointer: Start of BASIC Arrays
.const arytabh = $0030 // High Byte of Pointer: Start of BASIC Arrays
.const strendl = $0031 // Low  Byte of Pointer: End of BASIC Arrays (+1)
.const strendh = $0032 // High Byte of Pointer: End of BASIC Arrays (+1)
.const fretopl = $0033 // Low  Byte of Pointer: Bottom of String Storage
.const fretoph = $0034 // High Byte of Pointer: Bottom of String Storage
.const frespcl = $0035 // Low  Byte of Utility String Pointer
.const frespch = $0036 // High Byte of Utility String Pointer
.const memsizl = $0037 // Low  Byte of Pointer: Highest Address Used by BASIC
.const memsizh = $0038 // High Byte of Pointer: Highest Address Used by BASIC
.const curlinl = $0039 // Low  Byte of Current BASIC Line Number
.const curlinh = $003a // High Byte of Current BASIC Line Number
.const oldlinl = $003b // Low  Byte of Previous BASIC Line Number
.const oldlinh = $003c // High Byte of Previous BASIC Line Number
.const oldtxtl = $003d // Low  Byte of Pointer: BASIC Statement for CONT
.const oldtxth = $003e // High Byte of Pointer: BASIC Statement for CONT
.const datlinl = $003f // Low  Byte of Current DATA Line Number
.const datlinh = $0040 // High Byte of Current DATA Line Number
.const datptrl = $0041 // Low  Byte of Pointer: Current DATA Item Address
.const datptrh = $0042 // High Byte of Pointer: Current DATA Item Address
.const inpptrl = $0043 // Low  Byte of Vector: INPUT Routine
.const inpptrh = $0044 // High Byte of Vector: INPUT Routine
.const varnaml = $0045 // Low  Byte of Current BASIC Variable Name
.const varnamh = $0046 // High Byte of Current BASIC Variable Name
.const varpntl = $0047 // Low  Byte of Pointer: Current BASIC Variable Data
.const varpnth = $0048 // High Byte of Pointer: Current BASIC Variable Data
.const forpntl = $0049 // Low  Byte of Pointer: Index Variable for FOR/NEXT
.const forpnth = $004a // High Byte of Pointer: Index Variable for FOR/NEXT
//               $004b //              Temp Pointer / Data Area
//               $004c
//               $004d
//               $004e
//               $004f
//               $0050
//               $0051
//               $0052
//               $0053
//               $0054
//               $0055
//               $0056
//               $0057
//               $0058
//               $0059
//               $005a
//               $005b
//               $005c
//               $005d
//               $005e
//               $005f
//               $0060
.const facexp  = $0061 //              Floating-Point Accumulator #1: Exponent
.const facho   = $0062 //              Floating Accum. #1: Mantissa
//               $0063
//               $0064
//               $0065
.const facsgn  = $0066 //              Floating Accum. #1: Sign
.const sgnflg  = $0067 //              Pointer: Series Evaluation Constant
.const bits    = $0068 //              Floating Accum. #1: Overflow Digit
.const argexp  = $0069 //              Floating-Point Accumulator #2: Exponent
.const argho   = $006a //              Floating Accum. #2: Mantissa
//               $006b
//               $006c
//               $006d
.const argsgn  = $006e //              Floating Accum. #2: Sign
.const arisgn  = $006f //              Sign Comparison Result: Accum. #1 vs #2
.const facov   = $0070 //              Floating Accum. #1. Low-Order (Rounding)
.const fbufptl = $0071 // Low  Byte of Pointer: Cassette Buffer
.const fbufpth = $0072 // High Byte of Pointer: Cassette Buffer
.const chrget  = $0073 //              Subroutine: Get Next Byte of BASIC Text
//               $0074
//               $0075
//               $0076
//               $0077
//               $0078
.const chrgot  = $0079 //              Entry to Get Same Byte of Text Again
.const txtptrl = $007a // Low  Byte of Pointer: Current Byte of BASIC Text
.const txtptrh = $007b // High Byte of Pointer: Current Byte of BASIC Text
//               $007c // Continuing:  Subroutine: Get Next Byte of BASIC Text
//               $007d
//               $007e
//               $007f
//               $0080
//               $0081
//               $0082
//               $0083
//               $0084
//               $0085
//               $0086
//               $0087
//               $0088
//               $0089
//               $008a
.const rndx    = $008b //              Floating RND Function Seed Value
//               $008c
//               $008d
//               $008e
//               $008f
.const status  = $0090 //              Kernel I/O Status Word: ST
.const stkey   = $0091 //              Flag: STOP key / RVS key
.const svxt    = $0092 //              Timing Constant for Tape
.const verck2  = $0093 //              Flag: 0 = Load, 1 = Verify
.const c3po    = $0094 //              Flag: Serial Bus - Output Char. Buffered
.const bsour   = $0095 //              Buffered Character for Serial Bus
.const syno    = $0096 //              Cassette Sync No.
//               $0097 //              Temp Data Area
.const ldtnd   = $0098 //              No. of Open Files / Index to File Table
.const dfltn   = $0099 //              Default Input Device (0)
.const dflto   = $009a //              Default Output (CMD) Device (3)
.const prty    = $009b //              Tape Character Parity
.const dpsw    = $009c //              Flag: Tape Byte-Received
.const msgflg  = $009d //              Flag: $80 = Direct Mode, $00 = Program
.const ptr1    = $009e //              Tape Pass 1 Error Log
.const ptr2    = $009f //              Tape Pass 2 Error Log
.const time    = $00a0 //              Real-Time Jiffy Clock (approx) 1/60 Sec
//               $00a1
//               $00a2
//               $00a3 //              Temp Data Area
//               $00a4
.const cntdn   = $00a5 //              Cassette Sync Countdown
.const bufpnt  = $00a6 //              Pointer: Tape I/O Buffer
.const inbit   = $00a7 //              RS-232 Input Bits / Cassette Temp
.const bitci   = $00a8 //              RS-232 Input Bit Count / Cassette Temp
.const rinone  = $00a9 //              RS-232 Flag: Check for Start Bit
.const ridata  = $00aa //              RS-232 Input Byte Buffer/Cassette Temp
.const riprty  = $00ab //              RS-232 Input Parity / Cassette Short Cnt
.const sall    = $00ac // Low  Byte of Pointer: Tape Buffer/Screen Scrolling
.const salh    = $00ad // High Byte of Pointer: Tape Buffer/Screen Scrolling
.const eall    = $00ae // Low  Byte of Tape End Addresses/End of Program
.const ealh    = $00af // High Byte of Tape End Addresses/End of Program
.const cmp0l   = $00b0 // Low  Byte of Tape Timing Constants
.const cmp0h   = $00b1 // High Byte of Tape Timing Constants
.const tape1l  = $00b2 // Low  Byte of Pointer: Start of Tape Buffer
.const tape1h  = $00b3 // High Byte of Pointer: Start of Tape Buffer
.const bitts   = $00b4 //              RS-232 Out Bit Count / Cassette Temp
.const nxtbit  = $00b5 //              RS-232 Next Bit to Send/Tape EOT Flag
.const rodata  = $00b6 //              RS-232 Out Byte Buffer
.const fnlen   = $00b7 //              Length of Current File Name
.const la      = $00b8 //              Current Logical File Number
.const sa      = $00b9 //              Current Secondary Address
.const fa      = $00ba //              Current Device Number
.const fnadrl  = $00bb // Low  Byte of Pointer: Current File Name
.const fnadrh  = $00bc // High Byte of Pointer: Current File Name
.const roprty  = $00bd //              RS-232 Out Parity / Cassette Temp
.const fsblk   = $00be //              Cassette Read/Write Block Count
.const mych    = $00bf //              Serial Word Buffer
.const cas1    = $00c0 //              Tape Motor Interlock
.const stall   = $00c1 // Low  Byte of I/O Start Address
.const stalh   = $00c2 // High Byte of I/O Start Address
.const memuss  = $00c3 //              Tape Load Temps
//               $00c4
.const lstx    = $00c5 //              Current Key Pressed: 64 = No Key
.const ndx     = $00c6 //              No. of Chars. in Keyboard Buffer (Queue)
.const rvs     = $00c7 //              Flag: Print Reverse Chars. -1=Yes, 0=No Used
.const indx    = $00c8 //              Pointer: End of Logical Line for INPUT
.const lxsp    = $00c9 //              Cursor X-Y-Pos. at Start of INPUT
//               $00ca
.const sfdx    = $00cb //              64 = No Key
.const blnsw   = $00cc //              Cursor Blink Enable: 0 = Flash Cursor
.const blnct   = $00cd //              Timer: Countdown to Toggle Cursor
.const gdbln   = $00ce //              Character Under Cursor
.const blnon   = $00cf //              Flag: Last Cursor Blink On/Off
.const crsw    = $00d0 //              Flag: Last Cursor Blink On/Off
.const pntl    = $00d1 // Low  Byte of Pointer: Current Screen Line Address
.const pnth    = $00d2 // High Byte of Pointer: Current Screen Line Address
.const pntr    = $00d3 //              Cursor Column on Current Line
.const qtsw    = $00d4 //              Flag: Editor in Quote Mode, $00 = NO
.const lnmx    = $00d5 //              Physical Screen Line Length
.const tblx    = $00d6 //              Current Cursor Physical Line Number
//               $00d7 //              Temp Data Area
.const insrt   = $00d8 //              Flag: Insert Mode, >0 = # INSTs
.const ldtb1   = $00d9 //              Screen Line Link Table / Editor Temps
//               $00da
//               $00db
//               $00dc
//               $00dd
//               $00de
//               $00df
//               $00e0
//               $00e1
//               $00e2
//               $00e3
//               $00e4
//               $00e5
//               $00e6
//               $00e7
//               $00e8
//               $00e9
//               $00ea
//               $00eb
//               $00ec
//               $00ed
//               $00ee
//               $00ef
//               $00f0
//               $00f1
//               $00f2
.const userl   = $00f3 // Low  Byte of Pointer: Current Screen Color RAM loc.
.const userh   = $00f4 // High Byte of Pointer: Current Screen Color RAM loc.
.const keytabl = $00f5 // Low  Byte of Vector: Keyboard Decode Table
.const keytabh = $00f6 // High Byte of Vector: Keyboard Decode Table
.const ribufl  = $00f7 // Low  Byte of RS-232 Input Buffer Pointer
.const ribufh  = $00f8 // High Byte of RS-232 Input Buffer Pointer
.const robufl  = $00f9 // Low  Byte of RS-232 Output Buffer Pointer
.const robufh  = $00fa // High Byte of RS-232 Output Buffer Pointer
.const frekzpl = $00fb //              Free 0-Page Space for User Programs
//               $00fc
//               $00fd
//               $00fe
.const baszpt  = $00ff //              BASIC Temp Data Area
