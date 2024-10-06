; --------
;
; 18th March 2022
;
; An (x86) assembly version of the (in)famous "FizzBuzz" program.
;
; Free for all to use, but no warranties given. Maybe it works,
; maybe it doesn't. Maybe it makes your PC explode. I don't know.
; Although I hope it does work normally. ;)
;
; If you find bugs, please let me know. :)
;
; You are allowed to modify the source code.
; You are allowed to re-distribute it, as long as you include a
; link to my original version on GitHub.
;
; --------
; --------
SECTION .rodata
; --------

fizzbuzz_str:			db "FizzBuzz"
linefeed:			db 0xa

num_args:			dq 4

usage_err_msg:			db "Usage: `./fizzbuzz <divisor1> <divisor2> <max_number>`", 10, 0
usage_err_msg_len:		equ $ -usage_err_msg

param_divis_err_msg:		db "Divisors must be between (including) 2 and 9.", 10, 0
param_divis_err_msg_len:	equ $ -param_divis_err_msg

param_max_err_msg:		db "Max number must be between (including) 0 and 100.", 10, 0
param_max_err_msg_len:		equ $ -param_max_err_msg

; --------
; --------
SECTION .bss
; --------

divisor1:	resb	1
divisor2:	resb	1
max_number:	resw	1

buffer:		resb	8

; --------
; --------
SECTION .text
; --------

global _start

; --------

; --------
; void _start():
; Parses and verifies the command-line arguments,
; then either calls fizzbuzz or exits with error.
; Returns:	Does not return.
; --------

_start:

	mov rdi, [rsp]		; rdi = argc
	lea rsi, [rsp+8]	; rsi = argv
	call parse_cmd_line_args
	call fizzbuzz
	jmp exit_success

; --------

; --------
; void parse_cmd_line_args(uint64_t argc, char** argv):
; Parses the command-line arguments and puts them into the right global variables.
; Exits with error message on incorrect arguments.
; Expects:	rdi:	argc
;		rsi:	argv
; Returns:	(void)
; --------

parse_cmd_line_args:
	push rbx
	mov rbx, rsi	; save argv
; check argc:
	cmp rdi, [num_args]
	je parse_param1
; wrong argc:
	mov rdi, usage_err_msg_len
	mov rsi, usage_err_msg
	jmp exit_fail_with_msg

parse_param1:
;parse divisor1 := argv[1]:
	mov rsi, [rbx+1*8]
	mov rdi, 2
	mov rdx, buffer
	call antoi
	mov [divisor1], al

; check argv[1]:
	cmp byte [buffer], 0x0
	jne wrong_argv_1_or_2
	cmp al, 2
	jge parse_param2

wrong_argv_1_or_2:
	mov rdi, param_divis_err_msg_len
	mov rsi, param_divis_err_msg
	jmp exit_fail_with_msg

parse_param2:
;parse divisor2 := argv[2]:
	mov rsi, [rbx+2*8]
	mov rdi, 2
	mov rdx, buffer
	call antoi
	mov [divisor2], al

; check argv[2]:
	cmp byte [buffer], 0x0
	jne wrong_argv_1_or_2
	cmp al, 2
	jl wrong_argv_1_or_2

parse_param3:
;parse max_number := argv[3]:
	mov rsi, [rbx+3*8]
	mov rdi, 8
	mov rdx, buffer
	call antoi
	mov [max_number], ax
; check argv[3]:
	cmp byte [buffer], 0x0
	je check_max_number_limit

wrong_argv_3:
	mov rdi, param_max_err_msg_len
	mov rsi, param_max_err_msg
	jmp exit_fail_with_msg

check_max_number_limit:
	cmp word [max_number], 100
	jg wrong_argv_3

; parsing ok - return
	pop rbx
	ret

; --------

; --------
; void fizzbuzz():
; Prints out all integers from 1 to `max_number`,
; replacing them by "Fizz", "Buzz" or "FizzBuzz"
; if they're divisible by `divisor1`, `divisor2` or both.
; Returns:	(void)
; --------

fizzbuzz:
	push rbx
	xor bx, bx

fizzbuzz_loop:
	inc bx
	cmp bx, [max_number]
	jg fizzbuzz_return

	mov di, bx
	call check_number
	call print_linefeed

	jmp fizzbuzz_loop

fizzbuzz_return:
	pop rbx
	ret

; --------

; --------
; void check_number(uint16_t n):
; Checks whether n is divisible by divisor{1,2} and performs the appropriate actions.
; Expects:	di:	n	= current number to be checked.
; Returns:	(void)
; --------

check_number:
	push rbx
	mov bx, di
first_check:
	mov sil, [divisor1]
	call is_indivisible_by
	push rax
	cmp al, 0
	jne second_check
