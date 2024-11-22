#Leena Abd Arahman 1211051
#Aseel Saleh 1213378
.data
fileName: .asciiz "C:\\Users\\leena\\Desktop\\ARC\\input.txt" # مسار الملف
fileWords: .space 1024       # لتخزين البيانات المقروءة من الملف
lineBuffer: .space 128     # لتخزين معادلة واحدة
errorMsg: .asciiz "Error reading the file.\n" # رسالة خطأ
newlineChar: .byte 10        # السطر الجديد ('\n') ASCII 10
endOfBuffer: .byte 0         # نهاية السلسلةة
newline: .asciiz "\n"    # ت
Arrays: .space 512          # لتخزين عدة معادلات (4 معادلات × 128 بايت لكل معادل
Coefficient: .space 512
Variables: .space 128
Results: .space 512
LineCount: .word 0
result1: .float 0.0  # لتخزين نتيجة القسمة الأولى
result2: .float 0.0  # لتخزين نتيجة القسمة الثانية
X: .float 0.0
Y: .float 0.0
Z: .float 0.0
done_flag: .word 0  # متغير لتحديد إذا انتهت العمليات

.text
.globl main
main:
    # فتح الملف
    li $v0, 13           # syscall لفتح الملف
    la $a0, fileName     # مسار الملف
    li $a1, 0            # وضع القراءة فقط
    syscall
    bltz $v0, error      # إذا فشل فتح الملف، انتقل إلى error
    move $s0, $v0        # حفظ معرف الملف
    # قراءة البيانات من الملف
    li $v0, 14           # syscall للقراءة
    move $a0, $s0        # معرف الملف
    la $a1, fileWords    # تخزين البيانات في buffer
    li $a2, 1024         # حجم البيانات المراد قراءتها
    syscall
    bltz $v0, error      # إذا فشلت القراءة، انتقل إلى error
    # تحليل البيانات المقروءة
    la $t0, fileWords    # مؤشر إلى بداية البيانات
    la $t1, lineBuffer   # مؤشر لتخزين معادلة واحدة
    la $t9, Arrays       # $t9 مؤشر إلى بداية Arrays (وجهة النسخ)
    la $s7, Arrays
    li $t8, 32         # $t8 يُستخدم لتحديد حجم كل معادلة (للتنقل بين المواقع)

read_line:
    lb $t2, 0($t0)       # قراءة بايت واحد من buffer
    #lw $t6,LineCount
    #li $s2,3
    #beq $t6,$s2,Hello
    beqz $t2, Check      # إذا وصلنا إلى نهاية البيانات، انتقل إلى إغلاق الملف
    li $t3, 10           # تحميل القيمة ASCII للسطر الجديد ('\n') في $t3
    beq $t2, $t3, process_line # إذا كان الحرف سطرًا جديدًا، انتقل لمعالجة المعادلة
    sb $t2, 0($t1)       # تخزين الحرف في lineBuffer
    addi $t0, $t0, 1     # الانتقال إلى الحرف التالي في buffer
    addi $t1, $t1, 1     # الانتقال إلى الموقع التالي في lineBuffer
    j read_line          # كرر قراءة الحرف التالي
    
Check:
    move $s6,$s7
    move $t1, $s7         # تحميل العنوان في $t1
    lb $t3, 0($t1)        # قراءة أول قيمة من العنوان
    #li $t9, '-'
   # beq $t3, $t9, negative # إذا كان الحرف '-'
    la $t0,Coefficient
    subi $t0,$t0,2
    la $t2,Variables
    la $t7,Results
    subi $t7,$t7,2
    move $t5,$t7
    move $t8,$t2
    
check_number:
    li $s2, 48            # ASCII للصفر
    li $s3, 57            # ASCII للتسعة
    li $s4, 65              # ASCII للحرف 'A'
    li $s5, 90              # ASCII للحرف 'Z'
    li $t5,0 
check_loop:
    beqz $t3,go_Next  # إذا كانت القيمة صفرًا (نهاية النص)، إنهاء
    li $t6,61
    beq $t6,$t3,go_Next
