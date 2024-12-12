model   small
.stack   256
.data
message1 db 'Message: $'
message2 db 'Press 1 to encrypt $'
message3 db 'Press 2 to decrypt $'
message4 db 'Press 3 to save current message to file $'
message5 db 'Press 4 to exit $'
message6 db 'Max encryption $'
message7 db 'Min decryption $'

filename1 db 'input.txt',0 ; Stores the name of the input file with a null terminator.
handler1 dw ? ; Placeholder for the file handle of the input file.
point_fname1 dd filename1 ; Pointer to filename1.
fileSize1 dw ? ; Placeholder for the file size of the input file.

filename2 db 'output.txt',0 ; Stores the name of the Output file with a null terminator.
handler2 dw ? ; Placeholder for the file handle of the Output file.
point_fname2 dd filename2 ; Pointer to filename2.
fileSize2 dw ? ; Placeholder for the file size of the Output file.

len dw 200 ; Sets the maximum length for the buffer.
level db 30h ; Indicates the current encryption level (0-3).

; Defines constants used in encryption and decryption.
pass equ 170 
pass2 equ 3

; A 200-byte buffer initialized with zeros for storing file content.
buffer db 200 dup (0)

.code
main:

; Initializes the data segment by loading the segment address of @data into DS.
.startup   ;mov ax, @data
           ;mov ds, ax

; Opening the Input File  
    xor ax, ax ; Clears the AX register before setting it up for the DOS interrupt 21h. This ensures no unintended data remains in the register.
    mov al, 02h ; Specifies the file open mode: Read-only mode
    mov ah, 3dh ; Specifies the DOS interrupt function 3Dh (Open File).
    
    ; LDS (Load Pointer Using DS) transfers a pointer variable from the source operand [Memory] to DS and the destination register [General Register]
    lds dx, point_fname1 ; Points DX to the memory location of the string filename1 (the file name input.txt), which is required as input for the DOS interrupt 21h, function 3Dh.
    
    ; Opens the file specified by the pointer in DX (filename1). 
    ;If successful:
    ;The file handle is returned in AX.
    ;If unsuccessful, an error code is returned in AX. 
    int 21h
    mov handler1, ax ; Stores the file handle (or Error Code) for later operations (e.g., reading the file or closing it).
    
    ;========================================================================================================================================================================================
    
    ; Reading File Contents
    mov ah, 3fh ; Specifies the DOS interrupt function 3Fh, which is used to read from a file.
    mov bx, handler1 ; The BX register is used by DOS interrupt 21h, function 3Fh to identify the file to read from. This file handle was previously obtained when the file was opened.
    mov cx, len ; Specifies the number of bytes to read from the file. In this program, len is set to 200, meaning up to 200 bytes will be read.
    lea dx, buffer ; Points to the memory location where the read data will be stored. The buffer is a 200-byte array in this program.
    
    ; Reads data from the file identified by BX (the file handle) into the memory location pointed to by DX (the buffer). The number of bytes to read is specified in CX (len).
    ; If successful:
        ; The number of bytes actually read is returned in the AX register.
        ; The data is stored in the buffer.
     ;If unsuccessful:
        ;An error code is returned in AX.
    int 21h 
    ;========================================================================================================================================================================================
    
    ; Calculating the Effective Length
    ; Iterates through buffer to determine the effective length of the message:
        ;If a character is outside the range of printable ASCII (20h to 7Fh), it decrements len.
        
    mov cx, len ; Initializes CX to the total number of bytes to process in the buffer. This serves as a loop counter
    mov si, 0 ; SI is used as an index to traverse the buffer. Initializing it to 0 ensures the traversal starts from the beginning of the buffer.
    
    computeLen: ; This label is used as the entry point for checking each byte in the buffer.
    cmp buffer[si], 20h ; Checks if the current byte is less than the ASCII value 20h (non-printable characters like control characters).
    jl correctLen ; Handles bytes that are non-printable (outside the ASCII range of 20h to 7Fh).
    cmp buffer[si], 7fh ; Checks if the current byte is greater than 7Fh (non-printable characters beyond the standard ASCII range).
    jg correctLen ; Handles bytes that are non-printable (outside the ASCII range of 20h to 7Fh).
    inc si ; Moves the index to the next byte in the buffer.
    loop computeLen ; Continues iterating through the buffer until all bytes have been checked or CX reaches 0.
    jmp output ; Once the loop completes, control transfers to the output label to handle the next step.
    
    ;========================================================================================================================================================================================
    
    
    correctLen: ; This label is used as a target for jumps (jl or jg) when the current byte in the buffer is determined to be outside the printable ASCII range.
    
    ; Adjusts the effective length of the valid message stored in the buffer.
    ; The loop in the computeLen section uses CX as a counter for remaining iterations.
    ; If the loop exits early (due to encountering a non-printable character), CX still holds the count of unprocessed bytes.
    ; Subtracting CX from len reduces the effective length (len) to reflect only the valid printable characters up to the point where the loop terminated.
    sub len, cx 
    
    ;========================================================================================================================================================================================
    
    ; Output the Message
