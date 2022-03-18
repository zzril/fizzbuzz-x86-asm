FizzBuzz in x86 assembly
========================

General:
--------

### Info:

An (x86) assembly version of the (in)famous "FizzBuzz" program.

I made this just for fun and for personal training purposes.  
For a (pseudo-) copyright notice, see in the source code.

---

### Features:

* written entirely in x86-64 assembly
* does not require glibc
* supports custom parameters for the divisors and maximum number

---

Build & run:
------------

Build with `make`.  
Run with `./fizzbuzz <divisor1> <divisor2> <maximum>`.  
Requires:
* `nasm`
* `ld.lld`
* `make` (only for automatic build)

---

Test:
-----

* `./run.sh` will run the program with (more or less) standard parameters (3/5/50).
* `./test.sh` does the same and also executes a bunch of tests for edge cases.

As of now, test results are not automatically checked in any way.

---

Contribute:
-----------

The program is pretty much complete, but if you find bugs or have suggestions  
to improve the code or add new features, you're welcome.