Coefi_:
    li $t9, '-'
    beq $t3, $t9, negative # إذا كان الحرف '-'
    blt $t3, $s2, next_char # إذا كانت أقل من ASCII للصفر، انتقل إلى الخانة التالية
    bgt $t3, $s3, next_char # إذا كانت أكبر من ASCII للتسعة، انتقل إلى الخانة التالية  لي 
    beq $t3, 43, next_char
    subi $t3,$t3,48
    #sb $t3,0($t0)
    mul $t5, $t5, 10           # ضرب الرقم السابق بـ 10
    
    add $t5, $t5, $t3          # إض
    move $t3,$t5
     # تخزين الرقم المؤقت في المصفوفة
    move $t5, $t3                
    li $v0, 11            # syscall لطباعة حرف
    move $a0, $t3         # تحميل الرقم إلى $a0
    syscall
    # الانتقال إلى العنوان التالي
    j next_char 
negative:
    move $s0,$t3
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    j Coefi_
go_Next:
    beq $t3, $t6, ADD_Results  # إذا كانت القيمة '=', انتقل إلى ADD_Results
    addi $s7, $s7, 32          # تحريك $s7
    lb $t3, 0($s7)             # قراءة القيمة التالية
    move $t1, $s7              # تحديث $t1
    addi $t0, $t0, 24     # تحديث مؤشر Coefficient
    addi $t7,$t7,28
    lw $t6,LineCount     ################################################################
    li $s2,3
    beqz $t3, CR       # إذا كانت القيمة صفرًا، إنهاء
    j check_loop               # العودة إلى الحلقة
go_Next_EQ:
    addi $t1,$t1,1
ADD_Results:    
add_results_loop:
    lb $t3, 0($t1)             # قراءة البايت الحالي
    li $t9,45
    beq $t3, $t9, negativeCoef# إذا كان الحرف '-'
    
    li $t4, 13                 # ASCII لـ \r
    beq $t3, $t4, store_value  # إذا كانت القيمة \r، انتقل إلى store_value
    beqz $t3, go_Next          # إذا كانت القيمة صفرًا (نهاية النص)، انتقل إلى go_Next
    li $t6, 61                 # علامة '='
    beq $t3, $t6, go_Next_EQ   # إذا كانت '='، انتقل إلى go_Next_EQ
    subi $t3, $t3, 48          # تحويل الحرف الرقمي إلى رقم
    mul $t5, $t5, 10           # ضرب الرقم السابق بـ 10
    add $t5, $t5, $t3          # إضافة الرقم الجديد
    addi $t1, $t1, 1           # الانتقال إلى العنوان التالي
    j add_results_loop         # العودة للتحقق من البايت التالي
negativeCoef:
    move $s0,$t3
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    j add_results_loop 
store_value:
    beq $s0,45,StoreNeg
    sw $t5, 0($t7)             # تخزين القيمة في Results
    addi $t7, $t7, 4           # تحديث مؤشر Results
    li $t5, 0                  # إعادة تعيين المؤقت
    addi $t1, $t1, 1           # الانتقال إلى العنوان التالي
    li $s0,0
    j add_results_loop         # العودة للتحقق من البايت التالي
StoreNeg:
    li $s0,0
    negu $t5, $t5          # تحويل الرقم إلى قيمة سالبة
    sw $t5, 0($t7)             # تخزين القيمة في Results
    addi $t7, $t7, 4           # تحديث مؤشر Results
    li $t5, 0                  # إعادة تعيين المؤقت
    addi $t1, $t1, 1           # الانتقال إلى العنوان التالي
    j add_results_loop         # العودة للتحقق من البايت التالي

next_char:
   # sw $t4, 0($t0)           # تخزين الرقم في Coefficient
   # addi $t0, $t0, 4         # الانتقال إلى الموقع التالي في المصفوفة
    blt $t3, $s4, not_char  # إذا كانت أقل من 'A'
    ble $t3, $s5, is_char   # إذا كانت بين 'A' و 'Z'    
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    li $t4,0
    j check_loop          # العودة للتحقق من البايت التالي

not_char:
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    j check_loop          # العودة للتحقق من البايت التال

is_char:
    beq $s0, 45, StoreNegCoeff  # إذا كانت القيمة سالبة، انتقل لمعالجة القيم السالبة
    sw $t5, 0($t0)              # تخزين الرقم في Coefficient
    addi $t0, $t0, 4            # الانتقال إلى الموقع التالي في المصفوفة
    li $t5, 0
    la $t8, Variables           # تحميل عنوان Variables
    move $t9, $zero             # عداد للتحقق من عناصر Variables

