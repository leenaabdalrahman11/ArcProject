.data
fileName: .asciiz "C:\\Users\\leena\\Desktop\\ARC\\input.txt" # مسار الملف
fileWords: .space 1024       # لتخزين البيانات المقروءة من الملف
lineBuffer: .space 128       # لتخزين معادلة واحدة
errorMsg: .asciiz "Error reading the file.\n" # رسالة خطأ
newlineChar: .byte 10        # السطر الجديد ('\n') ASCII 10
endOfBuffer: .byte 0         # نهاية السلسلة

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

read_line:
    lb $t2, 0($t0)       # قراءة بايت واحد من buffer
    beqz $t2, close_file # إذا وصلنا إلى نهاية البيانات، انتقل إلى إغلاق الملف
    li $t3, 10           # تحميل القيمة ASCII للسطر الجديد ('\n') في $t3
    beq $t2, $t3, process_line # إذا كان الحرف سطرًا جديدًا، انتقل لمعالجة المعادلة
    sb $t2, 0($t1)       # تخزين الحرف في lineBuffer
    addi $t0, $t0, 1     # الانتقال إلى الحرف التالي في buffer
    addi $t1, $t1, 1     # الانتقال إلى الموقع التالي في lineBuffer
    j read_line          # كرر قراءة الحرف التالي

process_line:
    sb $zero, 0($t1)     # إضافة نهاية السلسلة إلى lineBuffer
    # طباعة المعادلة
    li $v0, 4            # syscall للطباعة
    la $a0, lineBuffer   # طباعة محتويات lineBuffer
    syscall

    # إعادة تعيين المؤشر للمعادلة التالية
    la $t1, lineBuffer   # إعادة المؤشر إلى بداية lineBuffer
    addi $t0, $t0, 1     # تخطي محرف السطر الجديد
    j read_line          # العودة لقراءة المعادلة التالية

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
