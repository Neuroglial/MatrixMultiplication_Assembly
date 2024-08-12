Include Irvine32.inc
includelib kernel32.lib
includelib user32.lib
 

.data
    ErrorStr BYTE "Error!!",10,
    "The number of columns in matrix A is not equal to the number of rows in matrix B,",10,
    "so the calculation cannot be performed.",10, 0
    MatAStr BYTE 10,"Matrix A: ",10, 0
    MatBStr BYTE 10,"Matrix B: ",10, 0
    MatCStr BYTE 10,"Result Matrix: ",10, 0
    ;������Ϊһ�����飬���� 0��Ԫ�غ� 1��Ԫ��Ϊ������������2�ż��Ժ�Ϊ������˳��洢�ľ���Ԫ��
.code

;��ȡ����a b1�� b2�е�ֵ
MatGet PROC a1:DWORD, b1:DWORD, b2:DWORD
    push ebx
    push ecx
    push edx

    mov ebx,a1
    mov ecx,b1
    imul ecx,[ebx+4]
    imul ecx,4
    mov edx,b2
    imul edx,4
    add ecx,edx
    add ecx,ebx
    mov eax,[ecx+8]

    pop edx
    pop ecx
    pop ebx
    ret
MatGet ENDP

;���þ���a b1�� b2�е�ֵΪ b3
MatSet PROC a1:DWORD, b1:DWORD, b2:DWORD, b3:DWORD
    push ebx
    push ecx
    push edx

    mov ebx,a1
    mov ecx,b1
    imul ecx,[ebx+4]
    imul ecx,4
    mov edx,b2
    imul edx,4
    add ecx,edx
    add ecx,ebx
    mov ebx,b3
    mov DWORD PTR [ecx+8],ebx

    pop edx
    pop ecx
    pop ebx
    ret
MatSet ENDP

;��ȡ��������
GetRowNum PROC a1:DWORD
    mov eax,a1
    mov eax,[eax]
    ret
GetRowNum ENDP

;��ȡ��������
GetClnNum PROC a1:DWORD
    mov eax,a1
    mov eax,[eax+4]
    ret
GetClnNum ENDP

;���þ�������
SetRowNum PROC a1:DWORD, b:DWORD
    push eax
    push ebx

    mov eax,a1
    mov ebx,b
    mov DWORD PTR [eax],ebx

    pop ebx
    pop eax
    ret
SetRowNum ENDP

;���þ�������
SetClnNum PROC a1:DWORD, b:DWORD
    push eax
    push ebx

    mov eax,a1
    mov ebx,b
    mov DWORD PTR [eax+4],ebx

    pop ebx
    pop eax
    ret
SetClnNum ENDP


;�����к������ a1 b1�� ���� a2 b2��
MatLineMulti PROC a1:DWORD, a2:DWORD, b1:DWORD, b2:DWORD
    push ebx
    push ecx
    push edx
    push esi

    mov esi,0h
    push a1
    call GetClnNum
    mov ebx,eax
    mov ecx,0

    L1:
    cmp ecx,ebx
    jz L1End

    push ecx
    push b1
    push a1
    call MatGet
    mov edx,eax

    push b2
    push ecx
    push a2
    call MatGet

    imul eax,edx
    add esi,eax

    inc ecx
    jmp L1
    L1End:

    mov eax,esi

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
MatLineMulti ENDP