check_exists:
    lb $t4, 0($t8)              # تحميل عنصر من Variables
    beq $t4, $zero, add_value   # إذا وصلنا إلى نهاية Variables، أضف القيمة
    beq $t3, $t4, skip          # إذا كانت القيمة موجودة، تخطَ الإضافة
    addi $t8, $t8, 1            # الانتقال إلى العنصر التالي في Variables
    j check_exists

add_value:
    sb $t3, 0($t2)              # تخزين القيمة الجديدة في Variables
    addi $t2, $t2, 1            # الانتقال إلى الموقع التالي في Variables
    li $v0, 11                  # syscall لطباعة الحرف
    move $a0, $t3               # تحميل القيمة إلى $a0
    syscall                     # طباعة الحرف

skip:
    addi $t1, $t1, 1            # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)              # قراءة البايت التالي
    j check_loop

StoreNegCoeff:
    negu $t5, $t5               # عكس الإشارة للقيمة السالبة
    li $s0, 0
    sw $t5, 0($t0)              # تخزين الرقم السالب في Coefficient
    addi $t0, $t0, 4            # الانتقال إلى الموقع التالي في المصفوفة
    li $t5, 0
    la $t8, Variables           # تحميل عنوان Variables
    move $t9, $zero             # عداد للتحقق من عناصر Variables

check_exists_neg:
    lb $t4, 0($t8)              # تحميل عنصر من Variables
    beq $t4, $zero, add_value_neg # إذا وصلنا إلى نهاية Variables، أضف القيمة
    beq $t3, $t4, skip_neg      # إذا كانت القيمة موجودة، تخطَ الإضافة
    addi $t8, $t8, 1            # الانتقال إلى العنصر التالي في Variables
    j check_exists_neg

add_value_neg:
    sb $t3, 0($t2)              # تخزين القيمة الجديدة في Variables
    addi $t2, $t2, 1            # الانتقال إلى الموقع التالي في Variables
    li $v0, 11                  # syscall لطباعة الحرف
    move $a0, $t3               # تحميل القيمة إلى $a0
    syscall                     # طباعة الحرف

skip_neg:
    addi $t1, $t1, 1            # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)              # قراءة البايت التالي
    j check_loop

checkLoop:
    addi $t8, $t8, 32
    addi $t1, $t1, 1
    lb $t3, 0($t1)
    j check_loop

CR:
    beq $t6,$s2,CR3 
  # --- حساب D ---
    la $t1, Coefficient
    subi $t1, $t1, 2
    lw $t4, 0($t1)         # t4 = Coefficient[0]
    addi $t1, $t1, 32
    lw $t5, 0($t1)         # t5 = Coefficient[1]
    
    la $t1, Coefficient
    subi $t1, $t1, 2
    addi $t1, $t1, 4
    lw $t6, 0($t1)         # t6 = Coefficient[2]
    addi $t1, $t1, 32
    lw $t7, 0($t1)         # t7 = Coefficient[3]
    
    mul $t2, $t4, $t7      # t2 = t4 * t7
    mul $t3, $t5, $t6      # t3 = t5 * t6
    sub $t7, $t2, $t3      # t7 = D

    # --- حساب Dx ---
    la $t1, Results
    subi $t1, $t1, 2
    lw $t4, 0($t1)         # t4 = Results[0]
    addi $t1, $t1, 32
    lw $t5, 0($t1)         # t5 = Results[1]
    
    la $t1, Coefficient
    subi $t1, $t1, 2
    addi $t1, $t1, 4
    lw $t6, 0($t1)         # t6 = Coefficient[2]
    addi $t1, $t1, 32
    lw $t7, 0($t1)         # t7 = Coefficient[3]
    
    mul $t2, $t4, $t7      # t2 = t4 * t7
    mul $t3, $t5, $t6      # t3 = t5 * t6
    sub $t8, $t2, $t3      # t8 = Dx

    # --- حساب Dy ---
    la $t1, Results
    subi $t1, $t1, 2
    lw $t6, 0($t1)         # t6 = Results[0]
    addi $t1, $t1, 32
    lw $t7, 0($t1)         # t7 = Results[1]
    
    la $t1, Coefficient
    subi $t1, $t1, 2
    lw $t4, 0($t1)         # t4 = Coefficient[0]
    addi $t1, $t1, 32
    lw $t5, 0($t1)         # t5 = Coefficient[1]
    
    mul $t2, $t4, $t7      # t2 = t4 * t7
    mul $t3, $t5, $t6      # t3 = t5 * t6
    sub $t9, $t2, $t3      # t9 = Dy

    # --- تحويل النتائج إلى نقاط عائمة ---
    mtc1 $t8, $f4          # نقل Dx إلى السجل العائم $f4
    cvt.s.w $f4, $f4       # تحويل Dx إلى نقطة عائمة

    mtc1 $t7, $f5          # نقل D إلى السجل العائم $f5
    cvt.s.w $f5, $f5       # تحويل D إلى نقطة عائمة

    mtc1 $t9, $f6          # نقل Dy إلى السجل العائم $f6
    cvt.s.w $f6, $f6       # تحويل Dy إلى نقطة عائمة

    # --- إجراء القسمة للحصول على X و Y ---
    div.s $f0, $f4, $f5    # $f0 = Dx / D
    div.s $f1, $f6, $f5    # $f1 = Dy / D

    # --- تخزين النتائج في الذاكرة ---
    s.s $f0, result1       # تخزين X في result1
    s.s $f1, result2       # تخزين Y في result2

    # --- طباعة النتائج ---
    li $v0, 4
    la $a0, newline
    syscall

    # طباعة X
    l.s $f12, result1
    li $v0, 2
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # طباعة Y
    l.s $f12, result2
    li $v0, 2
    syscall
    j end_check
