Sixnix
======

Mutifarious and portable *nix assembly "Hello World" that runs unmodified on Intel 64 bit 
versions of:

- Linux
- OpenBSD
- FreeBSD
- Dragonfly BSD
- NetBSD
- OpenIndiana (SunOS)

Assemble this to make a binary that prints "Linux" on x86-64 Linux, "BSD" on x86-64 BSD 
variants and "SunOS" on x86-64 Solaris (tested with OpenIndiana). 

As the Linux x86-64 syscalls are numbered differently than BSD or SunOS a simple test is 
used to determine if we're on Linux; Syscall 6 (sys_close on BSD/SunOS and sys_lstat on 
Linux) is called with the first argument being a pointer to the string /proc/self/stat,on 
Linux we get a return code of 0 as the file exists but on BSD/SunOS this is sys_close  with 
an invalid FD so we get -1. 

Next we test for SunOS by attempting to chdir into /system, if unsuccessful we can jump to
the BSD code. 

Structurally the file is a standard ELF x86-64 binary with the addition of two additional 
mandatory secions '.note.openbsd.ident' for OpenBSD and '.note.netbsd.ident' for 'NetBSD'. 
The OSABI field in the ELF header must also be set to 0x09 ("FreeBSD") for FreeBSD to load the 
file. 

Assemble on Linux with:
```
nasm -f elf64 -o sixnix.o sixnix.asm
ld -o sixnix sixnix.o
elfedit --output-oabi FreeBSD sixnix 

$ file sixnix
sixnix: ELF 64-bit LSB executable, x86-64, version 1 (FreeBSD), statically linked, 
for OpenBSD, for NetBSD 2.0, not stripped

``` 
Linux:
```
$ strace ./sixnix 
execve("./sixnix", ["./sixnix"], [/* 28 vars */]) = 0
lstat("/proc/self/stat", {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
write(1, "Linux\n", 6Linux
)                  = 6
_exit(42)                               = ?
```
OpenBSD:
```
$ kdump                  
 26458 ktrace   EMUL  "native"
 26458 ktrace   RET   ktrace 0
 26458 ktrace   CALL  execve(0x7f7ffffdf53f,0x7f7ffffdf448,0x7f7ffffdf458)
 26458 ktrace   NAMI  "/tmp/sixnix"
 26458 sixnix   EMUL  "native"
 26458 sixnix   RET   execve 0
 26458 sixnix   CALL  close(0x6001fc)
 26458 sixnix   RET   close -1 errno 9 Bad file descriptor
 26458 sixnix   CALL  chdir(0x6001f4)
 26458 sixnix   NAMI  "/system"
 26458 sixnix   RET   chdir -1 errno 2 No such file or directory
 26458 sixnix   CALL  write(0x1,0x600212,0x4)
 26458 sixnix   GIO   fd 1 wrote 4 bytes
       "BSD
       "
 26458 sixnix   RET   write 4
 26458 sixnix   CALL  exit(0x45)
```
FreeBSD:
```
$ kdump
   817 ktrace   RET   ktrace 0
   817 ktrace   CALL  execve(0x7fffffffdde7,0x7fffffffdbc8,0x7fffffffdbd8)
   817 ktrace   NAMI  "./sixnix"
   817 sixnix   RET   execve 0
   817 sixnix   CALL  close(0x6001fc)
   817 sixnix   RET   close -1 errno 9 Bad file descriptor
   817 sixnix   CALL  chdir(0x6001f4)
   817 sixnix   NAMI  "/system"
   817 sixnix   RET   chdir -1 errno 2 No such file or directory
   817 sixnix   CALL  write(0x1,0x600212,0x4)
   817 sixnix   GIO   fd 1 wrote 4 bytes
       "BSD
       "
   817 sixnix   RET   write 4
   817 sixnix   CALL  exit(0x45)
```
DragonflyBSD
```
$ kdump
  810 ktrace   RET   ktrace 0
  810 ktrace   CALL  execve(0x7ffffffffab7,0x7ffffffff890,0x7ffffffff8a0)
  810 ktrace   NAMI  "./sixnix"
  810 sixnix   RET   execve 0
  810 sixnix   CALL  close(0x6001fc)
  810 sixnix   RET   close -1 errno 9 Bad file descriptor
  810 sixnix   CALL  chdir(0x6001f4)
  810 sixnix   NAMI  "/system"
  810 sixnix   RET   chdir -1 errno 2 No such file or directory
  810 sixnix   CALL  write(0x1,0x600212,0x4)
  810 sixnix   GIO   fd 1 wrote 4 bytes
       "BSD
       "
  810 sixnix   RET   write 4
  810 sixnix   CALL  exit(0x45)
```
NetBSD
```
$ kdump
   106      1 ktrace   EMUL  "netbsd"
   106      1 ktrace   RET   ktrace 0
   106      1 ktrace   CALL  execve(0x7f7ffffffe57,0x7f7fffffdc90,0x7f7fffffdca0)
   106      1 ktrace   NAMI  "./sixnix"
   106      1 sixnix   EMUL  "netbsd"
   106      1 sixnix   RET   execve JUSTRETURN
   106      1 sixnix   CALL  close(0x6001fc)
   106      1 sixnix   RET   close -1 errno 9 Bad file descriptor
   106      1 sixnix   CALL  chdir(0x6001f4)
   106      1 sixnix   NAMI  "/system"
   106      1 sixnix   RET   chdir -1 errno 2 No such file or directory
   106      1 sixnix   CALL  write(1,0x600212,4)
   106      1 sixnix   GIO   fd 1 wrote 4 bytes
       "BSD\n"
   106      1 sixnix   RET   write 4
   106      1 sixnix   CALL  exit(0x45)
```
OpenIndiana (SunOS): 
```
$ truss /tmp/sixnix
execve("/tmp/sixnix", 0xFFFFFD7FFFDFFDE8, 0xFFFFFD7FFFDFFDF8)  argc = 1
close(6291964)                                  Err#9 EBADF
chdir("/system")                                = 0
SunOS
write(1, " S u n O S\n", 6)                     = 6
_exit(69)
```
