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
    ;矩阵定义为一个数组，其中 0号元素和 1号元素为行数和列数，2号及以后为行优先顺序存储的矩阵元素
.code

;获取矩阵a b1行 b2列的值
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

;设置矩阵a b1行 b2列的值为 b3
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

;获取矩阵行数
GetRowNum PROC a1:DWORD
    mov eax,a1
    mov eax,[eax]
    ret
GetRowNum ENDP

;获取矩阵列数
GetClnNum PROC a1:DWORD
    mov eax,a1
    mov eax,[eax+4]
    ret
GetClnNum ENDP

;设置矩阵行数
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

;设置矩阵列数
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


;矩阵行和列相乘 a1 b1行 乘以 a2 b2列
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


; 矩阵相乘函数 a3 = a1*a2
MatMulti PROC a1:DWORD, a2:DWORD, a3:DWORD
    push eax;保存现场
    push ebx
    push ecx
    push edx
    push esi

    mov edx,OFFSET MatAStr;打印a1矩阵
    call WriteString
    push a1
    call MatPrint

    mov edx,OFFSET MatBStr;打印a2矩阵
    call WriteString
    push a2
    call MatPrint

    push a1;获取a1矩阵列数
    call GetClnNum
    mov ebx,eax

    push a2;获取a2矩阵行数
    call GetRowNum

    cmp ebx,eax;如果值相等可以进行矩阵相乘运算
    jz Continue

    Error:;不相等报错返回
    mov edx,OFFSET ErrorStr
    call WriteString
    jmp TheEnd


    Continue:

    push a1;a3的行数等于a1的行数
    call GetRowNum
    mov ebx,eax
    push eax
    push a3
    call SetRowNum

    push a2;a3的列数等于a2的列数
    call GetClnNum
    mov ecx,eax
    push eax
    push a3
    call SetClnNum

    mov edx,0;对行数进行循环
    L1:
    cmp edx,ebx
    jz L1End

    mov esi,0;对列数进行循环
    L2:
    cmp esi,ecx
    jz L2End

    push esi;计算a1 edx行和a2 esi列的内积
    push edx
    push a2
    push a1
    call MatLineMulti

    push eax;该内积为a3 edx行 esi列的值
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

    mov edx,OFFSET MatCStr;打印结果
    call WriteString
    push a3
    call MatPrint


    TheEnd:
    pop esi;恢复现场
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
MatMulti ENDP

;矩阵打印函数
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

;从文件a1读取到缓冲区b1,b2为缓冲区大小
FileRead Proc a:DWORD, b1:DWORD, b2:DWORD
    push eax;保护现场
    push ebx
    push ecx
    push edx
    push esi

    ;清空缓冲区b1
    mov eax,b1
    mov ebx,b2
    mov ecx,0

    L1:
    mov DWORD PTR [eax+ecx],0h

    add ecx,4
    cmp ecx,ebx
    jb L1


    mov eax,a

      ; 打开文件
    invoke CreateFile, eax, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    mov edx, eax   ; 将文件句柄存储在 edx 寄存器中

    ; 检查文件是否成功打开
    cmp edx, INVALID_HANDLE_VALUE
    je  error_exit

    push edx

    ; 读取文件内容
    invoke ReadFile, edx, b1, b2, ADDR bytesRead, 0

    ; 关闭文件
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

    error_exit:;错误处理
    mov edx,OFFSET ReadErrorStr
    call WriteString

    end_program:;恢复现场
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FileRead ENDP

;将缓冲区b1写入b2个字节到地址a
FileWrite Proc a:DWORD, b1:DWORD, b2:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov edx,a

    ; 打开或创建文件
    invoke CreateFile, edx, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov ebx, eax  ; 保存文件句柄到 hFile 中
    cmp eax, INVALID_HANDLE_VALUE
    je error_exit  ; 如果创建文件失败，跳转到 error_exit

    ; 写入数据
    mov edx, b1
    mov eax, b2
    invoke WriteFile, ebx, edx, eax,ADDR bytesWritten, 0
    
    ; 检查是否写入成功
    test eax, eax
    je error_exit  ; 如果写入失败，跳转到 error_exit

    ; 关闭文件
    invoke CloseHandle, ebx
    jmp end_program  ; 跳转到程序结束

    error_exit:

    end_program:

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FileWrite ENDP

;从指针esi处开始的缓冲区中读取一个数字到eax，
ReadValue Proc
    push ebx
    push ecx
    push edx

    mov eax,0

    mov ecx,-1
   
    L1:
    inc ecx
    mov bl,[esi+ecx]
    cmp bl,32;跳过空格
    jz L1
    cmp bl,13;跳过换行
    jz L1
    cmp bl,10;跳过回车
    jz L1

    L2:
    cmp bl,48;低于48或者高于57都不是数字，跳转到结束
    jb program_end
    cmp bl,57
    jg program_end

    sub bl,48;如果是数字asiic码减去48转换为数字

    and ebx,0FFh;将高位清零
    imul eax,10;加入到已有值中
    add eax,ebx

    inc ecx;读取下一个字符
    mov bl,[esi+ecx]
    jmp L2

    program_end:
    add esi,ecx;移动缓冲区指针

    pop edx
    pop ecx
    pop ebx
    ret
ReadValue ENDP