; print "Fizz":
	mov rsi, fizzbuzz_str
	mov rdi, 4
	call print_str
second_check:
	mov di, bx
	mov sil, [divisor2]
	call is_indivisible_by
	push rax
	cmp al, 0
	jne check_if_written
; print "Buzz":
	lea rsi, [fizzbuzz_str+4]
	mov rdi, 4
	call print_str
check_if_written:
	pop rax
	pop rdi
	cmp al, 0
	je noprint
	cmp dil, 0
	je noprint
; neither "Fizz" nor "Buzz" - print number:
	mov di, bx
	call print_number
noprint:
	pop rbx
	ret

; --------

; --------
; uint8_t is_indivisible_by(uint16_t n, uint8_t p):
; Checks whether `n` is divisible by `p`.
; Expects:	di:	n	= divident
;		sil:	p	= divisor
; Returns:	ax:	0	iff n is divisible by p without a remainder.
; --------

is_indivisible_by:

	mov ax, di
	movsx si, sil
	xor dx, dx
	div si
	mov ax, dx
	ret

; --------

; --------
; void print_str(uint64_t n, char* s):
; Prints str to stdout.
; Expects:	rdi:	n	= number of characters to print.
; 		rsi:	s	= address of string to print.
; Returns:	(void)
; --------

print_str:
	mov rdx, rdi
	mov rax, 1
	mov rdi, 1
	syscall
	ret

; --------

; --------
; void exit_fail_with_msg(uint64_t n, char* s):
; Prints str to stderr and exits with error code 1.
; Expects:	rdi:	n	= number of characters to print.
; 		rsi:	s	= address of string to print.
; Returns:	Does not return.
; --------

exit_fail_with_msg:
	mov rdx, rdi
	mov rax, 1
	mov rdi, 2
	syscall
	jmp exit_failure

; --------

; --------
; void print_linefeed():
; Prints a linefeed (`\n`) to stdout.
; Returns:	(void)
; --------

print_linefeed:
	mov rsi, linefeed
	mov rax, 1
	mov rdi, 1
	mov rdx, 1
	syscall
	ret

; --------

; --------
; void print_number(uint16_t number):
; Prints `number` in decimal notation to stdout.
; Expects:	di:	number
; Returns:	(void)
; --------

print_number:
	mov qword [buffer], 0x0
	mov ax, di
	mov rcx, buffer
	mov di, 10
	add rcx, 7
print_number_loop:
	xor dx, dx
	div di
	add dl, 0x30
	mov [rcx], dl
	dec rcx
	cmp ax, 0
	jne print_number_loop
;actually print:
	mov rsi, buffer
	mov rdi, 8
	call print_str
; return:
	ret

; --------

; --------
; uint64_t antoi(uint64_t n, char* s, char* endptr):
; Converts the string `s` to an integer, assuming decimal notation.
; Sets `*endptr` to the last character parsed.
; On a correctly formatted string, `*endptr` should be `\0` after return.
; Expects:	rdi:	n	= max number of chars to process
;		rsi:	s	= string to parse
;		rdx:	endptr	= address to store the last char in
; Returns:	rax:	The integer that was encoded in `s`.

antoi:
	xor rax, rax	; start with 0
	mov r8, rdx	; we don't know what the multiplying will do with rdx later...
	mov r9b, -1	; make sure we return an invalid char if stopping early
	mov r10, 10
antoi_loop:
	cmp rdi, 0	; check if we exceeded the iteration limit
	je antoi_return
; get current char:
	mov byte cl, [rsi]
	mov r9b, cl	; save potential last char in r9b
	sub cl, 0x30	; convert to ascii
; check if digit:
	cmp cl, 0
	jl antoi_return
	cmp cl, 10
	jge antoi_return
; add to number:
	mul r10
	movsx rcx, cl	; sign-extend the digit in cl
	add rax, rcx
; end_of_loop:
	dec rdi
	add rsi, 1
	jmp antoi_loop

antoi_return:
	cmp r8, 0		; check if endptr addr. was NULL
	je antoi_return_nowrite
	mov byte [r8], r9b	; write last char to endchar addr.
antoi_return_nowrite:
	ret

; --------

; --------
; --------
; void exit_success(),
; void exit_failure(),
; void exit_code_in_rdi(uint64_t exit_code):
; Exit the program with given exit code.
; Expects:	rdi:	exit_code	(only for `exit_code_in_rdi`)
; Returns:	These functions do not return.
; --------

; --------

exit_failure:
	mov rdi, 1
	jmp exit_code_in_rdi
exit_success:
	mov rdi, 0
exit_code_in_rdi:
	mov rax, 60
	syscall

; --------