; ������˺��� a3 = a1*a2
MatMulti PROC a1:DWORD, a2:DWORD, a3:DWORD
    push eax;�����ֳ�
    push ebx
    push ecx
    push edx
    push esi

    mov edx,OFFSET MatAStr;��ӡa1����
    call WriteString
    push a1
    call MatPrint

    mov edx,OFFSET MatBStr;��ӡa2����
    call WriteString
    push a2
    call MatPrint

    push a1;��ȡa1��������
    call GetClnNum
    mov ebx,eax

    push a2;��ȡa2��������
    call GetRowNum

    cmp ebx,eax;���ֵ��ȿ��Խ��о����������
    jz Continue

    Error:;����ȱ�����
    mov edx,OFFSET ErrorStr
    call WriteString
    jmp TheEnd


    Continue:

    push a1;a3����������a1������
    call GetRowNum
    mov ebx,eax
    push eax
    push a3
    call SetRowNum

    push a2;a3����������a2������
    call GetClnNum
    mov ecx,eax
    push eax
    push a3
    call SetClnNum

    mov edx,0;����������ѭ��
    L1:
    cmp edx,ebx
    jz L1End

    mov esi,0;����������ѭ��
    L2:
    cmp esi,ecx
    jz L2End

    push esi;����a1 edx�к�a2 esi�е��ڻ�
    push edx
    push a2
    push a1
    call MatLineMulti

    push eax;���ڻ�Ϊa3 edx�� esi�е�ֵ
    push esi
    push edx
    push a3
    call MatSet

    inc esi
    jmp L2
    L2End:

    inc edx
    jmp L1
    L1End:

    mov edx,OFFSET MatCStr;��ӡ���
    call WriteString
    push a3
    call MatPrint


    TheEnd:
    pop esi;�ָ��ֳ�
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
MatMulti ENDP

;�����ӡ����
MatPrint Proc a:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi

    push a
    call GetRowNum
    mov edx,eax
    push a
    call GetClnNum
    mov esi,eax

    mov ebx,0
    Loop1:
    cmp ebx,edx
    je Loop1End

    mov ecx,0
    Loop2:
    cmp ecx,esi
    je Loop2End

    push ecx
    push ebx
    push a

    call MatGet
    
    call WriteDec
    mov al,32
    call WriteChar
    call WriteChar
    call WriteChar

    inc ecx
    jmp Loop2
    Loop2End:

    call Crlf
    inc ebx
    jmp Loop1
    Loop1End:

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
MatPrint ENDP

.data

bytesWritten DWORD ?
bytesRead DWORD ?
ReadErrorStr BYTE "Error!!",10,"File Read Error",10,0
ReadSuccessStr BYTE " Read Successful:",10, 0

.code

;���ļ�a1��ȡ��������b1,b2Ϊ��������С
FileRead Proc a:DWORD, b1:DWORD, b2:DWORD
    push eax;�����ֳ�
    push ebx
    push ecx
    push edx
    push esi

    ;��ջ�����b1
    mov eax,b1
    mov ebx,b2
    mov ecx,0

    L1:
    mov DWORD PTR [eax+ecx],0h

    add ecx,4
    cmp ecx,ebx
    jb L1


    mov eax,a

      ; ���ļ�
    invoke CreateFile, eax, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov edx, eax   ; ���ļ�����洢�� edx �Ĵ�����

    ; ����ļ��Ƿ�ɹ���
    cmp edx, INVALID_HANDLE_VALUE
    je  error_exit

    push edx

    ; ��ȡ�ļ�����
    invoke ReadFile, edx, b1, b2, ADDR bytesRead, 0

    ; �ر��ļ�
    pop edx
    invoke CloseHandle, edx

    mov edx,a
    call Crlf
    call WriteString
    mov edx,OFFSET ReadSuccessStr
    call WriteString
    mov edx,b1
    call WriteString
    call Crlf

    jmp end_program

    error_exit:;������
    mov edx,OFFSET ReadErrorStr
    call WriteString

    end_program:;�ָ��ֳ�
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FileRead ENDP

;��������b1д��b2���ֽڵ���ַa
FileWrite Proc a:DWORD, b1:DWORD, b2:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov edx,a

    ; �򿪻򴴽��ļ�
    invoke CreateFile, edx, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov ebx, eax  ; �����ļ������ hFile ��
    cmp eax, INVALID_HANDLE_VALUE
    je error_exit  ; ��������ļ�ʧ�ܣ���ת�� error_exit

    ; д������
    mov edx, b1
    mov eax, b2
    invoke WriteFile, ebx, edx, eax,ADDR bytesWritten, 0
    
    ; ����Ƿ�д��ɹ�
    test eax, eax
    je error_exit  ; ���д��ʧ�ܣ���ת�� error_exit

    ; �ر��ļ�
    invoke CloseHandle, ebx
    jmp end_program  ; ��ת���������

    error_exit:

    end_program:

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FileWrite ENDP

