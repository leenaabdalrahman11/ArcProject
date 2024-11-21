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
Results: .space 128
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
    la $t0,Coefficient
    subi $t0,$t0,2
    la $t2,Variables
    la $t7,Results
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
    blt $t3, $s2, next_char # إذا كانت أقل من ASCII للصفر، انتقل إلى الخانة التالية
    bgt $t3, $s3, next_char # إذا كانت أكبر من ASCII للتسعة، انتقل إلى الخانة التالية  لي 
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
   
go_Next:
    beq $t3, $t6, ADD_Results  # إذا كانت القيمة '=', انتقل إلى ADD_Results
    addi $s7, $s7, 32          # تحريك $s7
    lb $t3, 0($s7)             # قراءة القيمة التالية
    move $t1, $s7              # تحديث $t1
    addi $t0, $t0, 24     # تحديث مؤشر Coefficient
    addi $t7,$t7,30
    beqz $t3, end_check        # إذا كانت القيمة صفرًا، إنهاء
    j check_loop               # العودة إلى الحلقة
go_Next_EQ:
    addi $t1,$t1,1

ADD_Results:
add_results_loop:
    lb $t3, 0($t1)             # قراءة البايت الحالي
    # إذا كانت القيمة صفرًا (نهاية النص)، انتقل إلى go_Next
    beq $t3, $t6, go_Next_EQ      # إذا كانت '=', انتقل إلى go_Nex t
    beqz $t3, go_Next
    li $t4, 13                 # ASCII لـ \r
    beq $t3, $t4, skip_store   # إذا كانت القيمة \r، 
    sb $t3, 0($t7)             # تخزين القيمة في Results
    addi $t7, $t7, 1           # تحديث مؤشر Results
    addi $t1, $t1, 1           # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)             # قراءة البايت التالي
    li $v0, 11                 # syscall لطباعة حرف
    move $a0, $t3              # تحميل الرقم للطباعة
    syscall
    j add_results_loop         # العودة للتحقق من البايت التالي

skip_store:
    addi $t1, $t1, 1           # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)             # قراءة البايت التالي
    li $v0, 11                 # syscall لطباعة حرف
    move $a0, $t3              # تحميل الرقم للطباعة
    syscall
    j add_results_loop         # العودة للتح   
 
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
    sw $t5, 0($t0)           # تخزين الرقم في Coefficient
    addi $t0, $t0, 4         # الانتقال إلى الموقع التالي في المصفوفة
    li $t5,0
    lb $t9,0($t8)
    beq $t3,$t9,checkLoop
    sb $t3,0($t2)
    addi $t2,$t2,32
    li $v0, 11            # syscall لطباعة حرف
    move $a0, $t3         # تحميل الرقم إلى $a0
    syscall
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    j check_loop 
    
checkLoop:
    addi $t8,$t8,32
    addi $t1,$t1,1
    lb $t3, 0($t1) 
    j check_loop 
    
    
end_check:
    # طباعة سطر جديد بعد الأرقام
    li $v0, 4
    la $a0, newline
    syscall
    move $s7,$s6
    #ble $t3, $s5, is_char    # إذا كانت بين 'A' و 'Z'، هي حرف
    
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