output:
    xor dx, dx ; Ensures that DX is clean before being used to store the address of a string. This is a common practice to prevent unintended values from affecting operations
    ; Prints Message: 'Message:'
    mov dx, offset message1 ;'Message: $'
    mov ah, 09h
    int 21h
    
    
    xor cx, cx ; Resets the CX register to prepare it for a new value.
    xor si, si ; Resets the SI register, which will be used as an index for traversing the buffer
    mov cx, len ; Sets the number of characters to process in subsequent loops (e.g., for printing the contents of the buffer).
    mov si, 0 ; Ensures that traversal of the buffer starts at the beginning (index 0).
    
    ;========================================================================================================================================================================================
    printMessage: ; Indicates the start of a loop that prints each character from the buffer.
    mov dl, buffer[si] ; Prepares the current character from the buffer for output. The DL register is used by the DOS interrupt function 02h to print a single character.
    mov ah, 02h ; Specifies the DOS interrupt function 02h, which is used to display a single character on the screen.
    int 21h ; Outputs the character currently stored in the DL register to the screen.
    inc si ; Moves the index to the next character in the buffer
    loop printMessage
    ;========================================================================================================================================================================================
     
input:
    ; Print a new line
    mov dl, 10 ; Loads the ASCII code for a newline (0Ah) into the DL register.
    mov ah, 02h ; Loads 02h into AH, specifying the DOS function to display a single character.
    int 21h ; Executes the DOS interrupt to display the newline character.
    
    ; Print message 'Press 1 to encrypt' 
    xor dx, dx ; Clears the DX register to remove any previous value.
    mov dx, offset message2 ;'Press 1 to encrypt $'
    mov ah, 09h
    int 21h
    
    ; Prints a newline to visually separate the displayed messages.
    mov dl, 10
    mov ah, 02h
    int 21h
    
    ; Print Message 'Press 2 to decrypt'
    xor dx, dx ; Clears the DX register to remove any previous value.
    mov dx, offset message3 ;'Press 2 to decrypt $'
    mov ah, 09h
    int 21h

    ; Prints a newline to visually separate the displayed messages.
    mov dl, 10
    mov ah, 02h
    int 21h
    
    ; Print Message 'Press 3 to save current message to file'
    xor dx, dx ; Clears the DX register to remove any previous value.
    mov dx, offset message4 ;'Press 3 to save current message to file $'
    mov ah, 09h
    int 21h
    
    ; Prints a newline to visually separate the displayed messages.
    mov dl, 10
    mov ah, 02h
    int 21h
    
    ; Print Message 'Press 4 to exit'
    xor dx, dx ; Clears the DX register to remove any previous value.
    mov dx, offset message5 ;'Press 4 to exit $'
    mov ah, 09h
    int 21h
    
    ; Prints a newline to visually separate the displayed messages.
    mov dl, 10
    mov ah, 02h
    int 21h
    
    ; Wait for user input
    mov ah, 1h ; Loads 1h into AH, specifying the DOS function to read a single character from the keyboard.
    int 21h ; Executes the DOS interrupt to wait for user input.
    
    
    cmp al, 31h ; Compares the input (AL contains the ASCII code of the input) with 31h (ASCII for '1').
    je toCrypt ; If equal, jumps to the toCrypt label for encryption.
    cmp al, 32h ; Compares the input with 32h (ASCII for '2').
    je toDecryptJumptExtend ; If equal, jumps to the decryption process.
    cmp al, 33h ; Compares the input with 33h (ASCII for '3').
    je saveJumptExtend ; If equal, jumps to save the message to a file.
    cmp al, 34h ; Compares the input with 34h (ASCII for '4').
    je exitJumptExtend ; If equal, jumps to the exit routine.
    
outputJumptExtend:
    jmp output ; When this line is executed, the program will jump back to the output label, where the message will be printed again. 
    
   ;========================================================================================================================================================================================
   ; This section is activated when the user selects the option to encrypt the message