;从缓冲区 b 读取矩阵到 a
ReadMat Proc a:DWORD, b:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi,b
    mov ecx,0;表示当前将要填写的行
    mov edx,0;表示当前将要填写的列


    L1:
    call ReadValue;从缓冲区读取一个数字到 eax
    mov bl,[esi];获取下一个字符

    cmp bl,32;如果是空格
    jz next_space

    cmp bl,10;如果是换行或者回车
    jz next_newline
    cmp bl,13
    jz next_newline

    cmp bl,0;如果是缓冲区末尾
    jz program_end


    next_space:;不需要特殊处理，只需在当前行列处写入值，并指向下一列
    push eax;在当前行列处写入值
    push edx
    push ecx
    push a
    call MatSet
    inc edx;指向下一列
    jmp L1;处理下一个字符
    
    next_newline:;遇到回车代表当前行结束，当前列数为矩阵的列数，存入列数，并重新指向零列，并且行数加一
    push eax;在当前行列处写入值
    push edx
    push ecx
    push a
    call MatSet
    inc edx;指向下一列
    push edx;该列数为矩阵列数
    push a
    call SetClnNum;存入矩阵列数
    mov edx,0;重新指向 0列
    inc ecx;行数加一
    jmp L1;处理下一个字符

    program_end:;读取结束代表当前行数为矩阵行数
    push eax;在当前行列处写入值
    push edx
    push ecx
    push a
    call MatSet
    inc ecx;行数加一
    push ecx;将当前行数存入矩阵行数
    push a
    call SetRowNum

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ReadMat ENDP

;将 eax的值转换为 asiic码写入 esi指向的缓冲区
WriteValue Proc
    push eax
    push ebx
    push ecx
    push edx

    mov ebx,1;计算 eax的位数
    mov ecx,10

    L1:
    cmp eax,ecx;如果小于 10就只有一位，大于 10小于 100就是两位....
    jl continue

    inc ebx
    imul ecx,10
    jmp L1

    continue:

    push ebx;存入位数
    mov ecx,ebx;有多少位循环多少次
    mov ebx,10

    L2:
    xor edx,edx
    div ebx;
    add edx,48;除以 10的余数加上 48转为asiic码值
    mov BYTE PTR [esi+ecx-1],dl;在对应位置存入字符
    loop L2

    pop ebx
    add esi,ebx;将指针指向下一个未写入的位置
    mov BYTE PTR [esi],0

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
WriteValue ENDP

;将矩阵 b 写入到缓冲区 a, 并且在 eax返回总字节数
WriteMat Proc a:DWORD, b:DWORD
    push ebx
    push ecx
    push edx
    push esi

    mov esi,a
    mov ebx,0;当前元素序号
    mov edi,0;当前元素列号

    push b;获取列数
    call GetClnNum
    mov ecx,eax

    push b;获取行数
    call GetRowNum
    mov edx,eax

    imul edx,ecx;总元素个数

    L1:
    cmp ebx,edx;当当前元素序号大于等于总元素个数时，全部输出完毕
    jnl program_end

    push esi;取出当前元素值
    mov esi,b
    mov eax,[esi + ebx*4 +8]
    pop esi

    inc ebx;指向下一个元素
    inc edi;列号加一

    call WriteValue;将当前值写入缓冲区

    mov BYTE PTR [esi],32;写入空格隔开
    inc esi

    cmp edi,ecx;当前列号小于列数直接写入下一数
    jl L1

    ;当前列号大于等于时要换行
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

    ;矩阵数组，第0个和第1个元素分别表示行数和列数，后为行优先顺序存储

    buffer BYTE 128*128*64 DUP(?);缓冲区
    fileA BYTE 128*128 DUP(?)       ; 文件名
    fileB BYTE 128*128 DUP(?)       ; 文件名
    fileC BYTE 128*128 DUP(?)       ; 文件名

    helpString BYTE "For matrix calculation C=A×B, enter the file paths for A, B, and C, each followed by pressing the Enter key.",10,0

.code

main PROC                   ; 定义主函数开始位置
    
    mov edx,OFFSET helpString ;打印输入提示
    call WriteString

    mov edx,OFFSET fileA;输入矩阵 A地址
    mov ecx,SIZEOF fileA
    call ReadString

    mov edx,OFFSET fileB;输入矩阵 B地址
    mov ecx,SIZEOF fileB
    call ReadString

    mov edx,OFFSET fileC;输入输出结果矩阵 C地址
    mov ecx,SIZEOF fileC
    call ReadString

    push SIZEOF buffer;将矩阵 A以字符串读入buffer
    push OFFSET buffer
    push OFFSET fileA
    call FileRead

    push OFFSET buffer;将 buffer中字符串形式的矩阵A转为数字存储到数组 MatA
    push OFFSET MatA
    call ReadMat

    push SIZEOF buffer;将矩阵 B以字符串读入buffer
    push OFFSET buffer
    push OFFSET fileB
    call FileRead

    push OFFSET buffer;将 buffer中字符串形式的矩阵B转为数字存储到数组 MatB
    push OFFSET MatB
    call ReadMat

    push OFFSET MatC;计算矩阵 C = A * B
    push OFFSET MatB
    push OFFSET MatA
    call MatMulti

    push OFFSET MatC;将结果 C转化为字符串形式存储到 buffer
    push OFFSET buffer
    call WriteMat

    push eax;将 buffer中的结果输出到矩阵 C的文件地址
    push OFFSET buffer
    push OFFSET fileC
    call FileWrite
 
    call WaitMsg            ; 显示请按任意键继续信息
 
    exit
main ENDP           ; 函数结束位置, ENDP 之前的内容，要与PROC 
END main            ; 设置了函数的入口与出口