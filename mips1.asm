.data
fileName: .asciiz "C:\\Users\\leena\\Desktop\\ARC\\input.txt" # مسار الملف
fileWords: .space 1024       # لتخزين البيانات المقروءة من الملف
lineBuffer: .space 128     # لتخزين معادلة واحدة
errorMsg: .asciiz "Error reading the file.\n" # رسالة خطأ
newlineChar: .byte 10        # السطر الجديد ('\n') ASCII 10
endOfBuffer: .byte 0         # نهاية السلسلةة
newline: .asciiz "\n"    # ت
Arrays: .space 512          # لتخزين عدة معادلات (4 معادلات × 128 بايت لكل معادل
Coefficient: .space 128
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
    li $t8, 32          # $t8 يُستخدم لتحديد حجم كل معادلة (للتنقل بين المواقع)

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
    move $t1, $s7         # تحميل العنوان في $t1
    lb $t3, 0($t1)        # قراءة أول قيمة من العنوان
    la $t0,Coefficient

check_number:
    li $t4, 48            # ASCII للصفر
    li $t5, 57            # ASCII للتسعة
check_loop:
    beqz $t3,go_Next  # إذا كانت القيمة صفرًا (نهاية النص)، إنهاء
    li $t6,61
    beq $t6,$t3,go_Next
    blt $t3, $t4, next_char # إذا كانت أقل من ASCII للصفر، انتقل إلى الخانة التالية
    bgt $t3, $t5, next_char # إذا كانت أكبر من ASCII للتسعة، انتقل إلى الخانة التالية  
    # إذا كانت القيمة رقمًا، اطبعها
    sb $t3,0($t0)
    addi $t0,$t0,1
    li $v0, 11            # syscall لطباعة حرف
    move $a0, $t3         # تحميل الرقم إلى $a0
    syscall
    # الانتقال إلى العنوان التالي
    j next_char           # انتقل مباشرةً لمعالجة البايت التالي
go_Next:
    addi $s7,$s7,32
    lb $t3,0($s7)
    move $t1,$s7
    addi $t0,$t0,30
    beqz $t3,end_check
    j check_loop
    
next_char:
    addi $t1, $t1, 1      # الانتقال إلى العنوان التالي
    lb $t3, 0($t1)        # قراءة البايت التالي
    j check_loop          # العودة للتحقق من البايت التالي

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
