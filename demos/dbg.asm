// Assembler: KickAssembler 4.4
// All made by myself

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}