;��ָ��esi����ʼ�Ļ������ж�ȡһ�����ֵ�eax��
ReadValue Proc
    push ebx
    push ecx
    push edx

    mov eax,0

    mov ecx,-1
   
    L1:
    inc ecx
    mov bl,[esi+ecx]
    cmp bl,32;�����ո�
    jz L1
    cmp bl,13;��������
    jz L1
    cmp bl,10;�����س�
    jz L1

    L2:
    cmp bl,48;����48���߸���57���������֣���ת������
    jb program_end
    cmp bl,57
    jg program_end

    sub bl,48;���������asiic���ȥ48ת��Ϊ����

    and ebx,0FFh;����λ����
    imul eax,10;���뵽����ֵ��
    add eax,ebx

    inc ecx;��ȡ��һ���ַ�
    mov bl,[esi+ecx]
    jmp L2

    program_end:
    add esi,ecx;�ƶ�������ָ��

    pop edx
    pop ecx
    pop ebx
    ret
ReadValue ENDP

;�ӻ����� b ��ȡ���� a
ReadMat Proc a:DWORD, b:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi,b
    mov ecx,0;��ʾ��ǰ��Ҫ��д����
    mov edx,0;��ʾ��ǰ��Ҫ��д����


    L1:
    call ReadValue;�ӻ�������ȡһ�����ֵ� eax
    mov bl,[esi];��ȡ��һ���ַ�

    cmp bl,32;����ǿո�
    jz next_space

    cmp bl,10;����ǻ��л��߻س�
    jz next_newline
    cmp bl,13
    jz next_newline

    cmp bl,0;����ǻ�����ĩβ
    jz program_end


    next_space:;����Ҫ���⴦��ֻ���ڵ�ǰ���д�д��ֵ����ָ����һ��
    push eax;�ڵ�ǰ���д�д��ֵ
    push edx
    push ecx
    push a
    call MatSet
    inc edx;ָ����һ��
    jmp L1;������һ���ַ�
    
    next_newline:;�����س�����ǰ�н�������ǰ����Ϊ���������������������������ָ�����У�����������һ
    push eax;�ڵ�ǰ���д�д��ֵ
    push edx
    push ecx
    push a
    call MatSet
    inc edx;ָ����һ��
    push edx;������Ϊ��������
    push a
    call SetClnNum;�����������
    mov edx,0;����ָ�� 0��
    inc ecx;������һ
    jmp L1;������һ���ַ�

    program_end:;��ȡ��������ǰ����Ϊ��������
    push eax;�ڵ�ǰ���д�д��ֵ
    push edx
    push ecx
    push a
    call MatSet
    inc ecx;������һ
    push ecx;����ǰ���������������
    push a
    call SetRowNum

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ReadMat ENDP

;�� eax��ֵת��Ϊ asiic��д�� esiָ��Ļ�����
WriteValue Proc
    push eax
    push ebx
    push ecx
    push edx

    mov ebx,1;���� eax��λ��
    mov ecx,10

    L1:
    cmp eax,ecx;���С�� 10��ֻ��һλ������ 10С�� 100������λ....
    jl continue

    inc ebx
    imul ecx,10
    jmp L1

    continue:

    push ebx;����λ��
    mov ecx,ebx;�ж���λѭ�����ٴ�
    mov ebx,10

    L2:
    xor edx,edx
    div ebx;
    add edx,48;���� 10���������� 48תΪasiic��ֵ
    mov BYTE PTR [esi+ecx-1],dl;�ڶ�Ӧλ�ô����ַ�
    loop L2

    pop ebx
    add esi,ebx;��ָ��ָ����һ��δд���λ��
    mov BYTE PTR [esi],0

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
WriteValue ENDP