toCrypt:
    mov cx, len ; Loads the value of len (the length of the message) into the CX register For Looping.
    mov si, 0 ; ensures the encryption starts from the first character of the message.
    
    cmp level, 30h ; Compares the value of the level variable with 30h (hexadecimal 30, or 48 in decimal).
    je crypt1 ;  This jump directs the program to perform the first encryption method (under the crypt1 label).
    cmp level, 31h ; Compares the level variable with 31h (hexadecimal 31, or 49 in decimal).
    je crypt2 ; This jump directs the program to perform the second encryption method (under the crypt2 label). 
    cmp level, 32h ; Compares the level variable with 32h (hexadecimal 32, or 50 in decimal).
    je crypt3 ; This jump directs the program to perform the Third encryption method (under the crypt3 label). 
    cmp level, 33h ; Compares the level variable with 33h (hexadecimal 33, or 51 in decimal).
    je maxcrypt ; This jump leads to the maxcrypt label, which will perform the maximum encryption method. This is typically the strongest encryption technique in the program.
    ;========================================================================================================================================================================================
    ;  XOR encryption is a simple technique used here to encrypt the message.
    ; XORing a byte with a constant value modifies the original data, and applying the same operation again with the same constant will reverse it.
    ; The pass value is effectively a key used in this encryption process.
crypt1:
    xor buffer[si], pass ; XOR between current byte of message and pass = 170 in decimal or 0xAA in hexadecimal
    inc si ; Move to next byte
    loop crypt1 ; Loop Until CX is Zero
    inc level ; This allows the program to move to the next encryption technique if the user encrypts again.
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
    ;========================================================================================================================================================================================
    
    ; It adds the value of the current byte (buffer[si]) to the next byte (buffer[si+1]), essentially altering it based on the previous byte.
    ; This makes the encryption dependent on the relationship between two consecutive characters in the message.
crypt2:
    mov ah, buffer[si] ; emporarily stores the byte at the current index (si) of the message in the buffer into the AH register.
    add buffer[si+1], ah ; adds the value stored in AH (the value from buffer[si]) to buffer[si+1] (the next byte in the buffer).
    inc si ; Move to next byte
    loop crypt2 ; Loop Until CX is Zero
    mov ax, len ; this is used in the next step to modify the first byte of the message based on the length.
    add buffer[0], al ; adds the value in the AL register (contains the message length) to the first byte of the message (buffer[0]).
    inc level ; This allows the program to move to the next encryption technique if the user encrypts again. 
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
    ;========================================================================================================================================================================================
    ; This operation shifts the bits of the current byte (buffer[si]) to the right by 3 positions (because pass2 is 3).
    ; The result is a form of encryption that alters the byte by rotating its bits.
    ; This encryption method is different from the other methods (like XOR or addition) and changes the byte's value based on the rotation of its bits.
crypt3:
    ror buffer[si], pass2 ; This instruction performs a right rotate on the byte stored at buffer[si] by a number of positions specified by pass2 = 3.
    inc si ; Move to next byte
    loop crypt3 ; Loop until CX is Zero
    inc level ; This allows the program to move to the next encryption technique if the user encrypts again.
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
    ;========================================================================================================================================================================================
    ; 
maxcrypt:
    xor dx, dx ; Clear DX register
    
    ; Print messgae:'Max encryption'
    mov dx, offset message6 ;'Max encryption$'
    mov ah, 09h
    int 21h
    ; Print new line
    mov dl, 10
    mov ah, 02h
    int 21h
    
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
    ;========================================================================================================================================================================================
toDecryptJumptExtend:
    jmp toDecrypt
exitJumptExtend:
    jmp exit
saveJumptExtend:
    jmp save
inputJumptExtend:
    jmp input
 ;========================================================================================================================================================================================   
toDecrypt:
    mov cx, len ; Load CX with the length of the message
    mov si, 0 ; start the decryption process from the beginning of the message
    
    cmp level, 30h ; Compares the value of the level variable with 30h (hexadecimal 30, or 48 in decimal).
    je minDecrypt ; This jump directs the program to the lowest decryption level.
    cmp level, 31h ; Compares the level variable with 31h (hexadecimal 31, or 49 in decimal).
    je decrypt1 ; This jump directs the program to perform the first decryption method (under the decrypt1 label).
    cmp level, 32h ; Compares the level variable with 32h (hexadecimal 32, or 50 in decimal).
    je decrypt2 ; This jump directs the program to perform the Second decryption method (under the decrypt2 label).
    cmp level, 33h ; Compares the level variable with 33h (hexadecimal 33, or 51 in decimal).
    je decrypt3 ; This jump directs the program to perform the Third decryption method (under the decrypt3 label).
 ;========================================================================================================================================================================================   