CR3:   
    la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t2, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t3, 0($t0)
    addi $t0, $t0, 28
    lw $t4, 0($t0)
    addi $t0,$t0,4
    lw $t5, 0($t0)
    addi $t0,$t0,4
    lw $t6, 0($t0)
    addi $t0, $t0, 28
    lw $t7, 0($t0)
    addi $t0,$t0,4
    lw $t8, 0($t0)
    addi $t0,$t0,4
    lw $t9, 0($t0)
D:    # D
    mul $t4,$t5,$t9
    mul $t7,$t6,$t8
    sub $t4,$t4,$t7
    mul $t1,$t1,$t4
    move $s4,$t1
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 36
    lw $t4, 0($t0)
    addi $t0, $t0, 36
    lw $t7, 0($t0)
    mul $t5,$t4,$t9
    mul $t8,$t6,$t7
    sub $t5,$t5,$t8
    mul $t2,$t2,$t5
    move $s5,$t2
    #3
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 40
    lw $t5, 0($t0)
    addi $t0, $t0, 36
    lw $t8, 0($t0)
    
    mul $t6,$t4,$t8
    mul $t9,$t5,$t7
    sub $t6,$t6,$t9
    mul $t3,$t3,$t6
    move $s6,$t3
    
    sub $s4,$s4,$s5
    add $s5,$s4,$s6
    move $s7,$s5
         # تحقق من الانتهاء