;������ b д�뵽������ a, ������ eax�������ֽ���
WriteMat Proc a:DWORD, b:DWORD
    push ebx
    push ecx
    push edx
    push esi

    mov esi,a
    mov ebx,0;��ǰԪ�����
    mov edi,0;��ǰԪ���к�

    push b;��ȡ����
    call GetClnNum
    mov ecx,eax

    push b;��ȡ����
    call GetRowNum
    mov edx,eax

    imul edx,ecx;��Ԫ�ظ���

    L1:
    cmp ebx,edx;����ǰԪ����Ŵ��ڵ�����Ԫ�ظ���ʱ��ȫ��������
    jnl program_end

    push esi;ȡ����ǰԪ��ֵ
    mov esi,b
    mov eax,[esi + ebx*4 +8]
    pop esi

    inc ebx;ָ����һ��Ԫ��
    inc edi;�кż�һ

    call WriteValue;����ǰֵд�뻺����

    mov BYTE PTR [esi],32;д��ո����
    inc esi

    cmp edi,ecx;��ǰ�к�С������ֱ��д����һ��
    jl L1

    ;��ǰ�кŴ��ڵ���ʱҪ����
    mov BYTE PTR [esi-1],10
    mov edi,0

    jmp L1

    program_end:
    mov eax,esi
    sub eax,a
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
WriteMat ENDP




.data

    MatA DWORD 128*128 DUP(?)

    MatB DWORD 128*128 DUP(?)

    MatC DWORD 128*128 dup(?)

    ;�������飬��0���͵�1��Ԫ�طֱ��ʾ��������������Ϊ������˳��洢

    buffer BYTE 128*128*64 DUP(?);������
    fileA BYTE 128*128 DUP(?)       ; �ļ���
    fileB BYTE 128*128 DUP(?)       ; �ļ���
    fileC BYTE 128*128 DUP(?)       ; �ļ���

    helpString BYTE "For matrix calculation C=A��B, enter the file paths for A, B, and C, each followed by pressing the Enter key.",10,0

.code

main PROC                   ; ������������ʼλ��
    
    mov edx,OFFSET helpString ;��ӡ������ʾ
    call WriteString

    mov edx,OFFSET fileA;������� A��ַ
    mov ecx,SIZEOF fileA
    call ReadString

    mov edx,OFFSET fileB;������� B��ַ
    mov ecx,SIZEOF fileB
    call ReadString

    mov edx,OFFSET fileC;�������������� C��ַ
    mov ecx,SIZEOF fileC
    call ReadString

    push SIZEOF buffer;������ A���ַ�������buffer
    push OFFSET buffer
    push OFFSET fileA
    call FileRead

    push OFFSET buffer;�� buffer���ַ�����ʽ�ľ���AתΪ���ִ洢������ MatA
    push OFFSET MatA
    call ReadMat

    push SIZEOF buffer;������ B���ַ�������buffer
    push OFFSET buffer
    push OFFSET fileB
    call FileRead

    push OFFSET buffer;�� buffer���ַ�����ʽ�ľ���BתΪ���ִ洢������ MatB
    push OFFSET MatB
    call ReadMat

    push OFFSET MatC;������� C = A * B
    push OFFSET MatB
    push OFFSET MatA
    call MatMulti

    push OFFSET MatC;����� Cת��Ϊ�ַ�����ʽ�洢�� buffer
    push OFFSET buffer
    call WriteMat

    push eax;�� buffer�еĽ����������� C���ļ���ַ
    push OFFSET buffer
    push OFFSET fileC
    call FileWrite
 
    call WaitMsg            ; ��ʾ�밴�����������Ϣ
 
    exit
main ENDP           ; ��������λ��, ENDP ֮ǰ�����ݣ�Ҫ��PROC 
END main            ; �����˺�������������