decrypt1:
    xor buffer[si], pass ; decrypt the message by reversing the effect of the original encryption (which was an XOR with the pass value).
    inc si ; Move to next byte
    loop decrypt1 ; Loop until CX is zero
    dec level ; move the program to a lower decryption level after completing the current decryption stage (31h).
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
;========================================================================================================================================================================================
decrypt2:
    mov si, len ; The SI register is initialized to the length of the message, so it can be used to work backward through the buffer.
    mov ax, len ; The value of len is loaded into AX so that it can be used in the next instruction.
    sub buffer[0], al ; This step modifies the first byte of the buffer by subtracting the length of the message.
    decr2Cycle: ;  This part of the code will be executed repeatedly to apply a subtraction-based decryption to each byte in the message.
    mov ah, buffer[si-1] ; The value of the previous byte in the buffer is stored in the AH register so that it can be used in the next instruction.
    sub buffer[si], ah ; This operation decrypts the current byte by subtracting the value of the previous byte, effectively reversing the encryption applied by a similar method during encryption.
    dec si ; Move to previous byte
    loop decr2Cycle ; Loop until CX is zero
    dec level ; move the program to a lower decryption level after completing the current decryption stage (31h).
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
 ;========================================================================================================================================================================================   
decrypt3:
 ; Since the encryption stage used a right rotation (ror) to modify the bits of each byte, this operation undoes that transformation by rotating the bits in the opposite direction (left).
    rol buffer[si], pass2 ; This instruction performs a left rotate on the byte stored at buffer[si] by a number of positions specified by pass2 = 3.
    inc si ; Move to next byte
    loop decrypt3 ; Loop until CX is zero
    dec level ; move the program to a lower decryption level after completing the current decryption stage (31h).
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
 ;========================================================================================================================================================================================   
minDecrypt:
    xor dx, dx ; Clear DX register
    ; Print message: 'Min decryption'
    mov dx, offset message7 ;'Min decryption$'
    mov ah, 09h
    int 21h
    ; Print newline
    mov dl, 10
    mov ah, 02h
    int 21h
    jmp outputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
 ;========================================================================================================================================================================================   
save: 
    ;create and open output file
    mov ah, 3ch ; AH = 3Ch is the DOS interrupt function to create a new file. If the file exists, it will overwrite it.
    lds dx, point_fname2 ; This loads the address of filename2 (output.txt) into the DX register. (point_fname2 points to the string output.txt)
    mov cx, 1 ; CX = 1 indicates that the file should be created with standard permissions (read/write access).
    int 21h ; Creates the file output.txt and prepares it for writing. (On Success, File Handler is returned in AX)
    mov handler2, ax ; Saves the file handle for later writing.
    ;write in file
    mov ah, 40h ; AH = 40h is the DOS interrupt function for writing data to a file.
    mov cx, len ; Specifies the number of bytes to write, which is the length of the message stored in len.
    mov bx, handler2 ; Specifies the file handle (the one obtained earlier) where the data will be written.
    lea dx, buffer ; Loads the effective address of the buffer (where the message is stored) into the DX register. (Specifies the location of the data to be written to the file.)
    int 21h ; the message in buffer is written to the file associated with handler2.
    ;close output file
    mov ah, 3eh ; AH = 3Eh is the DOS interrupt function to close a file.
    lds bx, point_fname2 ; Loads the file handle of the output file into BX.
    int 21h ; Executes the close file service, ensuring the file is properly closed and its content is saved to disk.
    mov handler2, ax ; esets the handler2 variable, indicating that the file is no longer open.
    jmp inputJumptExtend ; this jump leads to the output section, where the program will re-display the message (now encrypted).
 ;========================================================================================================================================================================================   
exit:
    ;Close input file
    mov ah, 3eh ; AH = 3Eh is the DOS interrupt function used to close a file that has been opened or created. (Ensures that the input file (input.txt) is properly closed before the program exits)
    lds bx, point_fname1 ; Loads the file handle associated with point_fname1 (input.txt) into the BX register. (Specifies the file handle of the file to be closed)
    int 21h ; Releases system resources and ensures all pending changes to the file are committed.
    mov handler1, ax ; After the file is closed, this can act as a signal that the file handle is no longer valid.
    
    .exit    ;mov ax, 4c00h 
             ;int 21h
end main