DX: 
    la $s0, Results
    subi $s0, $s0, 2
    la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($s0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t2, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t3, 0($t0)
    la $s0, Results
    subi $s0,$s0,2
    addi $s0,$s0,32
    addi $t0, $t0, 28
    lw $t4, 0($s0)
    addi $t0,$t0,4
    lw $t5, 0($t0)
    addi $t0,$t0,4
    lw $t6, 0($t0)
    addi $t0, $t0, 28
    addi $s0,$s0,32
    lw $t7, 0($s0)
    addi $t0,$t0,4
    lw $t8, 0($t0)
    addi $t0,$t0,4
    lw $t9, 0($t0)
    # تحديث العلامة إلى انتهاء
    mul $t4,$t5,$t9
    mul $t7,$t6,$t8
    sub $t4,$t4,$t7
    mul $t1,$t1,$t4
    move $s4,$t1
    la $s0, Results
    subi $s0, $s0, 2
    lw $t1, 0($s0)
    la $s0, Results
    subi $s0, $s0, 2
    addi $s0, $s0, 32
    lw $t4, 0($s0)
    addi $s0, $s0, 32
    lw $t7, 0($s0)
    
    mul $t5,$t4,$t9
    mul $t8,$t6,$t7
    sub $t5,$t5,$t8
    mul $t2,$t2,$t5
    move $s5,$t2
    #3
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 40
    lw $t5, 0($t0)
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 4
    lw $t2, 0($t0)
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 4
    addi $t0, $t0, 32
    addi $t0, $t0, 36############8888
    lw $t8, 0($t0)
   
    mul $t6,$t4,$t8
    mul $t9,$t5,$t7
    sub $t6,$t6,$t9
    mul $t3,$t3,$t6
    move $s6,$t3############الخلل
    sub $s4,$s4,$s5
    add $s1,$s4,$s6
   
    # تحقق من الانت
DY: 
    la $s0, Results
    subi $s0, $s0, 2
    la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t2, 0($s0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t3, 0($t0)
    la $s0, Results
    subi $s0,$s0,2
    addi $s0,$s0,32
    addi $t0, $t0, 28
    lw $t4, 0($t0)
    addi $t0,$t0,4
    lw $t5, 0($s0)
    addi $t0,$t0,4
    lw $t6, 0($t0)
    addi $t0, $t0, 28
    addi $s0,$s0,32
    lw $t7, 0($t0)
    addi $t0,$t0,4
    lw $t8, 0($s0)
    addi $t0,$t0,4
    lw $t9, 0($t0)
    # تحديث العلامة إلى انتهاء
    mul $t4,$t5,$t9
    mul $t7,$t6,$t8
    sub $t4,$t4,$t7
    mul $t1,$t1,$t4
    move $s4,$t1
    la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($t0)
    addi $t0, $t0, 36
    lw $t4, 0($t0)
    addi $t0, $t0, 36
    lw $t7, 0($t0)
    mul $t5,$t4,$t9
    mul $t8,$t6,$t7
    sub $t5,$t5,$t8
    mul $t2,$t2,$t5
    move $s5,$t2
    #3
    la $t0, Coefficient
    subi $t0, $t0, 2
    la $s0, Results
    subi $s0,$s0,2
    lw $t2, 0($s0)
    addi $s0, $s0, 32
    lw $t5, 0($s0)
    addi $s0, $s0, 32
    lw $t8, 0($s0)
    mul $t6,$t4,$t8
    mul $t9,$t5,$t7
    sub $t6,$t6,$t9
    mul $t3,$t3,$t6
    move $s6,$t3   
    sub $s4,$s4,$s5
    add $s5,$s4,$s6
    move $s2,$s5
    # تحقق من الان
DZ: 
   la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    lw $t2, 0($t0)         # t1 = Coefficient[0]
    addi $t0,$t0,4
    la $s0, Results
    subi $s0,$s0,2
    lw $t3, 0($s0) 
    addi $t0, $t0, 28
    lw $t4, 0($t0)
    addi $t0,$t0,4
    lw $t5, 0($t0)
    addi $t0,$t0,4
    addi $s0,$s0,32
    lw $t6, 0($s0)
    addi $t0, $t0, 28
    lw $t7, 0($t0)
    addi $t0,$t0,4
    lw $t8, 0($t0)
    addi $t0,$t0,4
    addi $s0,$s0,32
    lw $t9, 0($s0)
    mul $t4,$t5,$t9
    mul $t7,$t6,$t8
    sub $t4,$t4,$t7
    mul $t1,$t1,$t4
    move $s4,$t1
    la $t0, Coefficient
    subi $t0, $t0, 2
    lw $t1, 0($t0)
    addi $t0, $t0, 36
    lw $t4, 0($t0)
    addi $t0, $t0, 36
    lw $t7, 0($t0)
    mul $t5,$t4,$t9
    mul $t8,$t6,$t7
    sub $t5,$t5,$t8
    mul $t2,$t2,$t5
    move $s5,$t2
    #3
    la $t0, Coefficient
    subi $t0, $t0, 2
    addi $t0, $t0, 4
    lw $t2, 0($t0)
    addi $t0, $t0, 36
    lw $t5, 0($t0)
    addi $t0, $t0, 36
    lw $t8, 0($t0)
    mul $t6,$t4,$t8
    mul $t9,$t5,$t7
    sub $t6,$t6,$t9
    mul $t3,$t3,$t6
    move $s6,$t3   
    sub $s4,$s4,$s5
    add $s5,$s4,$s6
    move $s3,$s5
    # تحقق من الان
    
CALC_X_Y_Z:

    move $t1,$s7#D
    move $t2,$s1#DX
    move $t3,$s2#DY
    move $t4,$s3#DZ
      # --- تحويل النتائج إلى نقاط عائمة ---
    mtc1 $t1, $f5          # نقل D إلى السجل العائم $f5
    cvt.s.w $f5, $f5       # تحويل D إلى نقطة عائمة

    mtc1 $t2, $f4          # نقل Dx إلى السجل العائم $f4
    cvt.s.w $f4, $f4       # تحويل Dx إلى نقطة عائمة

    mtc1 $t3, $f6          # نقل Dy إلى السجل العائم $f6
    cvt.s.w $f6, $f6       # تحويل Dy إلى نقطة عائمة
    mtc1 $t4, $f7          # نقل DZ--> D$f7
    cvt.s.w $f7, $f7       # تحويل Dy إلى نقطة عائمة

    # --- إجراء القسمة للحصول على X و Y ---
    div.s $f0, $f4, $f5    # $f0 = Dx / D
    div.s $f1, $f6, $f5    # $f1 = Dy / D
    div.s $f2, $f7, $f5    # $f1 = Dy / D
   
    # --- تخزين النتائج في الذاكرة ---
    s.s $f0, X      # تخزين X في result1
    s.s $f1, Y      # تخزين Y في result2
    s.s $f2, Z
    # --- طباعة النتائج ---
    li $v0, 4
    la $a0, newline
    syscall

    # طباعة X
    l.s $f12, X
    li $v0, 2
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # طباعة Y
    l.s $f12, Y
    li $v0, 2
    syscall
    li $v0, 4
    la $a0, newline
    syscall
        #طباعة Z
    l.s $f12, Z
    li $v0, 2
    syscall
    
end_check:
    # طباعة سطر جديد بعد الأرقام
    li $v0, 4
    la $a0, newline
    syscall

    # إنهاء البرنامج
    li $v0, 10            # syscall لإنهاء البرنامج
    syscall

process_line:
    sb $zero, 0($t1)     # إضافة نهاية السلسلة إلى lineBuffer
    # طباعة المعادلة
    li $v0, 4            # syscall للطباعة
    la $a0, lineBuffer   # طباعة محتويات lineBuffer
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # إعداد النسخ: lineBuffer --> Arrays (بداية القسم المناسب)
    la $t5, lineBuffer   # تحميل عنوان lineBuffer إلى $t5
    move $t4, $t9        # تحميل عنوان المصفوفة الحالية (المؤشر الديناميكي) إلى $t4
    li $t6, 128          # حجم البيانات المراد نسخها (128 بايت كحد أقصى)    

copy_loop:
    beqz $t6, end_copy   # إذا انتهت البيانات (t6 = 0)، انتقل إلى نهاية النسخ
    lb $t7, 0($t5)       # قراءة بايت واحد من lineBuffer
    beqz $t7, end_copy   # إذا كان البايت هو \0 (نهاية السلسلة)، توقف عن النسخ
    sb $t7, 0($t4)       # تخزين البايت في المصفوفة الحالية
    addi $t5, $t5, 1     # الانتقال إلى البايت التالي في lineBuffer
    addi $t4, $t4, 1     # الانتقال إلى البايت التالي في Arrays
    subi $t6, $t6, 1     # تقليل العداد t6
    j copy_loop          # العودة إلى بداية الحلقة

end_copy:
    # تحريك المؤشر إلى المصفوفة التالية
    add $t9, $t9, $t8    # الانتقال إلى المصفوفة التالية في Arrays
    lw $t5,LineCount
    addi $t5,$t5,1
    sw $t5,LineCount
    # إعادة تعيين المؤشر للمعادلة التالية
    la $t1, lineBuffer   # إعادة المؤشر إلى بداية lineBuffer
    addi $t0, $t0, 1     # تخطي محرف السطر الجديد
    
    j read_line          # العودة لقراءة السطر التالي
close_file:
    # إغلاق الملف
    li $v0, 16           # syscall لإغلاق الملف
    move $a0, $s0        # معرف الملف
    syscall

    # إنهاء البرنامج
    li $v0, 10           # syscall لإنهاء البرنامج
    syscall

error:
    # عرض رسالة خطأ
    li $v0, 4  
    la $a0, errorMsg
    syscall

    # إنهاء البرنامج
    li $v0, 10
    syscall
