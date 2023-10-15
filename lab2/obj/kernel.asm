
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	44260613          	addi	a2,a2,1090 # ffffffffc0206480 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2ab010ef          	jal	ra,ffffffffc0201af8 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201b10 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	34a010ef          	jal	ra,ffffffffc02013b4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	524010ef          	jal	ra,ffffffffc02015ce <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	4f0010ef          	jal	ra,ffffffffc02015ce <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	a2050513          	addi	a0,a0,-1504 # ffffffffc0201b60 <etext+0x56>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0201b80 <etext+0x76>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	9a858593          	addi	a1,a1,-1624 # ffffffffc0201b0a <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	a3650513          	addi	a0,a0,-1482 # ffffffffc0201ba0 <etext+0x96>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	ea258593          	addi	a1,a1,-350 # ffffffffc0206018 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	a4250513          	addi	a0,a0,-1470 # ffffffffc0201bc0 <etext+0xb6>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	2f658593          	addi	a1,a1,758 # ffffffffc0206480 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201be0 <etext+0xd6>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00006597          	auipc	a1,0x6
ffffffffc02001a2:	6e158593          	addi	a1,a1,1761 # ffffffffc020687f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0201c00 <etext+0xf6>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	96060613          	addi	a2,a2,-1696 # ffffffffc0201b30 <etext+0x26>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201b48 <etext+0x3e>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	b2460613          	addi	a2,a2,-1244 # ffffffffc0201d10 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	b3c58593          	addi	a1,a1,-1220 # ffffffffc0201d30 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0201d38 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0201d48 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	b5e58593          	addi	a1,a1,-1186 # ffffffffc0201d70 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0201d38 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0201d80 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	b7258593          	addi	a1,a1,-1166 # ffffffffc0201da0 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0201d38 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	a0850513          	addi	a0,a0,-1528 # ffffffffc0201c78 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0201ca0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	988c8c93          	addi	s9,s9,-1656 # ffffffffc0201c30 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	a1898993          	addi	s3,s3,-1512 # ffffffffc0201cc8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	a1890913          	addi	s2,s2,-1512 # ffffffffc0201cd0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	a16b0b13          	addi	s6,s6,-1514 # ffffffffc0201cd8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	a66a8a93          	addi	s5,s5,-1434 # ffffffffc0201d30 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	684010ef          	jal	ra,ffffffffc020195a <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	7f2010ef          	jal	ra,ffffffffc0201ada <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00002d17          	auipc	s10,0x2
ffffffffc0200302:	932d0d13          	addi	s10,s10,-1742 # ffffffffc0201c30 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	7a4010ef          	jal	ra,ffffffffc0201ab0 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	790010ef          	jal	ra,ffffffffc0201ab0 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	754010ef          	jal	ra,ffffffffc0201ada <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201cf8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06c30313          	addi	t1,t1,108 # ffffffffc0206418 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72423          	sw	a5,72(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	9d250513          	addi	a0,a0,-1582 # ffffffffc0201db0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	83450513          	addi	a0,a0,-1996 # ffffffffc0201c28 <etext+0x11e>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	610010ef          	jal	ra,ffffffffc0201a34 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007bb23          	sd	zero,22(a5) # ffffffffc0206440 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	99e50513          	addi	a0,a0,-1634 # ffffffffc0201dd0 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	5e80106f          	j	ffffffffc0201a34 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	5c20106f          	j	ffffffffc0201a18 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	5f60106f          	j	ffffffffc0201a50 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	32278793          	addi	a5,a5,802 # ffffffffc0200790 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0201ed0 <commands+0x2a0>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a5450513          	addi	a0,a0,-1452 # ffffffffc0201ee8 <commands+0x2b8>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0201f00 <commands+0x2d0>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a6850513          	addi	a0,a0,-1432 # ffffffffc0201f18 <commands+0x2e8>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0201f30 <commands+0x300>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0201f48 <commands+0x318>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a8650513          	addi	a0,a0,-1402 # ffffffffc0201f60 <commands+0x330>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a9050513          	addi	a0,a0,-1392 # ffffffffc0201f78 <commands+0x348>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0201f90 <commands+0x360>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201fa8 <commands+0x378>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	aae50513          	addi	a0,a0,-1362 # ffffffffc0201fc0 <commands+0x390>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201fd8 <commands+0x3a8>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	ac250513          	addi	a0,a0,-1342 # ffffffffc0201ff0 <commands+0x3c0>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	acc50513          	addi	a0,a0,-1332 # ffffffffc0202008 <commands+0x3d8>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	ad650513          	addi	a0,a0,-1322 # ffffffffc0202020 <commands+0x3f0>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0202038 <commands+0x408>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	aea50513          	addi	a0,a0,-1302 # ffffffffc0202050 <commands+0x420>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	af450513          	addi	a0,a0,-1292 # ffffffffc0202068 <commands+0x438>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	afe50513          	addi	a0,a0,-1282 # ffffffffc0202080 <commands+0x450>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	b0850513          	addi	a0,a0,-1272 # ffffffffc0202098 <commands+0x468>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	b1250513          	addi	a0,a0,-1262 # ffffffffc02020b0 <commands+0x480>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02020c8 <commands+0x498>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b2650513          	addi	a0,a0,-1242 # ffffffffc02020e0 <commands+0x4b0>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b3050513          	addi	a0,a0,-1232 # ffffffffc02020f8 <commands+0x4c8>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0202110 <commands+0x4e0>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0202128 <commands+0x4f8>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202140 <commands+0x510>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b5850513          	addi	a0,a0,-1192 # ffffffffc0202158 <commands+0x528>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b6250513          	addi	a0,a0,-1182 # ffffffffc0202170 <commands+0x540>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202188 <commands+0x558>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b7650513          	addi	a0,a0,-1162 # ffffffffc02021a0 <commands+0x570>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02021b8 <commands+0x588>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02021d0 <commands+0x5a0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02021e8 <commands+0x5b8>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b8650513          	addi	a0,a0,-1146 # ffffffffc0202200 <commands+0x5d0>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0202218 <commands+0x5e8>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0202230 <commands+0x600>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76a63          	bltu	a4,a5,ffffffffc020074c <interrupt_handler+0xa0>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	73070713          	addi	a4,a4,1840 # ffffffffc0201dec <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	7b250513          	addi	a0,a0,1970 # ffffffffc0201e80 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	78650513          	addi	a0,a0,1926 # ffffffffc0201e60 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	73a50513          	addi	a0,a0,1850 # ffffffffc0201e20 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	74e50513          	addi	a0,a0,1870 # ffffffffc0201e40 <commands+0x210>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02006fe:	00001517          	auipc	a0,0x1
ffffffffc0200702:	7b250513          	addi	a0,a0,1970 # ffffffffc0201eb0 <commands+0x280>
ffffffffc0200706:	9b1ff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020070a:	1141                	addi	sp,sp,-16
ffffffffc020070c:	e022                	sd	s0,0(sp)
ffffffffc020070e:	e406                	sd	ra,8(sp)
              clock_set_next_event();
ffffffffc0200710:	d31ff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            ticks++;
ffffffffc0200714:	00006717          	auipc	a4,0x6
ffffffffc0200718:	d2c70713          	addi	a4,a4,-724 # ffffffffc0206440 <ticks>
ffffffffc020071c:	631c                	ld	a5,0(a4)
ffffffffc020071e:	00006417          	auipc	s0,0x6
ffffffffc0200722:	d0240413          	addi	s0,s0,-766 # ffffffffc0206420 <num>
ffffffffc0200726:	0785                	addi	a5,a5,1
ffffffffc0200728:	00006697          	auipc	a3,0x6
ffffffffc020072c:	d0f6bc23          	sd	a5,-744(a3) # ffffffffc0206440 <ticks>
            if(ticks%100==0){
ffffffffc0200730:	631c                	ld	a5,0(a4)
ffffffffc0200732:	06400713          	li	a4,100
ffffffffc0200736:	02e7f7b3          	remu	a5,a5,a4
ffffffffc020073a:	cb99                	beqz	a5,ffffffffc0200750 <interrupt_handler+0xa4>
	if(num==10){
ffffffffc020073c:	6018                	ld	a4,0(s0)
ffffffffc020073e:	47a9                	li	a5,10
ffffffffc0200740:	02f70763          	beq	a4,a5,ffffffffc020076e <interrupt_handler+0xc2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200744:	60a2                	ld	ra,8(sp)
ffffffffc0200746:	6402                	ld	s0,0(sp)
ffffffffc0200748:	0141                	addi	sp,sp,16
ffffffffc020074a:	8082                	ret
            print_trapframe(tf);
ffffffffc020074c:	effff06f          	j	ffffffffc020064a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200750:	06400593          	li	a1,100
ffffffffc0200754:	00001517          	auipc	a0,0x1
ffffffffc0200758:	74c50513          	addi	a0,a0,1868 # ffffffffc0201ea0 <commands+0x270>
ffffffffc020075c:	95bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            num++;
ffffffffc0200760:	601c                	ld	a5,0(s0)
ffffffffc0200762:	0785                	addi	a5,a5,1
ffffffffc0200764:	00006717          	auipc	a4,0x6
ffffffffc0200768:	caf73e23          	sd	a5,-836(a4) # ffffffffc0206420 <num>
ffffffffc020076c:	bfc1                	j	ffffffffc020073c <interrupt_handler+0x90>
}
ffffffffc020076e:	6402                	ld	s0,0(sp)
ffffffffc0200770:	60a2                	ld	ra,8(sp)
ffffffffc0200772:	0141                	addi	sp,sp,16
	sbi_shutdown();
ffffffffc0200774:	2fa0106f          	j	ffffffffc0201a6e <sbi_shutdown>

ffffffffc0200778 <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200778:	11853783          	ld	a5,280(a0)
ffffffffc020077c:	0007c863          	bltz	a5,ffffffffc020078c <trap+0x14>
    switch (tf->cause) {
ffffffffc0200780:	472d                	li	a4,11
ffffffffc0200782:	00f76363          	bltu	a4,a5,ffffffffc0200788 <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
ffffffffc0200786:	8082                	ret
            print_trapframe(tf);
ffffffffc0200788:	ec3ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020078c:	f21ff06f          	j	ffffffffc02006ac <interrupt_handler>

ffffffffc0200790 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200790:	14011073          	csrw	sscratch,sp
ffffffffc0200794:	712d                	addi	sp,sp,-288
ffffffffc0200796:	e002                	sd	zero,0(sp)
ffffffffc0200798:	e406                	sd	ra,8(sp)
ffffffffc020079a:	ec0e                	sd	gp,24(sp)
ffffffffc020079c:	f012                	sd	tp,32(sp)
ffffffffc020079e:	f416                	sd	t0,40(sp)
ffffffffc02007a0:	f81a                	sd	t1,48(sp)
ffffffffc02007a2:	fc1e                	sd	t2,56(sp)
ffffffffc02007a4:	e0a2                	sd	s0,64(sp)
ffffffffc02007a6:	e4a6                	sd	s1,72(sp)
ffffffffc02007a8:	e8aa                	sd	a0,80(sp)
ffffffffc02007aa:	ecae                	sd	a1,88(sp)
ffffffffc02007ac:	f0b2                	sd	a2,96(sp)
ffffffffc02007ae:	f4b6                	sd	a3,104(sp)
ffffffffc02007b0:	f8ba                	sd	a4,112(sp)
ffffffffc02007b2:	fcbe                	sd	a5,120(sp)
ffffffffc02007b4:	e142                	sd	a6,128(sp)
ffffffffc02007b6:	e546                	sd	a7,136(sp)
ffffffffc02007b8:	e94a                	sd	s2,144(sp)
ffffffffc02007ba:	ed4e                	sd	s3,152(sp)
ffffffffc02007bc:	f152                	sd	s4,160(sp)
ffffffffc02007be:	f556                	sd	s5,168(sp)
ffffffffc02007c0:	f95a                	sd	s6,176(sp)
ffffffffc02007c2:	fd5e                	sd	s7,184(sp)
ffffffffc02007c4:	e1e2                	sd	s8,192(sp)
ffffffffc02007c6:	e5e6                	sd	s9,200(sp)
ffffffffc02007c8:	e9ea                	sd	s10,208(sp)
ffffffffc02007ca:	edee                	sd	s11,216(sp)
ffffffffc02007cc:	f1f2                	sd	t3,224(sp)
ffffffffc02007ce:	f5f6                	sd	t4,232(sp)
ffffffffc02007d0:	f9fa                	sd	t5,240(sp)
ffffffffc02007d2:	fdfe                	sd	t6,248(sp)
ffffffffc02007d4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007d8:	100024f3          	csrr	s1,sstatus
ffffffffc02007dc:	14102973          	csrr	s2,sepc
ffffffffc02007e0:	143029f3          	csrr	s3,stval
ffffffffc02007e4:	14202a73          	csrr	s4,scause
ffffffffc02007e8:	e822                	sd	s0,16(sp)
ffffffffc02007ea:	e226                	sd	s1,256(sp)
ffffffffc02007ec:	e64a                	sd	s2,264(sp)
ffffffffc02007ee:	ea4e                	sd	s3,272(sp)
ffffffffc02007f0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007f2:	850a                	mv	a0,sp
    jal trap
ffffffffc02007f4:	f85ff0ef          	jal	ra,ffffffffc0200778 <trap>

ffffffffc02007f8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007f8:	6492                	ld	s1,256(sp)
ffffffffc02007fa:	6932                	ld	s2,264(sp)
ffffffffc02007fc:	10049073          	csrw	sstatus,s1
ffffffffc0200800:	14191073          	csrw	sepc,s2
ffffffffc0200804:	60a2                	ld	ra,8(sp)
ffffffffc0200806:	61e2                	ld	gp,24(sp)
ffffffffc0200808:	7202                	ld	tp,32(sp)
ffffffffc020080a:	72a2                	ld	t0,40(sp)
ffffffffc020080c:	7342                	ld	t1,48(sp)
ffffffffc020080e:	73e2                	ld	t2,56(sp)
ffffffffc0200810:	6406                	ld	s0,64(sp)
ffffffffc0200812:	64a6                	ld	s1,72(sp)
ffffffffc0200814:	6546                	ld	a0,80(sp)
ffffffffc0200816:	65e6                	ld	a1,88(sp)
ffffffffc0200818:	7606                	ld	a2,96(sp)
ffffffffc020081a:	76a6                	ld	a3,104(sp)
ffffffffc020081c:	7746                	ld	a4,112(sp)
ffffffffc020081e:	77e6                	ld	a5,120(sp)
ffffffffc0200820:	680a                	ld	a6,128(sp)
ffffffffc0200822:	68aa                	ld	a7,136(sp)
ffffffffc0200824:	694a                	ld	s2,144(sp)
ffffffffc0200826:	69ea                	ld	s3,152(sp)
ffffffffc0200828:	7a0a                	ld	s4,160(sp)
ffffffffc020082a:	7aaa                	ld	s5,168(sp)
ffffffffc020082c:	7b4a                	ld	s6,176(sp)
ffffffffc020082e:	7bea                	ld	s7,184(sp)
ffffffffc0200830:	6c0e                	ld	s8,192(sp)
ffffffffc0200832:	6cae                	ld	s9,200(sp)
ffffffffc0200834:	6d4e                	ld	s10,208(sp)
ffffffffc0200836:	6dee                	ld	s11,216(sp)
ffffffffc0200838:	7e0e                	ld	t3,224(sp)
ffffffffc020083a:	7eae                	ld	t4,232(sp)
ffffffffc020083c:	7f4e                	ld	t5,240(sp)
ffffffffc020083e:	7fee                	ld	t6,248(sp)
ffffffffc0200840:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200842:	10200073          	sret

ffffffffc0200846 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200846:	00006797          	auipc	a5,0x6
ffffffffc020084a:	c0278793          	addi	a5,a5,-1022 # ffffffffc0206448 <free_area>
ffffffffc020084e:	e79c                	sd	a5,8(a5)
ffffffffc0200850:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200852:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200856:	8082                	ret

ffffffffc0200858 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200858:	00006517          	auipc	a0,0x6
ffffffffc020085c:	c0056503          	lwu	a0,-1024(a0) # ffffffffc0206458 <free_area+0x10>
ffffffffc0200860:	8082                	ret

ffffffffc0200862 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200862:	c15d                	beqz	a0,ffffffffc0200908 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200864:	00006617          	auipc	a2,0x6
ffffffffc0200868:	be460613          	addi	a2,a2,-1052 # ffffffffc0206448 <free_area>
ffffffffc020086c:	01062803          	lw	a6,16(a2)
ffffffffc0200870:	86aa                	mv	a3,a0
ffffffffc0200872:	02081793          	slli	a5,a6,0x20
ffffffffc0200876:	9381                	srli	a5,a5,0x20
ffffffffc0200878:	08a7e663          	bltu	a5,a0,ffffffffc0200904 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc020087c:	0018059b          	addiw	a1,a6,1
ffffffffc0200880:	1582                	slli	a1,a1,0x20
ffffffffc0200882:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200884:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0200886:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200888:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020088a:	00c78e63          	beq	a5,a2,ffffffffc02008a6 <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property<min_size) {
ffffffffc020088e:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200892:	fed76be3          	bltu	a4,a3,ffffffffc0200888 <best_fit_alloc_pages+0x26>
ffffffffc0200896:	feb779e3          	bleu	a1,a4,ffffffffc0200888 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc020089a:	fe878513          	addi	a0,a5,-24
ffffffffc020089e:	679c                	ld	a5,8(a5)
ffffffffc02008a0:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008a2:	fec796e3          	bne	a5,a2,ffffffffc020088e <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc02008a6:	c125                	beqz	a0,ffffffffc0200906 <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc02008a8:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02008aa:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc02008ac:	490c                	lw	a1,16(a0)
ffffffffc02008ae:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02008b2:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02008b4:	e310                	sd	a2,0(a4)
ffffffffc02008b6:	02059713          	slli	a4,a1,0x20
ffffffffc02008ba:	9301                	srli	a4,a4,0x20
ffffffffc02008bc:	02e6f863          	bleu	a4,a3,ffffffffc02008ec <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc02008c0:	00269713          	slli	a4,a3,0x2
ffffffffc02008c4:	9736                	add	a4,a4,a3
ffffffffc02008c6:	070e                	slli	a4,a4,0x3
ffffffffc02008c8:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008ca:	411585bb          	subw	a1,a1,a7
ffffffffc02008ce:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008d0:	4689                	li	a3,2
ffffffffc02008d2:	00870593          	addi	a1,a4,8
ffffffffc02008d6:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008da:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008dc:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008e0:	0107a803          	lw	a6,16(a5)
ffffffffc02008e4:	e28c                	sd	a1,0(a3)
ffffffffc02008e6:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008e8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008ea:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02008ec:	4118083b          	subw	a6,a6,a7
ffffffffc02008f0:	00006797          	auipc	a5,0x6
ffffffffc02008f4:	b707a423          	sw	a6,-1176(a5) # ffffffffc0206458 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008f8:	57f5                	li	a5,-3
ffffffffc02008fa:	00850713          	addi	a4,a0,8
ffffffffc02008fe:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200902:	8082                	ret
        return NULL;
ffffffffc0200904:	4501                	li	a0,0
}
ffffffffc0200906:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200908:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020090a:	00002697          	auipc	a3,0x2
ffffffffc020090e:	93e68693          	addi	a3,a3,-1730 # ffffffffc0202248 <commands+0x618>
ffffffffc0200912:	00002617          	auipc	a2,0x2
ffffffffc0200916:	93e60613          	addi	a2,a2,-1730 # ffffffffc0202250 <commands+0x620>
ffffffffc020091a:	06b00593          	li	a1,107
ffffffffc020091e:	00002517          	auipc	a0,0x2
ffffffffc0200922:	94a50513          	addi	a0,a0,-1718 # ffffffffc0202268 <commands+0x638>
best_fit_alloc_pages(size_t n) {
ffffffffc0200926:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200928:	a85ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020092c <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020092c:	715d                	addi	sp,sp,-80
ffffffffc020092e:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200930:	00006917          	auipc	s2,0x6
ffffffffc0200934:	b1890913          	addi	s2,s2,-1256 # ffffffffc0206448 <free_area>
ffffffffc0200938:	00893783          	ld	a5,8(s2)
ffffffffc020093c:	e486                	sd	ra,72(sp)
ffffffffc020093e:	e0a2                	sd	s0,64(sp)
ffffffffc0200940:	fc26                	sd	s1,56(sp)
ffffffffc0200942:	f44e                	sd	s3,40(sp)
ffffffffc0200944:	f052                	sd	s4,32(sp)
ffffffffc0200946:	ec56                	sd	s5,24(sp)
ffffffffc0200948:	e85a                	sd	s6,16(sp)
ffffffffc020094a:	e45e                	sd	s7,8(sp)
ffffffffc020094c:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020094e:	2d278363          	beq	a5,s2,ffffffffc0200c14 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200952:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200956:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200958:	8b05                	andi	a4,a4,1
ffffffffc020095a:	2c070163          	beqz	a4,ffffffffc0200c1c <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc020095e:	4401                	li	s0,0
ffffffffc0200960:	4481                	li	s1,0
ffffffffc0200962:	a031                	j	ffffffffc020096e <best_fit_check+0x42>
ffffffffc0200964:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200968:	8b09                	andi	a4,a4,2
ffffffffc020096a:	2a070963          	beqz	a4,ffffffffc0200c1c <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc020096e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200972:	679c                	ld	a5,8(a5)
ffffffffc0200974:	2485                	addiw	s1,s1,1
ffffffffc0200976:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200978:	ff2796e3          	bne	a5,s2,ffffffffc0200964 <best_fit_check+0x38>
ffffffffc020097c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020097e:	1f7000ef          	jal	ra,ffffffffc0201374 <nr_free_pages>
ffffffffc0200982:	37351d63          	bne	a0,s3,ffffffffc0200cfc <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200986:	4505                	li	a0,1
ffffffffc0200988:	163000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc020098c:	8a2a                	mv	s4,a0
ffffffffc020098e:	3a050763          	beqz	a0,ffffffffc0200d3c <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200992:	4505                	li	a0,1
ffffffffc0200994:	157000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200998:	89aa                	mv	s3,a0
ffffffffc020099a:	38050163          	beqz	a0,ffffffffc0200d1c <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020099e:	4505                	li	a0,1
ffffffffc02009a0:	14b000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc02009a4:	8aaa                	mv	s5,a0
ffffffffc02009a6:	30050b63          	beqz	a0,ffffffffc0200cbc <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02009aa:	293a0963          	beq	s4,s3,ffffffffc0200c3c <best_fit_check+0x310>
ffffffffc02009ae:	28aa0763          	beq	s4,a0,ffffffffc0200c3c <best_fit_check+0x310>
ffffffffc02009b2:	28a98563          	beq	s3,a0,ffffffffc0200c3c <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02009b6:	000a2783          	lw	a5,0(s4)
ffffffffc02009ba:	2a079163          	bnez	a5,ffffffffc0200c5c <best_fit_check+0x330>
ffffffffc02009be:	0009a783          	lw	a5,0(s3)
ffffffffc02009c2:	28079d63          	bnez	a5,ffffffffc0200c5c <best_fit_check+0x330>
ffffffffc02009c6:	411c                	lw	a5,0(a0)
ffffffffc02009c8:	28079a63          	bnez	a5,ffffffffc0200c5c <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009cc:	00006797          	auipc	a5,0x6
ffffffffc02009d0:	aac78793          	addi	a5,a5,-1364 # ffffffffc0206478 <pages>
ffffffffc02009d4:	639c                	ld	a5,0(a5)
ffffffffc02009d6:	00002717          	auipc	a4,0x2
ffffffffc02009da:	8aa70713          	addi	a4,a4,-1878 # ffffffffc0202280 <commands+0x650>
ffffffffc02009de:	630c                	ld	a1,0(a4)
ffffffffc02009e0:	40fa0733          	sub	a4,s4,a5
ffffffffc02009e4:	870d                	srai	a4,a4,0x3
ffffffffc02009e6:	02b70733          	mul	a4,a4,a1
ffffffffc02009ea:	00002697          	auipc	a3,0x2
ffffffffc02009ee:	f5668693          	addi	a3,a3,-170 # ffffffffc0202940 <nbase>
ffffffffc02009f2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009f4:	00006697          	auipc	a3,0x6
ffffffffc02009f8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0206428 <npage>
ffffffffc02009fc:	6294                	ld	a3,0(a3)
ffffffffc02009fe:	06b2                	slli	a3,a3,0xc
ffffffffc0200a00:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a02:	0732                	slli	a4,a4,0xc
ffffffffc0200a04:	26d77c63          	bleu	a3,a4,ffffffffc0200c7c <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a08:	40f98733          	sub	a4,s3,a5
ffffffffc0200a0c:	870d                	srai	a4,a4,0x3
ffffffffc0200a0e:	02b70733          	mul	a4,a4,a1
ffffffffc0200a12:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a14:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a16:	42d77363          	bleu	a3,a4,ffffffffc0200e3c <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a1a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a1e:	878d                	srai	a5,a5,0x3
ffffffffc0200a20:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a24:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a26:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a28:	3ed7fa63          	bleu	a3,a5,ffffffffc0200e1c <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a2c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a2e:	00093c03          	ld	s8,0(s2)
ffffffffc0200a32:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a36:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a3a:	00006797          	auipc	a5,0x6
ffffffffc0200a3e:	a127bb23          	sd	s2,-1514(a5) # ffffffffc0206450 <free_area+0x8>
ffffffffc0200a42:	00006797          	auipc	a5,0x6
ffffffffc0200a46:	a127b323          	sd	s2,-1530(a5) # ffffffffc0206448 <free_area>
    nr_free = 0;
ffffffffc0200a4a:	00006797          	auipc	a5,0x6
ffffffffc0200a4e:	a007a723          	sw	zero,-1522(a5) # ffffffffc0206458 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a52:	099000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200a56:	3a051363          	bnez	a0,ffffffffc0200dfc <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a5a:	4585                	li	a1,1
ffffffffc0200a5c:	8552                	mv	a0,s4
ffffffffc0200a5e:	0d1000ef          	jal	ra,ffffffffc020132e <free_pages>
    free_page(p1);
ffffffffc0200a62:	4585                	li	a1,1
ffffffffc0200a64:	854e                	mv	a0,s3
ffffffffc0200a66:	0c9000ef          	jal	ra,ffffffffc020132e <free_pages>
    free_page(p2);
ffffffffc0200a6a:	4585                	li	a1,1
ffffffffc0200a6c:	8556                	mv	a0,s5
ffffffffc0200a6e:	0c1000ef          	jal	ra,ffffffffc020132e <free_pages>
    assert(nr_free == 3);
ffffffffc0200a72:	01092703          	lw	a4,16(s2)
ffffffffc0200a76:	478d                	li	a5,3
ffffffffc0200a78:	36f71263          	bne	a4,a5,ffffffffc0200ddc <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a7c:	4505                	li	a0,1
ffffffffc0200a7e:	06d000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200a82:	89aa                	mv	s3,a0
ffffffffc0200a84:	32050c63          	beqz	a0,ffffffffc0200dbc <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a88:	4505                	li	a0,1
ffffffffc0200a8a:	061000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200a8e:	8aaa                	mv	s5,a0
ffffffffc0200a90:	30050663          	beqz	a0,ffffffffc0200d9c <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a94:	4505                	li	a0,1
ffffffffc0200a96:	055000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200a9a:	8a2a                	mv	s4,a0
ffffffffc0200a9c:	2e050063          	beqz	a0,ffffffffc0200d7c <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200aa0:	4505                	li	a0,1
ffffffffc0200aa2:	049000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200aa6:	2a051b63          	bnez	a0,ffffffffc0200d5c <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200aaa:	4585                	li	a1,1
ffffffffc0200aac:	854e                	mv	a0,s3
ffffffffc0200aae:	081000ef          	jal	ra,ffffffffc020132e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ab2:	00893783          	ld	a5,8(s2)
ffffffffc0200ab6:	1f278363          	beq	a5,s2,ffffffffc0200c9c <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200aba:	4505                	li	a0,1
ffffffffc0200abc:	02f000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200ac0:	54a99e63          	bne	s3,a0,ffffffffc020101c <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200ac4:	4505                	li	a0,1
ffffffffc0200ac6:	025000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200aca:	52051963          	bnez	a0,ffffffffc0200ffc <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200ace:	01092783          	lw	a5,16(s2)
ffffffffc0200ad2:	50079563          	bnez	a5,ffffffffc0200fdc <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200ad6:	854e                	mv	a0,s3
ffffffffc0200ad8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ada:	00006797          	auipc	a5,0x6
ffffffffc0200ade:	9787b723          	sd	s8,-1682(a5) # ffffffffc0206448 <free_area>
ffffffffc0200ae2:	00006797          	auipc	a5,0x6
ffffffffc0200ae6:	9777b723          	sd	s7,-1682(a5) # ffffffffc0206450 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200aea:	00006797          	auipc	a5,0x6
ffffffffc0200aee:	9767a723          	sw	s6,-1682(a5) # ffffffffc0206458 <free_area+0x10>
    free_page(p);
ffffffffc0200af2:	03d000ef          	jal	ra,ffffffffc020132e <free_pages>
    free_page(p1);
ffffffffc0200af6:	4585                	li	a1,1
ffffffffc0200af8:	8556                	mv	a0,s5
ffffffffc0200afa:	035000ef          	jal	ra,ffffffffc020132e <free_pages>
    free_page(p2);
ffffffffc0200afe:	4585                	li	a1,1
ffffffffc0200b00:	8552                	mv	a0,s4
ffffffffc0200b02:	02d000ef          	jal	ra,ffffffffc020132e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b06:	4515                	li	a0,5
ffffffffc0200b08:	7e2000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200b0c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200b0e:	4a050763          	beqz	a0,ffffffffc0200fbc <best_fit_check+0x690>
ffffffffc0200b12:	651c                	ld	a5,8(a0)
ffffffffc0200b14:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b16:	8b85                	andi	a5,a5,1
ffffffffc0200b18:	48079263          	bnez	a5,ffffffffc0200f9c <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b1e:	00093b03          	ld	s6,0(s2)
ffffffffc0200b22:	00893a83          	ld	s5,8(s2)
ffffffffc0200b26:	00006797          	auipc	a5,0x6
ffffffffc0200b2a:	9327b123          	sd	s2,-1758(a5) # ffffffffc0206448 <free_area>
ffffffffc0200b2e:	00006797          	auipc	a5,0x6
ffffffffc0200b32:	9327b123          	sd	s2,-1758(a5) # ffffffffc0206450 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b36:	7b4000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200b3a:	44051163          	bnez	a0,ffffffffc0200f7c <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b3e:	4589                	li	a1,2
ffffffffc0200b40:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b44:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b48:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b4c:	00006797          	auipc	a5,0x6
ffffffffc0200b50:	9007a623          	sw	zero,-1780(a5) # ffffffffc0206458 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b54:	7da000ef          	jal	ra,ffffffffc020132e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b58:	8562                	mv	a0,s8
ffffffffc0200b5a:	4585                	li	a1,1
ffffffffc0200b5c:	7d2000ef          	jal	ra,ffffffffc020132e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b60:	4511                	li	a0,4
ffffffffc0200b62:	788000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200b66:	3e051b63          	bnez	a0,ffffffffc0200f5c <best_fit_check+0x630>
ffffffffc0200b6a:	0309b783          	ld	a5,48(s3)
ffffffffc0200b6e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b70:	8b85                	andi	a5,a5,1
ffffffffc0200b72:	3c078563          	beqz	a5,ffffffffc0200f3c <best_fit_check+0x610>
ffffffffc0200b76:	0389a703          	lw	a4,56(s3)
ffffffffc0200b7a:	4789                	li	a5,2
ffffffffc0200b7c:	3cf71063          	bne	a4,a5,ffffffffc0200f3c <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b80:	4505                	li	a0,1
ffffffffc0200b82:	768000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200b86:	8a2a                	mv	s4,a0
ffffffffc0200b88:	38050a63          	beqz	a0,ffffffffc0200f1c <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b8c:	4509                	li	a0,2
ffffffffc0200b8e:	75c000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200b92:	36050563          	beqz	a0,ffffffffc0200efc <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b96:	354c1363          	bne	s8,s4,ffffffffc0200edc <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b9a:	854e                	mv	a0,s3
ffffffffc0200b9c:	4595                	li	a1,5
ffffffffc0200b9e:	790000ef          	jal	ra,ffffffffc020132e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ba2:	4515                	li	a0,5
ffffffffc0200ba4:	746000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200ba8:	89aa                	mv	s3,a0
ffffffffc0200baa:	30050963          	beqz	a0,ffffffffc0200ebc <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200bae:	4505                	li	a0,1
ffffffffc0200bb0:	73a000ef          	jal	ra,ffffffffc02012ea <alloc_pages>
ffffffffc0200bb4:	2e051463          	bnez	a0,ffffffffc0200e9c <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200bb8:	01092783          	lw	a5,16(s2)
ffffffffc0200bbc:	2c079063          	bnez	a5,ffffffffc0200e7c <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bc0:	4595                	li	a1,5
ffffffffc0200bc2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bc4:	00006797          	auipc	a5,0x6
ffffffffc0200bc8:	8977aa23          	sw	s7,-1900(a5) # ffffffffc0206458 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bcc:	00006797          	auipc	a5,0x6
ffffffffc0200bd0:	8767be23          	sd	s6,-1924(a5) # ffffffffc0206448 <free_area>
ffffffffc0200bd4:	00006797          	auipc	a5,0x6
ffffffffc0200bd8:	8757be23          	sd	s5,-1924(a5) # ffffffffc0206450 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bdc:	752000ef          	jal	ra,ffffffffc020132e <free_pages>
    return listelm->next;
ffffffffc0200be0:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200be4:	01278963          	beq	a5,s2,ffffffffc0200bf6 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200be8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bec:	679c                	ld	a5,8(a5)
ffffffffc0200bee:	34fd                	addiw	s1,s1,-1
ffffffffc0200bf0:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bf2:	ff279be3          	bne	a5,s2,ffffffffc0200be8 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200bf6:	26049363          	bnez	s1,ffffffffc0200e5c <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200bfa:	e06d                	bnez	s0,ffffffffc0200cdc <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200bfc:	60a6                	ld	ra,72(sp)
ffffffffc0200bfe:	6406                	ld	s0,64(sp)
ffffffffc0200c00:	74e2                	ld	s1,56(sp)
ffffffffc0200c02:	7942                	ld	s2,48(sp)
ffffffffc0200c04:	79a2                	ld	s3,40(sp)
ffffffffc0200c06:	7a02                	ld	s4,32(sp)
ffffffffc0200c08:	6ae2                	ld	s5,24(sp)
ffffffffc0200c0a:	6b42                	ld	s6,16(sp)
ffffffffc0200c0c:	6ba2                	ld	s7,8(sp)
ffffffffc0200c0e:	6c02                	ld	s8,0(sp)
ffffffffc0200c10:	6161                	addi	sp,sp,80
ffffffffc0200c12:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c14:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c16:	4401                	li	s0,0
ffffffffc0200c18:	4481                	li	s1,0
ffffffffc0200c1a:	b395                	j	ffffffffc020097e <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c1c:	00001697          	auipc	a3,0x1
ffffffffc0200c20:	66c68693          	addi	a3,a3,1644 # ffffffffc0202288 <commands+0x658>
ffffffffc0200c24:	00001617          	auipc	a2,0x1
ffffffffc0200c28:	62c60613          	addi	a2,a2,1580 # ffffffffc0202250 <commands+0x620>
ffffffffc0200c2c:	10b00593          	li	a1,267
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	63850513          	addi	a0,a0,1592 # ffffffffc0202268 <commands+0x638>
ffffffffc0200c38:	f74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c3c:	00001697          	auipc	a3,0x1
ffffffffc0200c40:	6dc68693          	addi	a3,a3,1756 # ffffffffc0202318 <commands+0x6e8>
ffffffffc0200c44:	00001617          	auipc	a2,0x1
ffffffffc0200c48:	60c60613          	addi	a2,a2,1548 # ffffffffc0202250 <commands+0x620>
ffffffffc0200c4c:	0d700593          	li	a1,215
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	61850513          	addi	a0,a0,1560 # ffffffffc0202268 <commands+0x638>
ffffffffc0200c58:	f54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c5c:	00001697          	auipc	a3,0x1
ffffffffc0200c60:	6e468693          	addi	a3,a3,1764 # ffffffffc0202340 <commands+0x710>
ffffffffc0200c64:	00001617          	auipc	a2,0x1
ffffffffc0200c68:	5ec60613          	addi	a2,a2,1516 # ffffffffc0202250 <commands+0x620>
ffffffffc0200c6c:	0d800593          	li	a1,216
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	5f850513          	addi	a0,a0,1528 # ffffffffc0202268 <commands+0x638>
ffffffffc0200c78:	f34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c7c:	00001697          	auipc	a3,0x1
ffffffffc0200c80:	70468693          	addi	a3,a3,1796 # ffffffffc0202380 <commands+0x750>
ffffffffc0200c84:	00001617          	auipc	a2,0x1
ffffffffc0200c88:	5cc60613          	addi	a2,a2,1484 # ffffffffc0202250 <commands+0x620>
ffffffffc0200c8c:	0da00593          	li	a1,218
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	5d850513          	addi	a0,a0,1496 # ffffffffc0202268 <commands+0x638>
ffffffffc0200c98:	f14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c9c:	00001697          	auipc	a3,0x1
ffffffffc0200ca0:	76c68693          	addi	a3,a3,1900 # ffffffffc0202408 <commands+0x7d8>
ffffffffc0200ca4:	00001617          	auipc	a2,0x1
ffffffffc0200ca8:	5ac60613          	addi	a2,a2,1452 # ffffffffc0202250 <commands+0x620>
ffffffffc0200cac:	0f300593          	li	a1,243
ffffffffc0200cb0:	00001517          	auipc	a0,0x1
ffffffffc0200cb4:	5b850513          	addi	a0,a0,1464 # ffffffffc0202268 <commands+0x638>
ffffffffc0200cb8:	ef4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cbc:	00001697          	auipc	a3,0x1
ffffffffc0200cc0:	63c68693          	addi	a3,a3,1596 # ffffffffc02022f8 <commands+0x6c8>
ffffffffc0200cc4:	00001617          	auipc	a2,0x1
ffffffffc0200cc8:	58c60613          	addi	a2,a2,1420 # ffffffffc0202250 <commands+0x620>
ffffffffc0200ccc:	0d500593          	li	a1,213
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	59850513          	addi	a0,a0,1432 # ffffffffc0202268 <commands+0x638>
ffffffffc0200cd8:	ed4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200cdc:	00002697          	auipc	a3,0x2
ffffffffc0200ce0:	85c68693          	addi	a3,a3,-1956 # ffffffffc0202538 <commands+0x908>
ffffffffc0200ce4:	00001617          	auipc	a2,0x1
ffffffffc0200ce8:	56c60613          	addi	a2,a2,1388 # ffffffffc0202250 <commands+0x620>
ffffffffc0200cec:	14d00593          	li	a1,333
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	57850513          	addi	a0,a0,1400 # ffffffffc0202268 <commands+0x638>
ffffffffc0200cf8:	eb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200cfc:	00001697          	auipc	a3,0x1
ffffffffc0200d00:	59c68693          	addi	a3,a3,1436 # ffffffffc0202298 <commands+0x668>
ffffffffc0200d04:	00001617          	auipc	a2,0x1
ffffffffc0200d08:	54c60613          	addi	a2,a2,1356 # ffffffffc0202250 <commands+0x620>
ffffffffc0200d0c:	10e00593          	li	a1,270
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	55850513          	addi	a0,a0,1368 # ffffffffc0202268 <commands+0x638>
ffffffffc0200d18:	e94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d1c:	00001697          	auipc	a3,0x1
ffffffffc0200d20:	5bc68693          	addi	a3,a3,1468 # ffffffffc02022d8 <commands+0x6a8>
ffffffffc0200d24:	00001617          	auipc	a2,0x1
ffffffffc0200d28:	52c60613          	addi	a2,a2,1324 # ffffffffc0202250 <commands+0x620>
ffffffffc0200d2c:	0d400593          	li	a1,212
ffffffffc0200d30:	00001517          	auipc	a0,0x1
ffffffffc0200d34:	53850513          	addi	a0,a0,1336 # ffffffffc0202268 <commands+0x638>
ffffffffc0200d38:	e74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	57c68693          	addi	a3,a3,1404 # ffffffffc02022b8 <commands+0x688>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	50c60613          	addi	a2,a2,1292 # ffffffffc0202250 <commands+0x620>
ffffffffc0200d4c:	0d300593          	li	a1,211
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	51850513          	addi	a0,a0,1304 # ffffffffc0202268 <commands+0x638>
ffffffffc0200d58:	e54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d5c:	00001697          	auipc	a3,0x1
ffffffffc0200d60:	68468693          	addi	a3,a3,1668 # ffffffffc02023e0 <commands+0x7b0>
ffffffffc0200d64:	00001617          	auipc	a2,0x1
ffffffffc0200d68:	4ec60613          	addi	a2,a2,1260 # ffffffffc0202250 <commands+0x620>
ffffffffc0200d6c:	0f000593          	li	a1,240
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	4f850513          	addi	a0,a0,1272 # ffffffffc0202268 <commands+0x638>
ffffffffc0200d78:	e34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	57c68693          	addi	a3,a3,1404 # ffffffffc02022f8 <commands+0x6c8>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	4cc60613          	addi	a2,a2,1228 # ffffffffc0202250 <commands+0x620>
ffffffffc0200d8c:	0ee00593          	li	a1,238
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	4d850513          	addi	a0,a0,1240 # ffffffffc0202268 <commands+0x638>
ffffffffc0200d98:	e14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	53c68693          	addi	a3,a3,1340 # ffffffffc02022d8 <commands+0x6a8>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	4ac60613          	addi	a2,a2,1196 # ffffffffc0202250 <commands+0x620>
ffffffffc0200dac:	0ed00593          	li	a1,237
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	4b850513          	addi	a0,a0,1208 # ffffffffc0202268 <commands+0x638>
ffffffffc0200db8:	df4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	4fc68693          	addi	a3,a3,1276 # ffffffffc02022b8 <commands+0x688>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	48c60613          	addi	a2,a2,1164 # ffffffffc0202250 <commands+0x620>
ffffffffc0200dcc:	0ec00593          	li	a1,236
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	49850513          	addi	a0,a0,1176 # ffffffffc0202268 <commands+0x638>
ffffffffc0200dd8:	dd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	61c68693          	addi	a3,a3,1564 # ffffffffc02023f8 <commands+0x7c8>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	46c60613          	addi	a2,a2,1132 # ffffffffc0202250 <commands+0x620>
ffffffffc0200dec:	0ea00593          	li	a1,234
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	47850513          	addi	a0,a0,1144 # ffffffffc0202268 <commands+0x638>
ffffffffc0200df8:	db4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	5e468693          	addi	a3,a3,1508 # ffffffffc02023e0 <commands+0x7b0>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	44c60613          	addi	a2,a2,1100 # ffffffffc0202250 <commands+0x620>
ffffffffc0200e0c:	0e500593          	li	a1,229
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	45850513          	addi	a0,a0,1112 # ffffffffc0202268 <commands+0x638>
ffffffffc0200e18:	d94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	5a468693          	addi	a3,a3,1444 # ffffffffc02023c0 <commands+0x790>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	42c60613          	addi	a2,a2,1068 # ffffffffc0202250 <commands+0x620>
ffffffffc0200e2c:	0dc00593          	li	a1,220
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	43850513          	addi	a0,a0,1080 # ffffffffc0202268 <commands+0x638>
ffffffffc0200e38:	d74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	56468693          	addi	a3,a3,1380 # ffffffffc02023a0 <commands+0x770>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	40c60613          	addi	a2,a2,1036 # ffffffffc0202250 <commands+0x620>
ffffffffc0200e4c:	0db00593          	li	a1,219
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	41850513          	addi	a0,a0,1048 # ffffffffc0202268 <commands+0x638>
ffffffffc0200e58:	d54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202528 <commands+0x8f8>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	3ec60613          	addi	a2,a2,1004 # ffffffffc0202250 <commands+0x620>
ffffffffc0200e6c:	14c00593          	li	a1,332
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	3f850513          	addi	a0,a0,1016 # ffffffffc0202268 <commands+0x638>
ffffffffc0200e78:	d34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7c:	00001697          	auipc	a3,0x1
ffffffffc0200e80:	5c468693          	addi	a3,a3,1476 # ffffffffc0202440 <commands+0x810>
ffffffffc0200e84:	00001617          	auipc	a2,0x1
ffffffffc0200e88:	3cc60613          	addi	a2,a2,972 # ffffffffc0202250 <commands+0x620>
ffffffffc0200e8c:	14100593          	li	a1,321
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	3d850513          	addi	a0,a0,984 # ffffffffc0202268 <commands+0x638>
ffffffffc0200e98:	d14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9c:	00001697          	auipc	a3,0x1
ffffffffc0200ea0:	54468693          	addi	a3,a3,1348 # ffffffffc02023e0 <commands+0x7b0>
ffffffffc0200ea4:	00001617          	auipc	a2,0x1
ffffffffc0200ea8:	3ac60613          	addi	a2,a2,940 # ffffffffc0202250 <commands+0x620>
ffffffffc0200eac:	13b00593          	li	a1,315
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	3b850513          	addi	a0,a0,952 # ffffffffc0202268 <commands+0x638>
ffffffffc0200eb8:	cf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ebc:	00001697          	auipc	a3,0x1
ffffffffc0200ec0:	64c68693          	addi	a3,a3,1612 # ffffffffc0202508 <commands+0x8d8>
ffffffffc0200ec4:	00001617          	auipc	a2,0x1
ffffffffc0200ec8:	38c60613          	addi	a2,a2,908 # ffffffffc0202250 <commands+0x620>
ffffffffc0200ecc:	13a00593          	li	a1,314
ffffffffc0200ed0:	00001517          	auipc	a0,0x1
ffffffffc0200ed4:	39850513          	addi	a0,a0,920 # ffffffffc0202268 <commands+0x638>
ffffffffc0200ed8:	cd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200edc:	00001697          	auipc	a3,0x1
ffffffffc0200ee0:	61c68693          	addi	a3,a3,1564 # ffffffffc02024f8 <commands+0x8c8>
ffffffffc0200ee4:	00001617          	auipc	a2,0x1
ffffffffc0200ee8:	36c60613          	addi	a2,a2,876 # ffffffffc0202250 <commands+0x620>
ffffffffc0200eec:	13200593          	li	a1,306
ffffffffc0200ef0:	00001517          	auipc	a0,0x1
ffffffffc0200ef4:	37850513          	addi	a0,a0,888 # ffffffffc0202268 <commands+0x638>
ffffffffc0200ef8:	cb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200efc:	00001697          	auipc	a3,0x1
ffffffffc0200f00:	5e468693          	addi	a3,a3,1508 # ffffffffc02024e0 <commands+0x8b0>
ffffffffc0200f04:	00001617          	auipc	a2,0x1
ffffffffc0200f08:	34c60613          	addi	a2,a2,844 # ffffffffc0202250 <commands+0x620>
ffffffffc0200f0c:	13100593          	li	a1,305
ffffffffc0200f10:	00001517          	auipc	a0,0x1
ffffffffc0200f14:	35850513          	addi	a0,a0,856 # ffffffffc0202268 <commands+0x638>
ffffffffc0200f18:	c94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f1c:	00001697          	auipc	a3,0x1
ffffffffc0200f20:	5a468693          	addi	a3,a3,1444 # ffffffffc02024c0 <commands+0x890>
ffffffffc0200f24:	00001617          	auipc	a2,0x1
ffffffffc0200f28:	32c60613          	addi	a2,a2,812 # ffffffffc0202250 <commands+0x620>
ffffffffc0200f2c:	13000593          	li	a1,304
ffffffffc0200f30:	00001517          	auipc	a0,0x1
ffffffffc0200f34:	33850513          	addi	a0,a0,824 # ffffffffc0202268 <commands+0x638>
ffffffffc0200f38:	c74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f3c:	00001697          	auipc	a3,0x1
ffffffffc0200f40:	55468693          	addi	a3,a3,1364 # ffffffffc0202490 <commands+0x860>
ffffffffc0200f44:	00001617          	auipc	a2,0x1
ffffffffc0200f48:	30c60613          	addi	a2,a2,780 # ffffffffc0202250 <commands+0x620>
ffffffffc0200f4c:	12e00593          	li	a1,302
ffffffffc0200f50:	00001517          	auipc	a0,0x1
ffffffffc0200f54:	31850513          	addi	a0,a0,792 # ffffffffc0202268 <commands+0x638>
ffffffffc0200f58:	c54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f5c:	00001697          	auipc	a3,0x1
ffffffffc0200f60:	51c68693          	addi	a3,a3,1308 # ffffffffc0202478 <commands+0x848>
ffffffffc0200f64:	00001617          	auipc	a2,0x1
ffffffffc0200f68:	2ec60613          	addi	a2,a2,748 # ffffffffc0202250 <commands+0x620>
ffffffffc0200f6c:	12d00593          	li	a1,301
ffffffffc0200f70:	00001517          	auipc	a0,0x1
ffffffffc0200f74:	2f850513          	addi	a0,a0,760 # ffffffffc0202268 <commands+0x638>
ffffffffc0200f78:	c34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f7c:	00001697          	auipc	a3,0x1
ffffffffc0200f80:	46468693          	addi	a3,a3,1124 # ffffffffc02023e0 <commands+0x7b0>
ffffffffc0200f84:	00001617          	auipc	a2,0x1
ffffffffc0200f88:	2cc60613          	addi	a2,a2,716 # ffffffffc0202250 <commands+0x620>
ffffffffc0200f8c:	12100593          	li	a1,289
ffffffffc0200f90:	00001517          	auipc	a0,0x1
ffffffffc0200f94:	2d850513          	addi	a0,a0,728 # ffffffffc0202268 <commands+0x638>
ffffffffc0200f98:	c14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f9c:	00001697          	auipc	a3,0x1
ffffffffc0200fa0:	4c468693          	addi	a3,a3,1220 # ffffffffc0202460 <commands+0x830>
ffffffffc0200fa4:	00001617          	auipc	a2,0x1
ffffffffc0200fa8:	2ac60613          	addi	a2,a2,684 # ffffffffc0202250 <commands+0x620>
ffffffffc0200fac:	11800593          	li	a1,280
ffffffffc0200fb0:	00001517          	auipc	a0,0x1
ffffffffc0200fb4:	2b850513          	addi	a0,a0,696 # ffffffffc0202268 <commands+0x638>
ffffffffc0200fb8:	bf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200fbc:	00001697          	auipc	a3,0x1
ffffffffc0200fc0:	49468693          	addi	a3,a3,1172 # ffffffffc0202450 <commands+0x820>
ffffffffc0200fc4:	00001617          	auipc	a2,0x1
ffffffffc0200fc8:	28c60613          	addi	a2,a2,652 # ffffffffc0202250 <commands+0x620>
ffffffffc0200fcc:	11700593          	li	a1,279
ffffffffc0200fd0:	00001517          	auipc	a0,0x1
ffffffffc0200fd4:	29850513          	addi	a0,a0,664 # ffffffffc0202268 <commands+0x638>
ffffffffc0200fd8:	bd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200fdc:	00001697          	auipc	a3,0x1
ffffffffc0200fe0:	46468693          	addi	a3,a3,1124 # ffffffffc0202440 <commands+0x810>
ffffffffc0200fe4:	00001617          	auipc	a2,0x1
ffffffffc0200fe8:	26c60613          	addi	a2,a2,620 # ffffffffc0202250 <commands+0x620>
ffffffffc0200fec:	0f900593          	li	a1,249
ffffffffc0200ff0:	00001517          	auipc	a0,0x1
ffffffffc0200ff4:	27850513          	addi	a0,a0,632 # ffffffffc0202268 <commands+0x638>
ffffffffc0200ff8:	bb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ffc:	00001697          	auipc	a3,0x1
ffffffffc0201000:	3e468693          	addi	a3,a3,996 # ffffffffc02023e0 <commands+0x7b0>
ffffffffc0201004:	00001617          	auipc	a2,0x1
ffffffffc0201008:	24c60613          	addi	a2,a2,588 # ffffffffc0202250 <commands+0x620>
ffffffffc020100c:	0f700593          	li	a1,247
ffffffffc0201010:	00001517          	auipc	a0,0x1
ffffffffc0201014:	25850513          	addi	a0,a0,600 # ffffffffc0202268 <commands+0x638>
ffffffffc0201018:	b94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020101c:	00001697          	auipc	a3,0x1
ffffffffc0201020:	40468693          	addi	a3,a3,1028 # ffffffffc0202420 <commands+0x7f0>
ffffffffc0201024:	00001617          	auipc	a2,0x1
ffffffffc0201028:	22c60613          	addi	a2,a2,556 # ffffffffc0202250 <commands+0x620>
ffffffffc020102c:	0f600593          	li	a1,246
ffffffffc0201030:	00001517          	auipc	a0,0x1
ffffffffc0201034:	23850513          	addi	a0,a0,568 # ffffffffc0202268 <commands+0x638>
ffffffffc0201038:	b74ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020103c <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020103c:	1141                	addi	sp,sp,-16
ffffffffc020103e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201040:	18058063          	beqz	a1,ffffffffc02011c0 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201044:	00259693          	slli	a3,a1,0x2
ffffffffc0201048:	96ae                	add	a3,a3,a1
ffffffffc020104a:	068e                	slli	a3,a3,0x3
ffffffffc020104c:	96aa                	add	a3,a3,a0
ffffffffc020104e:	02d50d63          	beq	a0,a3,ffffffffc0201088 <best_fit_free_pages+0x4c>
ffffffffc0201052:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201054:	8b85                	andi	a5,a5,1
ffffffffc0201056:	14079563          	bnez	a5,ffffffffc02011a0 <best_fit_free_pages+0x164>
ffffffffc020105a:	651c                	ld	a5,8(a0)
ffffffffc020105c:	8385                	srli	a5,a5,0x1
ffffffffc020105e:	8b85                	andi	a5,a5,1
ffffffffc0201060:	14079063          	bnez	a5,ffffffffc02011a0 <best_fit_free_pages+0x164>
ffffffffc0201064:	87aa                	mv	a5,a0
ffffffffc0201066:	a809                	j	ffffffffc0201078 <best_fit_free_pages+0x3c>
ffffffffc0201068:	6798                	ld	a4,8(a5)
ffffffffc020106a:	8b05                	andi	a4,a4,1
ffffffffc020106c:	12071a63          	bnez	a4,ffffffffc02011a0 <best_fit_free_pages+0x164>
ffffffffc0201070:	6798                	ld	a4,8(a5)
ffffffffc0201072:	8b09                	andi	a4,a4,2
ffffffffc0201074:	12071663          	bnez	a4,ffffffffc02011a0 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201078:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020107c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201080:	02878793          	addi	a5,a5,40
ffffffffc0201084:	fed792e3          	bne	a5,a3,ffffffffc0201068 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201088:	2581                	sext.w	a1,a1
ffffffffc020108a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020108c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201090:	4789                	li	a5,2
ffffffffc0201092:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201096:	00005697          	auipc	a3,0x5
ffffffffc020109a:	3b268693          	addi	a3,a3,946 # ffffffffc0206448 <free_area>
ffffffffc020109e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02010a0:	669c                	ld	a5,8(a3)
ffffffffc02010a2:	9db9                	addw	a1,a1,a4
ffffffffc02010a4:	00005717          	auipc	a4,0x5
ffffffffc02010a8:	3ab72a23          	sw	a1,948(a4) # ffffffffc0206458 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02010ac:	08d78f63          	beq	a5,a3,ffffffffc020114a <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02010b0:	fe878713          	addi	a4,a5,-24
ffffffffc02010b4:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02010b6:	4801                	li	a6,0
ffffffffc02010b8:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010bc:	00e56a63          	bltu	a0,a4,ffffffffc02010d0 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02010c0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010c2:	02d70563          	beq	a4,a3,ffffffffc02010ec <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010c6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010c8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010cc:	fee57ae3          	bleu	a4,a0,ffffffffc02010c0 <best_fit_free_pages+0x84>
ffffffffc02010d0:	00080663          	beqz	a6,ffffffffc02010dc <best_fit_free_pages+0xa0>
ffffffffc02010d4:	00005817          	auipc	a6,0x5
ffffffffc02010d8:	36b83a23          	sd	a1,884(a6) # ffffffffc0206448 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010dc:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010de:	e390                	sd	a2,0(a5)
ffffffffc02010e0:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010e2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010e4:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010e6:	02d59163          	bne	a1,a3,ffffffffc0201108 <best_fit_free_pages+0xcc>
ffffffffc02010ea:	a091                	j	ffffffffc020112e <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010ec:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010ee:	f114                	sd	a3,32(a0)
ffffffffc02010f0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010f2:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010f4:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010f6:	00d70563          	beq	a4,a3,ffffffffc0201100 <best_fit_free_pages+0xc4>
ffffffffc02010fa:	4805                	li	a6,1
ffffffffc02010fc:	87ba                	mv	a5,a4
ffffffffc02010fe:	b7e9                	j	ffffffffc02010c8 <best_fit_free_pages+0x8c>
ffffffffc0201100:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201102:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201104:	02d78163          	beq	a5,a3,ffffffffc0201126 <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201108:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020110c:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc0201110:	02081713          	slli	a4,a6,0x20
ffffffffc0201114:	9301                	srli	a4,a4,0x20
ffffffffc0201116:	00271793          	slli	a5,a4,0x2
ffffffffc020111a:	97ba                	add	a5,a5,a4
ffffffffc020111c:	078e                	slli	a5,a5,0x3
ffffffffc020111e:	97b2                	add	a5,a5,a2
ffffffffc0201120:	02f50e63          	beq	a0,a5,ffffffffc020115c <best_fit_free_pages+0x120>
ffffffffc0201124:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201126:	fe878713          	addi	a4,a5,-24
ffffffffc020112a:	00d78d63          	beq	a5,a3,ffffffffc0201144 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020112e:	490c                	lw	a1,16(a0)
ffffffffc0201130:	02059613          	slli	a2,a1,0x20
ffffffffc0201134:	9201                	srli	a2,a2,0x20
ffffffffc0201136:	00261693          	slli	a3,a2,0x2
ffffffffc020113a:	96b2                	add	a3,a3,a2
ffffffffc020113c:	068e                	slli	a3,a3,0x3
ffffffffc020113e:	96aa                	add	a3,a3,a0
ffffffffc0201140:	04d70063          	beq	a4,a3,ffffffffc0201180 <best_fit_free_pages+0x144>
}
ffffffffc0201144:	60a2                	ld	ra,8(sp)
ffffffffc0201146:	0141                	addi	sp,sp,16
ffffffffc0201148:	8082                	ret
ffffffffc020114a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020114c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201150:	e398                	sd	a4,0(a5)
ffffffffc0201152:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201154:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201156:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201158:	0141                	addi	sp,sp,16
ffffffffc020115a:	8082                	ret
            p->property += base->property;
ffffffffc020115c:	491c                	lw	a5,16(a0)
ffffffffc020115e:	0107883b          	addw	a6,a5,a6
ffffffffc0201162:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201166:	57f5                	li	a5,-3
ffffffffc0201168:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020116c:	01853803          	ld	a6,24(a0)
ffffffffc0201170:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc0201172:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201174:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201178:	659c                	ld	a5,8(a1)
ffffffffc020117a:	01073023          	sd	a6,0(a4)
ffffffffc020117e:	b765                	j	ffffffffc0201126 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201180:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201184:	ff078693          	addi	a3,a5,-16
ffffffffc0201188:	9db9                	addw	a1,a1,a4
ffffffffc020118a:	c90c                	sw	a1,16(a0)
ffffffffc020118c:	5775                	li	a4,-3
ffffffffc020118e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201192:	6398                	ld	a4,0(a5)
ffffffffc0201194:	679c                	ld	a5,8(a5)
}
ffffffffc0201196:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201198:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020119a:	e398                	sd	a4,0(a5)
ffffffffc020119c:	0141                	addi	sp,sp,16
ffffffffc020119e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011a0:	00001697          	auipc	a3,0x1
ffffffffc02011a4:	3a868693          	addi	a3,a3,936 # ffffffffc0202548 <commands+0x918>
ffffffffc02011a8:	00001617          	auipc	a2,0x1
ffffffffc02011ac:	0a860613          	addi	a2,a2,168 # ffffffffc0202250 <commands+0x620>
ffffffffc02011b0:	09300593          	li	a1,147
ffffffffc02011b4:	00001517          	auipc	a0,0x1
ffffffffc02011b8:	0b450513          	addi	a0,a0,180 # ffffffffc0202268 <commands+0x638>
ffffffffc02011bc:	9f0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011c0:	00001697          	auipc	a3,0x1
ffffffffc02011c4:	08868693          	addi	a3,a3,136 # ffffffffc0202248 <commands+0x618>
ffffffffc02011c8:	00001617          	auipc	a2,0x1
ffffffffc02011cc:	08860613          	addi	a2,a2,136 # ffffffffc0202250 <commands+0x620>
ffffffffc02011d0:	09000593          	li	a1,144
ffffffffc02011d4:	00001517          	auipc	a0,0x1
ffffffffc02011d8:	09450513          	addi	a0,a0,148 # ffffffffc0202268 <commands+0x638>
ffffffffc02011dc:	9d0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011e0 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011e0:	1141                	addi	sp,sp,-16
ffffffffc02011e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011e4:	c1fd                	beqz	a1,ffffffffc02012ca <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011e6:	00259693          	slli	a3,a1,0x2
ffffffffc02011ea:	96ae                	add	a3,a3,a1
ffffffffc02011ec:	068e                	slli	a3,a3,0x3
ffffffffc02011ee:	96aa                	add	a3,a3,a0
ffffffffc02011f0:	02d50463          	beq	a0,a3,ffffffffc0201218 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011f4:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011f6:	87aa                	mv	a5,a0
ffffffffc02011f8:	8b05                	andi	a4,a4,1
ffffffffc02011fa:	e709                	bnez	a4,ffffffffc0201204 <best_fit_init_memmap+0x24>
ffffffffc02011fc:	a07d                	j	ffffffffc02012aa <best_fit_init_memmap+0xca>
ffffffffc02011fe:	6798                	ld	a4,8(a5)
ffffffffc0201200:	8b05                	andi	a4,a4,1
ffffffffc0201202:	c745                	beqz	a4,ffffffffc02012aa <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0201204:	0007a823          	sw	zero,16(a5)
ffffffffc0201208:	0007b423          	sd	zero,8(a5)
ffffffffc020120c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201210:	02878793          	addi	a5,a5,40
ffffffffc0201214:	fed795e3          	bne	a5,a3,ffffffffc02011fe <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201218:	2581                	sext.w	a1,a1
ffffffffc020121a:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020121c:	4789                	li	a5,2
ffffffffc020121e:	00850713          	addi	a4,a0,8
ffffffffc0201222:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201226:	00005697          	auipc	a3,0x5
ffffffffc020122a:	22268693          	addi	a3,a3,546 # ffffffffc0206448 <free_area>
ffffffffc020122e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201230:	669c                	ld	a5,8(a3)
ffffffffc0201232:	9db9                	addw	a1,a1,a4
ffffffffc0201234:	00005717          	auipc	a4,0x5
ffffffffc0201238:	22b72223          	sw	a1,548(a4) # ffffffffc0206458 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020123c:	04d78a63          	beq	a5,a3,ffffffffc0201290 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201240:	fe878713          	addi	a4,a5,-24
ffffffffc0201244:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201246:	4801                	li	a6,0
ffffffffc0201248:	01850613          	addi	a2,a0,24
            if(base < page){
ffffffffc020124c:	00e56a63          	bltu	a0,a4,ffffffffc0201260 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201250:	6798                	ld	a4,8(a5)
        else if (list_next(le) == &free_list) {
ffffffffc0201252:	02d70563          	beq	a4,a3,ffffffffc020127c <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201256:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201258:	fe878713          	addi	a4,a5,-24
            if(base < page){
ffffffffc020125c:	fee57ae3          	bleu	a4,a0,ffffffffc0201250 <best_fit_init_memmap+0x70>
ffffffffc0201260:	00080663          	beqz	a6,ffffffffc020126c <best_fit_init_memmap+0x8c>
ffffffffc0201264:	00005717          	auipc	a4,0x5
ffffffffc0201268:	1eb73223          	sd	a1,484(a4) # ffffffffc0206448 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020126c:	6398                	ld	a4,0(a5)
}
ffffffffc020126e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201270:	e390                	sd	a2,0(a5)
ffffffffc0201272:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201274:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201276:	ed18                	sd	a4,24(a0)
ffffffffc0201278:	0141                	addi	sp,sp,16
ffffffffc020127a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020127c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020127e:	f114                	sd	a3,32(a0)
ffffffffc0201280:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201282:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201284:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201286:	00d70e63          	beq	a4,a3,ffffffffc02012a2 <best_fit_init_memmap+0xc2>
ffffffffc020128a:	4805                	li	a6,1
ffffffffc020128c:	87ba                	mv	a5,a4
ffffffffc020128e:	b7e9                	j	ffffffffc0201258 <best_fit_init_memmap+0x78>
}
ffffffffc0201290:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201292:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201296:	e398                	sd	a4,0(a5)
ffffffffc0201298:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020129a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020129c:	ed1c                	sd	a5,24(a0)
}
ffffffffc020129e:	0141                	addi	sp,sp,16
ffffffffc02012a0:	8082                	ret
ffffffffc02012a2:	60a2                	ld	ra,8(sp)
ffffffffc02012a4:	e290                	sd	a2,0(a3)
ffffffffc02012a6:	0141                	addi	sp,sp,16
ffffffffc02012a8:	8082                	ret
        assert(PageReserved(p));
ffffffffc02012aa:	00001697          	auipc	a3,0x1
ffffffffc02012ae:	2c668693          	addi	a3,a3,710 # ffffffffc0202570 <commands+0x940>
ffffffffc02012b2:	00001617          	auipc	a2,0x1
ffffffffc02012b6:	f9e60613          	addi	a2,a2,-98 # ffffffffc0202250 <commands+0x620>
ffffffffc02012ba:	04a00593          	li	a1,74
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	faa50513          	addi	a0,a0,-86 # ffffffffc0202268 <commands+0x638>
ffffffffc02012c6:	8e6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02012ca:	00001697          	auipc	a3,0x1
ffffffffc02012ce:	f7e68693          	addi	a3,a3,-130 # ffffffffc0202248 <commands+0x618>
ffffffffc02012d2:	00001617          	auipc	a2,0x1
ffffffffc02012d6:	f7e60613          	addi	a2,a2,-130 # ffffffffc0202250 <commands+0x620>
ffffffffc02012da:	04700593          	li	a1,71
ffffffffc02012de:	00001517          	auipc	a0,0x1
ffffffffc02012e2:	f8a50513          	addi	a0,a0,-118 # ffffffffc0202268 <commands+0x638>
ffffffffc02012e6:	8c6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02012ea <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ea:	100027f3          	csrr	a5,sstatus
ffffffffc02012ee:	8b89                	andi	a5,a5,2
ffffffffc02012f0:	eb89                	bnez	a5,ffffffffc0201302 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012f2:	00005797          	auipc	a5,0x5
ffffffffc02012f6:	17678793          	addi	a5,a5,374 # ffffffffc0206468 <pmm_manager>
ffffffffc02012fa:	639c                	ld	a5,0(a5)
ffffffffc02012fc:	0187b303          	ld	t1,24(a5)
ffffffffc0201300:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201302:	1141                	addi	sp,sp,-16
ffffffffc0201304:	e406                	sd	ra,8(sp)
ffffffffc0201306:	e022                	sd	s0,0(sp)
ffffffffc0201308:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020130a:	95aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020130e:	00005797          	auipc	a5,0x5
ffffffffc0201312:	15a78793          	addi	a5,a5,346 # ffffffffc0206468 <pmm_manager>
ffffffffc0201316:	639c                	ld	a5,0(a5)
ffffffffc0201318:	8522                	mv	a0,s0
ffffffffc020131a:	6f9c                	ld	a5,24(a5)
ffffffffc020131c:	9782                	jalr	a5
ffffffffc020131e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201320:	93eff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201324:	8522                	mv	a0,s0
ffffffffc0201326:	60a2                	ld	ra,8(sp)
ffffffffc0201328:	6402                	ld	s0,0(sp)
ffffffffc020132a:	0141                	addi	sp,sp,16
ffffffffc020132c:	8082                	ret

ffffffffc020132e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020132e:	100027f3          	csrr	a5,sstatus
ffffffffc0201332:	8b89                	andi	a5,a5,2
ffffffffc0201334:	eb89                	bnez	a5,ffffffffc0201346 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201336:	00005797          	auipc	a5,0x5
ffffffffc020133a:	13278793          	addi	a5,a5,306 # ffffffffc0206468 <pmm_manager>
ffffffffc020133e:	639c                	ld	a5,0(a5)
ffffffffc0201340:	0207b303          	ld	t1,32(a5)
ffffffffc0201344:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201346:	1101                	addi	sp,sp,-32
ffffffffc0201348:	ec06                	sd	ra,24(sp)
ffffffffc020134a:	e822                	sd	s0,16(sp)
ffffffffc020134c:	e426                	sd	s1,8(sp)
ffffffffc020134e:	842a                	mv	s0,a0
ffffffffc0201350:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201352:	912ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201356:	00005797          	auipc	a5,0x5
ffffffffc020135a:	11278793          	addi	a5,a5,274 # ffffffffc0206468 <pmm_manager>
ffffffffc020135e:	639c                	ld	a5,0(a5)
ffffffffc0201360:	85a6                	mv	a1,s1
ffffffffc0201362:	8522                	mv	a0,s0
ffffffffc0201364:	739c                	ld	a5,32(a5)
ffffffffc0201366:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201368:	6442                	ld	s0,16(sp)
ffffffffc020136a:	60e2                	ld	ra,24(sp)
ffffffffc020136c:	64a2                	ld	s1,8(sp)
ffffffffc020136e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201370:	8eeff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201374 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201374:	100027f3          	csrr	a5,sstatus
ffffffffc0201378:	8b89                	andi	a5,a5,2
ffffffffc020137a:	eb89                	bnez	a5,ffffffffc020138c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020137c:	00005797          	auipc	a5,0x5
ffffffffc0201380:	0ec78793          	addi	a5,a5,236 # ffffffffc0206468 <pmm_manager>
ffffffffc0201384:	639c                	ld	a5,0(a5)
ffffffffc0201386:	0287b303          	ld	t1,40(a5)
ffffffffc020138a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020138c:	1141                	addi	sp,sp,-16
ffffffffc020138e:	e406                	sd	ra,8(sp)
ffffffffc0201390:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201392:	8d2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201396:	00005797          	auipc	a5,0x5
ffffffffc020139a:	0d278793          	addi	a5,a5,210 # ffffffffc0206468 <pmm_manager>
ffffffffc020139e:	639c                	ld	a5,0(a5)
ffffffffc02013a0:	779c                	ld	a5,40(a5)
ffffffffc02013a2:	9782                	jalr	a5
ffffffffc02013a4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02013a6:	8b8ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02013aa:	8522                	mv	a0,s0
ffffffffc02013ac:	60a2                	ld	ra,8(sp)
ffffffffc02013ae:	6402                	ld	s0,0(sp)
ffffffffc02013b0:	0141                	addi	sp,sp,16
ffffffffc02013b2:	8082                	ret

ffffffffc02013b4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013b4:	00001797          	auipc	a5,0x1
ffffffffc02013b8:	1cc78793          	addi	a5,a5,460 # ffffffffc0202580 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013bc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02013be:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013c0:	00001517          	auipc	a0,0x1
ffffffffc02013c4:	21050513          	addi	a0,a0,528 # ffffffffc02025d0 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013c8:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013ca:	00005717          	auipc	a4,0x5
ffffffffc02013ce:	08f73f23          	sd	a5,158(a4) # ffffffffc0206468 <pmm_manager>
void pmm_init(void) {
ffffffffc02013d2:	e822                	sd	s0,16(sp)
ffffffffc02013d4:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013d6:	00005417          	auipc	s0,0x5
ffffffffc02013da:	09240413          	addi	s0,s0,146 # ffffffffc0206468 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013de:	cd9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013e2:	601c                	ld	a5,0(s0)
ffffffffc02013e4:	679c                	ld	a5,8(a5)
ffffffffc02013e6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013e8:	57f5                	li	a5,-3
ffffffffc02013ea:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013ec:	00001517          	auipc	a0,0x1
ffffffffc02013f0:	1fc50513          	addi	a0,a0,508 # ffffffffc02025e8 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013f4:	00005717          	auipc	a4,0x5
ffffffffc02013f8:	06f73e23          	sd	a5,124(a4) # ffffffffc0206470 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013fc:	cbbfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201400:	46c5                	li	a3,17
ffffffffc0201402:	06ee                	slli	a3,a3,0x1b
ffffffffc0201404:	40100613          	li	a2,1025
ffffffffc0201408:	16fd                	addi	a3,a3,-1
ffffffffc020140a:	0656                	slli	a2,a2,0x15
ffffffffc020140c:	07e005b7          	lui	a1,0x7e00
ffffffffc0201410:	00001517          	auipc	a0,0x1
ffffffffc0201414:	1f050513          	addi	a0,a0,496 # ffffffffc0202600 <best_fit_pmm_manager+0x80>
ffffffffc0201418:	c9ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020141c:	777d                	lui	a4,0xfffff
ffffffffc020141e:	00006797          	auipc	a5,0x6
ffffffffc0201422:	06178793          	addi	a5,a5,97 # ffffffffc020747f <end+0xfff>
ffffffffc0201426:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201428:	00088737          	lui	a4,0x88
ffffffffc020142c:	00005697          	auipc	a3,0x5
ffffffffc0201430:	fee6be23          	sd	a4,-4(a3) # ffffffffc0206428 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201434:	4601                	li	a2,0
ffffffffc0201436:	00005717          	auipc	a4,0x5
ffffffffc020143a:	04f73123          	sd	a5,66(a4) # ffffffffc0206478 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020143e:	4681                	li	a3,0
ffffffffc0201440:	00005897          	auipc	a7,0x5
ffffffffc0201444:	fe888893          	addi	a7,a7,-24 # ffffffffc0206428 <npage>
ffffffffc0201448:	00005597          	auipc	a1,0x5
ffffffffc020144c:	03058593          	addi	a1,a1,48 # ffffffffc0206478 <pages>
ffffffffc0201450:	4805                	li	a6,1
ffffffffc0201452:	fff80537          	lui	a0,0xfff80
ffffffffc0201456:	a011                	j	ffffffffc020145a <pmm_init+0xa6>
ffffffffc0201458:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020145a:	97b2                	add	a5,a5,a2
ffffffffc020145c:	07a1                	addi	a5,a5,8
ffffffffc020145e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201462:	0008b703          	ld	a4,0(a7)
ffffffffc0201466:	0685                	addi	a3,a3,1
ffffffffc0201468:	02860613          	addi	a2,a2,40
ffffffffc020146c:	00a707b3          	add	a5,a4,a0
ffffffffc0201470:	fef6e4e3          	bltu	a3,a5,ffffffffc0201458 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201474:	6190                	ld	a2,0(a1)
ffffffffc0201476:	00271793          	slli	a5,a4,0x2
ffffffffc020147a:	97ba                	add	a5,a5,a4
ffffffffc020147c:	fec006b7          	lui	a3,0xfec00
ffffffffc0201480:	078e                	slli	a5,a5,0x3
ffffffffc0201482:	96b2                	add	a3,a3,a2
ffffffffc0201484:	96be                	add	a3,a3,a5
ffffffffc0201486:	c02007b7          	lui	a5,0xc0200
ffffffffc020148a:	08f6e863          	bltu	a3,a5,ffffffffc020151a <pmm_init+0x166>
ffffffffc020148e:	00005497          	auipc	s1,0x5
ffffffffc0201492:	fe248493          	addi	s1,s1,-30 # ffffffffc0206470 <va_pa_offset>
ffffffffc0201496:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201498:	45c5                	li	a1,17
ffffffffc020149a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020149c:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020149e:	04b6e963          	bltu	a3,a1,ffffffffc02014f0 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02014a2:	601c                	ld	a5,0(s0)
ffffffffc02014a4:	7b9c                	ld	a5,48(a5)
ffffffffc02014a6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02014a8:	00001517          	auipc	a0,0x1
ffffffffc02014ac:	1f050513          	addi	a0,a0,496 # ffffffffc0202698 <best_fit_pmm_manager+0x118>
ffffffffc02014b0:	c07fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014b4:	00004697          	auipc	a3,0x4
ffffffffc02014b8:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02014bc:	00005797          	auipc	a5,0x5
ffffffffc02014c0:	f6d7ba23          	sd	a3,-140(a5) # ffffffffc0206430 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02014c8:	06f6e563          	bltu	a3,a5,ffffffffc0201532 <pmm_init+0x17e>
ffffffffc02014cc:	609c                	ld	a5,0(s1)
}
ffffffffc02014ce:	6442                	ld	s0,16(sp)
ffffffffc02014d0:	60e2                	ld	ra,24(sp)
ffffffffc02014d2:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014d4:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014d6:	8e9d                	sub	a3,a3,a5
ffffffffc02014d8:	00005797          	auipc	a5,0x5
ffffffffc02014dc:	f8d7b423          	sd	a3,-120(a5) # ffffffffc0206460 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014e0:	00001517          	auipc	a0,0x1
ffffffffc02014e4:	1d850513          	addi	a0,a0,472 # ffffffffc02026b8 <best_fit_pmm_manager+0x138>
ffffffffc02014e8:	8636                	mv	a2,a3
}
ffffffffc02014ea:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014ec:	bcbfe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014f0:	6785                	lui	a5,0x1
ffffffffc02014f2:	17fd                	addi	a5,a5,-1
ffffffffc02014f4:	96be                	add	a3,a3,a5
ffffffffc02014f6:	77fd                	lui	a5,0xfffff
ffffffffc02014f8:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014fa:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014fe:	04e7f663          	bleu	a4,a5,ffffffffc020154a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0201502:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201504:	97aa                	add	a5,a5,a0
ffffffffc0201506:	00279513          	slli	a0,a5,0x2
ffffffffc020150a:	953e                	add	a0,a0,a5
ffffffffc020150c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020150e:	8d95                	sub	a1,a1,a3
ffffffffc0201510:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201512:	81b1                	srli	a1,a1,0xc
ffffffffc0201514:	9532                	add	a0,a0,a2
ffffffffc0201516:	9782                	jalr	a5
ffffffffc0201518:	b769                	j	ffffffffc02014a2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020151a:	00001617          	auipc	a2,0x1
ffffffffc020151e:	11660613          	addi	a2,a2,278 # ffffffffc0202630 <best_fit_pmm_manager+0xb0>
ffffffffc0201522:	06e00593          	li	a1,110
ffffffffc0201526:	00001517          	auipc	a0,0x1
ffffffffc020152a:	13250513          	addi	a0,a0,306 # ffffffffc0202658 <best_fit_pmm_manager+0xd8>
ffffffffc020152e:	e7ffe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201532:	00001617          	auipc	a2,0x1
ffffffffc0201536:	0fe60613          	addi	a2,a2,254 # ffffffffc0202630 <best_fit_pmm_manager+0xb0>
ffffffffc020153a:	08900593          	li	a1,137
ffffffffc020153e:	00001517          	auipc	a0,0x1
ffffffffc0201542:	11a50513          	addi	a0,a0,282 # ffffffffc0202658 <best_fit_pmm_manager+0xd8>
ffffffffc0201546:	e67fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020154a:	00001617          	auipc	a2,0x1
ffffffffc020154e:	11e60613          	addi	a2,a2,286 # ffffffffc0202668 <best_fit_pmm_manager+0xe8>
ffffffffc0201552:	06b00593          	li	a1,107
ffffffffc0201556:	00001517          	auipc	a0,0x1
ffffffffc020155a:	13250513          	addi	a0,a0,306 # ffffffffc0202688 <best_fit_pmm_manager+0x108>
ffffffffc020155e:	e4ffe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201562 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201562:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201566:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201568:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020156c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020156e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201572:	f022                	sd	s0,32(sp)
ffffffffc0201574:	ec26                	sd	s1,24(sp)
ffffffffc0201576:	e84a                	sd	s2,16(sp)
ffffffffc0201578:	f406                	sd	ra,40(sp)
ffffffffc020157a:	e44e                	sd	s3,8(sp)
ffffffffc020157c:	84aa                	mv	s1,a0
ffffffffc020157e:	892e                	mv	s2,a1
ffffffffc0201580:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201584:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201586:	03067e63          	bleu	a6,a2,ffffffffc02015c2 <printnum+0x60>
ffffffffc020158a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020158c:	00805763          	blez	s0,ffffffffc020159a <printnum+0x38>
ffffffffc0201590:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201592:	85ca                	mv	a1,s2
ffffffffc0201594:	854e                	mv	a0,s3
ffffffffc0201596:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201598:	fc65                	bnez	s0,ffffffffc0201590 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020159a:	1a02                	slli	s4,s4,0x20
ffffffffc020159c:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015a0:	00001797          	auipc	a5,0x1
ffffffffc02015a4:	2e878793          	addi	a5,a5,744 # ffffffffc0202888 <error_string+0x38>
ffffffffc02015a8:	9a3e                	add	s4,s4,a5
}
ffffffffc02015aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015ac:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015b0:	70a2                	ld	ra,40(sp)
ffffffffc02015b2:	69a2                	ld	s3,8(sp)
ffffffffc02015b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015b6:	85ca                	mv	a1,s2
ffffffffc02015b8:	8326                	mv	t1,s1
}
ffffffffc02015ba:	6942                	ld	s2,16(sp)
ffffffffc02015bc:	64e2                	ld	s1,24(sp)
ffffffffc02015be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015c0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02015c2:	03065633          	divu	a2,a2,a6
ffffffffc02015c6:	8722                	mv	a4,s0
ffffffffc02015c8:	f9bff0ef          	jal	ra,ffffffffc0201562 <printnum>
ffffffffc02015cc:	b7f9                	j	ffffffffc020159a <printnum+0x38>

ffffffffc02015ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02015ce:	7119                	addi	sp,sp,-128
ffffffffc02015d0:	f4a6                	sd	s1,104(sp)
ffffffffc02015d2:	f0ca                	sd	s2,96(sp)
ffffffffc02015d4:	e8d2                	sd	s4,80(sp)
ffffffffc02015d6:	e4d6                	sd	s5,72(sp)
ffffffffc02015d8:	e0da                	sd	s6,64(sp)
ffffffffc02015da:	fc5e                	sd	s7,56(sp)
ffffffffc02015dc:	f862                	sd	s8,48(sp)
ffffffffc02015de:	f06a                	sd	s10,32(sp)
ffffffffc02015e0:	fc86                	sd	ra,120(sp)
ffffffffc02015e2:	f8a2                	sd	s0,112(sp)
ffffffffc02015e4:	ecce                	sd	s3,88(sp)
ffffffffc02015e6:	f466                	sd	s9,40(sp)
ffffffffc02015e8:	ec6e                	sd	s11,24(sp)
ffffffffc02015ea:	892a                	mv	s2,a0
ffffffffc02015ec:	84ae                	mv	s1,a1
ffffffffc02015ee:	8d32                	mv	s10,a2
ffffffffc02015f0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015f2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f4:	00001a17          	auipc	s4,0x1
ffffffffc02015f8:	104a0a13          	addi	s4,s4,260 # ffffffffc02026f8 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015fc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201600:	00001c17          	auipc	s8,0x1
ffffffffc0201604:	250c0c13          	addi	s8,s8,592 # ffffffffc0202850 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201608:	000d4503          	lbu	a0,0(s10)
ffffffffc020160c:	02500793          	li	a5,37
ffffffffc0201610:	001d0413          	addi	s0,s10,1
ffffffffc0201614:	00f50e63          	beq	a0,a5,ffffffffc0201630 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201618:	c521                	beqz	a0,ffffffffc0201660 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020161a:	02500993          	li	s3,37
ffffffffc020161e:	a011                	j	ffffffffc0201622 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201620:	c121                	beqz	a0,ffffffffc0201660 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201622:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201624:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201626:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201628:	fff44503          	lbu	a0,-1(s0)
ffffffffc020162c:	ff351ae3          	bne	a0,s3,ffffffffc0201620 <vprintfmt+0x52>
ffffffffc0201630:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201634:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201638:	4981                	li	s3,0
ffffffffc020163a:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020163c:	5cfd                	li	s9,-1
ffffffffc020163e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201640:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201644:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201646:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020164a:	0ff6f693          	andi	a3,a3,255
ffffffffc020164e:	00140d13          	addi	s10,s0,1
ffffffffc0201652:	20d5e563          	bltu	a1,a3,ffffffffc020185c <vprintfmt+0x28e>
ffffffffc0201656:	068a                	slli	a3,a3,0x2
ffffffffc0201658:	96d2                	add	a3,a3,s4
ffffffffc020165a:	4294                	lw	a3,0(a3)
ffffffffc020165c:	96d2                	add	a3,a3,s4
ffffffffc020165e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201660:	70e6                	ld	ra,120(sp)
ffffffffc0201662:	7446                	ld	s0,112(sp)
ffffffffc0201664:	74a6                	ld	s1,104(sp)
ffffffffc0201666:	7906                	ld	s2,96(sp)
ffffffffc0201668:	69e6                	ld	s3,88(sp)
ffffffffc020166a:	6a46                	ld	s4,80(sp)
ffffffffc020166c:	6aa6                	ld	s5,72(sp)
ffffffffc020166e:	6b06                	ld	s6,64(sp)
ffffffffc0201670:	7be2                	ld	s7,56(sp)
ffffffffc0201672:	7c42                	ld	s8,48(sp)
ffffffffc0201674:	7ca2                	ld	s9,40(sp)
ffffffffc0201676:	7d02                	ld	s10,32(sp)
ffffffffc0201678:	6de2                	ld	s11,24(sp)
ffffffffc020167a:	6109                	addi	sp,sp,128
ffffffffc020167c:	8082                	ret
    if (lflag >= 2) {
ffffffffc020167e:	4705                	li	a4,1
ffffffffc0201680:	008a8593          	addi	a1,s5,8
ffffffffc0201684:	01074463          	blt	a4,a6,ffffffffc020168c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201688:	26080363          	beqz	a6,ffffffffc02018ee <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020168c:	000ab603          	ld	a2,0(s5)
ffffffffc0201690:	46c1                	li	a3,16
ffffffffc0201692:	8aae                	mv	s5,a1
ffffffffc0201694:	a06d                	j	ffffffffc020173e <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201696:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020169a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020169c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020169e:	b765                	j	ffffffffc0201646 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02016a0:	000aa503          	lw	a0,0(s5)
ffffffffc02016a4:	85a6                	mv	a1,s1
ffffffffc02016a6:	0aa1                	addi	s5,s5,8
ffffffffc02016a8:	9902                	jalr	s2
            break;
ffffffffc02016aa:	bfb9                	j	ffffffffc0201608 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016ac:	4705                	li	a4,1
ffffffffc02016ae:	008a8993          	addi	s3,s5,8
ffffffffc02016b2:	01074463          	blt	a4,a6,ffffffffc02016ba <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02016b6:	22080463          	beqz	a6,ffffffffc02018de <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02016ba:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016be:	24044463          	bltz	s0,ffffffffc0201906 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02016c2:	8622                	mv	a2,s0
ffffffffc02016c4:	8ace                	mv	s5,s3
ffffffffc02016c6:	46a9                	li	a3,10
ffffffffc02016c8:	a89d                	j	ffffffffc020173e <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02016ca:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016ce:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016d0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016d2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02016d6:	8fb5                	xor	a5,a5,a3
ffffffffc02016d8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016dc:	1ad74363          	blt	a4,a3,ffffffffc0201882 <vprintfmt+0x2b4>
ffffffffc02016e0:	00369793          	slli	a5,a3,0x3
ffffffffc02016e4:	97e2                	add	a5,a5,s8
ffffffffc02016e6:	639c                	ld	a5,0(a5)
ffffffffc02016e8:	18078d63          	beqz	a5,ffffffffc0201882 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02016ec:	86be                	mv	a3,a5
ffffffffc02016ee:	00001617          	auipc	a2,0x1
ffffffffc02016f2:	24a60613          	addi	a2,a2,586 # ffffffffc0202938 <error_string+0xe8>
ffffffffc02016f6:	85a6                	mv	a1,s1
ffffffffc02016f8:	854a                	mv	a0,s2
ffffffffc02016fa:	240000ef          	jal	ra,ffffffffc020193a <printfmt>
ffffffffc02016fe:	b729                	j	ffffffffc0201608 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201700:	00144603          	lbu	a2,1(s0)
ffffffffc0201704:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201706:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201708:	bf3d                	j	ffffffffc0201646 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020170a:	4705                	li	a4,1
ffffffffc020170c:	008a8593          	addi	a1,s5,8
ffffffffc0201710:	01074463          	blt	a4,a6,ffffffffc0201718 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201714:	1e080263          	beqz	a6,ffffffffc02018f8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201718:	000ab603          	ld	a2,0(s5)
ffffffffc020171c:	46a1                	li	a3,8
ffffffffc020171e:	8aae                	mv	s5,a1
ffffffffc0201720:	a839                	j	ffffffffc020173e <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201722:	03000513          	li	a0,48
ffffffffc0201726:	85a6                	mv	a1,s1
ffffffffc0201728:	e03e                	sd	a5,0(sp)
ffffffffc020172a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020172c:	85a6                	mv	a1,s1
ffffffffc020172e:	07800513          	li	a0,120
ffffffffc0201732:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201734:	0aa1                	addi	s5,s5,8
ffffffffc0201736:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020173a:	6782                	ld	a5,0(sp)
ffffffffc020173c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020173e:	876e                	mv	a4,s11
ffffffffc0201740:	85a6                	mv	a1,s1
ffffffffc0201742:	854a                	mv	a0,s2
ffffffffc0201744:	e1fff0ef          	jal	ra,ffffffffc0201562 <printnum>
            break;
ffffffffc0201748:	b5c1                	j	ffffffffc0201608 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020174a:	000ab603          	ld	a2,0(s5)
ffffffffc020174e:	0aa1                	addi	s5,s5,8
ffffffffc0201750:	1c060663          	beqz	a2,ffffffffc020191c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201754:	00160413          	addi	s0,a2,1
ffffffffc0201758:	17b05c63          	blez	s11,ffffffffc02018d0 <vprintfmt+0x302>
ffffffffc020175c:	02d00593          	li	a1,45
ffffffffc0201760:	14b79263          	bne	a5,a1,ffffffffc02018a4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201764:	00064783          	lbu	a5,0(a2)
ffffffffc0201768:	0007851b          	sext.w	a0,a5
ffffffffc020176c:	c905                	beqz	a0,ffffffffc020179c <vprintfmt+0x1ce>
ffffffffc020176e:	000cc563          	bltz	s9,ffffffffc0201778 <vprintfmt+0x1aa>
ffffffffc0201772:	3cfd                	addiw	s9,s9,-1
ffffffffc0201774:	036c8263          	beq	s9,s6,ffffffffc0201798 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201778:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020177a:	18098463          	beqz	s3,ffffffffc0201902 <vprintfmt+0x334>
ffffffffc020177e:	3781                	addiw	a5,a5,-32
ffffffffc0201780:	18fbf163          	bleu	a5,s7,ffffffffc0201902 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201784:	03f00513          	li	a0,63
ffffffffc0201788:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020178a:	0405                	addi	s0,s0,1
ffffffffc020178c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201790:	3dfd                	addiw	s11,s11,-1
ffffffffc0201792:	0007851b          	sext.w	a0,a5
ffffffffc0201796:	fd61                	bnez	a0,ffffffffc020176e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201798:	e7b058e3          	blez	s11,ffffffffc0201608 <vprintfmt+0x3a>
ffffffffc020179c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020179e:	85a6                	mv	a1,s1
ffffffffc02017a0:	02000513          	li	a0,32
ffffffffc02017a4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017a6:	e60d81e3          	beqz	s11,ffffffffc0201608 <vprintfmt+0x3a>
ffffffffc02017aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02017ac:	85a6                	mv	a1,s1
ffffffffc02017ae:	02000513          	li	a0,32
ffffffffc02017b2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02017b4:	fe0d94e3          	bnez	s11,ffffffffc020179c <vprintfmt+0x1ce>
ffffffffc02017b8:	bd81                	j	ffffffffc0201608 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017ba:	4705                	li	a4,1
ffffffffc02017bc:	008a8593          	addi	a1,s5,8
ffffffffc02017c0:	01074463          	blt	a4,a6,ffffffffc02017c8 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02017c4:	12080063          	beqz	a6,ffffffffc02018e4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02017c8:	000ab603          	ld	a2,0(s5)
ffffffffc02017cc:	46a9                	li	a3,10
ffffffffc02017ce:	8aae                	mv	s5,a1
ffffffffc02017d0:	b7bd                	j	ffffffffc020173e <vprintfmt+0x170>
ffffffffc02017d2:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02017d6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017da:	846a                	mv	s0,s10
ffffffffc02017dc:	b5ad                	j	ffffffffc0201646 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017de:	85a6                	mv	a1,s1
ffffffffc02017e0:	02500513          	li	a0,37
ffffffffc02017e4:	9902                	jalr	s2
            break;
ffffffffc02017e6:	b50d                	j	ffffffffc0201608 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02017e8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02017ec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02017f0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017f2:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02017f4:	e40dd9e3          	bgez	s11,ffffffffc0201646 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02017f8:	8de6                	mv	s11,s9
ffffffffc02017fa:	5cfd                	li	s9,-1
ffffffffc02017fc:	b5a9                	j	ffffffffc0201646 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02017fe:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201802:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201806:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201808:	bd3d                	j	ffffffffc0201646 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020180a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020180e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201812:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201814:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201818:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020181c:	fcd56ce3          	bltu	a0,a3,ffffffffc02017f4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201820:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201822:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201826:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020182a:	0196873b          	addw	a4,a3,s9
ffffffffc020182e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201832:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201836:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020183a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020183e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201842:	fcd57fe3          	bleu	a3,a0,ffffffffc0201820 <vprintfmt+0x252>
ffffffffc0201846:	b77d                	j	ffffffffc02017f4 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201848:	fffdc693          	not	a3,s11
ffffffffc020184c:	96fd                	srai	a3,a3,0x3f
ffffffffc020184e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201852:	00144603          	lbu	a2,1(s0)
ffffffffc0201856:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201858:	846a                	mv	s0,s10
ffffffffc020185a:	b3f5                	j	ffffffffc0201646 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020185c:	85a6                	mv	a1,s1
ffffffffc020185e:	02500513          	li	a0,37
ffffffffc0201862:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201864:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201868:	02500793          	li	a5,37
ffffffffc020186c:	8d22                	mv	s10,s0
ffffffffc020186e:	d8f70de3          	beq	a4,a5,ffffffffc0201608 <vprintfmt+0x3a>
ffffffffc0201872:	02500713          	li	a4,37
ffffffffc0201876:	1d7d                	addi	s10,s10,-1
ffffffffc0201878:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020187c:	fee79de3          	bne	a5,a4,ffffffffc0201876 <vprintfmt+0x2a8>
ffffffffc0201880:	b361                	j	ffffffffc0201608 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201882:	00001617          	auipc	a2,0x1
ffffffffc0201886:	0a660613          	addi	a2,a2,166 # ffffffffc0202928 <error_string+0xd8>
ffffffffc020188a:	85a6                	mv	a1,s1
ffffffffc020188c:	854a                	mv	a0,s2
ffffffffc020188e:	0ac000ef          	jal	ra,ffffffffc020193a <printfmt>
ffffffffc0201892:	bb9d                	j	ffffffffc0201608 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201894:	00001617          	auipc	a2,0x1
ffffffffc0201898:	08c60613          	addi	a2,a2,140 # ffffffffc0202920 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020189c:	00001417          	auipc	s0,0x1
ffffffffc02018a0:	08540413          	addi	s0,s0,133 # ffffffffc0202921 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018a4:	8532                	mv	a0,a2
ffffffffc02018a6:	85e6                	mv	a1,s9
ffffffffc02018a8:	e032                	sd	a2,0(sp)
ffffffffc02018aa:	e43e                	sd	a5,8(sp)
ffffffffc02018ac:	1de000ef          	jal	ra,ffffffffc0201a8a <strnlen>
ffffffffc02018b0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018b4:	6602                	ld	a2,0(sp)
ffffffffc02018b6:	01b05d63          	blez	s11,ffffffffc02018d0 <vprintfmt+0x302>
ffffffffc02018ba:	67a2                	ld	a5,8(sp)
ffffffffc02018bc:	2781                	sext.w	a5,a5
ffffffffc02018be:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018c0:	6522                	ld	a0,8(sp)
ffffffffc02018c2:	85a6                	mv	a1,s1
ffffffffc02018c4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02018c8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018ca:	6602                	ld	a2,0(sp)
ffffffffc02018cc:	fe0d9ae3          	bnez	s11,ffffffffc02018c0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018d0:	00064783          	lbu	a5,0(a2)
ffffffffc02018d4:	0007851b          	sext.w	a0,a5
ffffffffc02018d8:	e8051be3          	bnez	a0,ffffffffc020176e <vprintfmt+0x1a0>
ffffffffc02018dc:	b335                	j	ffffffffc0201608 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02018de:	000aa403          	lw	s0,0(s5)
ffffffffc02018e2:	bbf1                	j	ffffffffc02016be <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02018e4:	000ae603          	lwu	a2,0(s5)
ffffffffc02018e8:	46a9                	li	a3,10
ffffffffc02018ea:	8aae                	mv	s5,a1
ffffffffc02018ec:	bd89                	j	ffffffffc020173e <vprintfmt+0x170>
ffffffffc02018ee:	000ae603          	lwu	a2,0(s5)
ffffffffc02018f2:	46c1                	li	a3,16
ffffffffc02018f4:	8aae                	mv	s5,a1
ffffffffc02018f6:	b5a1                	j	ffffffffc020173e <vprintfmt+0x170>
ffffffffc02018f8:	000ae603          	lwu	a2,0(s5)
ffffffffc02018fc:	46a1                	li	a3,8
ffffffffc02018fe:	8aae                	mv	s5,a1
ffffffffc0201900:	bd3d                	j	ffffffffc020173e <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201902:	9902                	jalr	s2
ffffffffc0201904:	b559                	j	ffffffffc020178a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201906:	85a6                	mv	a1,s1
ffffffffc0201908:	02d00513          	li	a0,45
ffffffffc020190c:	e03e                	sd	a5,0(sp)
ffffffffc020190e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201910:	8ace                	mv	s5,s3
ffffffffc0201912:	40800633          	neg	a2,s0
ffffffffc0201916:	46a9                	li	a3,10
ffffffffc0201918:	6782                	ld	a5,0(sp)
ffffffffc020191a:	b515                	j	ffffffffc020173e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020191c:	01b05663          	blez	s11,ffffffffc0201928 <vprintfmt+0x35a>
ffffffffc0201920:	02d00693          	li	a3,45
ffffffffc0201924:	f6d798e3          	bne	a5,a3,ffffffffc0201894 <vprintfmt+0x2c6>
ffffffffc0201928:	00001417          	auipc	s0,0x1
ffffffffc020192c:	ff940413          	addi	s0,s0,-7 # ffffffffc0202921 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201930:	02800513          	li	a0,40
ffffffffc0201934:	02800793          	li	a5,40
ffffffffc0201938:	bd1d                	j	ffffffffc020176e <vprintfmt+0x1a0>

ffffffffc020193a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020193a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020193c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201940:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201942:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201944:	ec06                	sd	ra,24(sp)
ffffffffc0201946:	f83a                	sd	a4,48(sp)
ffffffffc0201948:	fc3e                	sd	a5,56(sp)
ffffffffc020194a:	e0c2                	sd	a6,64(sp)
ffffffffc020194c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020194e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201950:	c7fff0ef          	jal	ra,ffffffffc02015ce <vprintfmt>
}
ffffffffc0201954:	60e2                	ld	ra,24(sp)
ffffffffc0201956:	6161                	addi	sp,sp,80
ffffffffc0201958:	8082                	ret

ffffffffc020195a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020195a:	715d                	addi	sp,sp,-80
ffffffffc020195c:	e486                	sd	ra,72(sp)
ffffffffc020195e:	e0a2                	sd	s0,64(sp)
ffffffffc0201960:	fc26                	sd	s1,56(sp)
ffffffffc0201962:	f84a                	sd	s2,48(sp)
ffffffffc0201964:	f44e                	sd	s3,40(sp)
ffffffffc0201966:	f052                	sd	s4,32(sp)
ffffffffc0201968:	ec56                	sd	s5,24(sp)
ffffffffc020196a:	e85a                	sd	s6,16(sp)
ffffffffc020196c:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020196e:	c901                	beqz	a0,ffffffffc020197e <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201970:	85aa                	mv	a1,a0
ffffffffc0201972:	00001517          	auipc	a0,0x1
ffffffffc0201976:	fc650513          	addi	a0,a0,-58 # ffffffffc0202938 <error_string+0xe8>
ffffffffc020197a:	f3cfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc020197e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201980:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201982:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201984:	4aa9                	li	s5,10
ffffffffc0201986:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201988:	00004b97          	auipc	s7,0x4
ffffffffc020198c:	690b8b93          	addi	s7,s7,1680 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201990:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201994:	f9afe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201998:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020199a:	00054b63          	bltz	a0,ffffffffc02019b0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020199e:	00a95b63          	ble	a0,s2,ffffffffc02019b4 <readline+0x5a>
ffffffffc02019a2:	029a5463          	ble	s1,s4,ffffffffc02019ca <readline+0x70>
        c = getchar();
ffffffffc02019a6:	f88fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019aa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019ac:	fe0559e3          	bgez	a0,ffffffffc020199e <readline+0x44>
            return NULL;
ffffffffc02019b0:	4501                	li	a0,0
ffffffffc02019b2:	a099                	j	ffffffffc02019f8 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019b4:	03341463          	bne	s0,s3,ffffffffc02019dc <readline+0x82>
ffffffffc02019b8:	e8b9                	bnez	s1,ffffffffc0201a0e <readline+0xb4>
        c = getchar();
ffffffffc02019ba:	f74fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02019be:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019c0:	fe0548e3          	bltz	a0,ffffffffc02019b0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019c4:	fea958e3          	ble	a0,s2,ffffffffc02019b4 <readline+0x5a>
ffffffffc02019c8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02019ca:	8522                	mv	a0,s0
ffffffffc02019cc:	f1efe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02019d0:	009b87b3          	add	a5,s7,s1
ffffffffc02019d4:	00878023          	sb	s0,0(a5)
ffffffffc02019d8:	2485                	addiw	s1,s1,1
ffffffffc02019da:	bf6d                	j	ffffffffc0201994 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02019dc:	01540463          	beq	s0,s5,ffffffffc02019e4 <readline+0x8a>
ffffffffc02019e0:	fb641ae3          	bne	s0,s6,ffffffffc0201994 <readline+0x3a>
            cputchar(c);
ffffffffc02019e4:	8522                	mv	a0,s0
ffffffffc02019e6:	f04fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019ea:	00004517          	auipc	a0,0x4
ffffffffc02019ee:	62e50513          	addi	a0,a0,1582 # ffffffffc0206018 <edata>
ffffffffc02019f2:	94aa                	add	s1,s1,a0
ffffffffc02019f4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019f8:	60a6                	ld	ra,72(sp)
ffffffffc02019fa:	6406                	ld	s0,64(sp)
ffffffffc02019fc:	74e2                	ld	s1,56(sp)
ffffffffc02019fe:	7942                	ld	s2,48(sp)
ffffffffc0201a00:	79a2                	ld	s3,40(sp)
ffffffffc0201a02:	7a02                	ld	s4,32(sp)
ffffffffc0201a04:	6ae2                	ld	s5,24(sp)
ffffffffc0201a06:	6b42                	ld	s6,16(sp)
ffffffffc0201a08:	6ba2                	ld	s7,8(sp)
ffffffffc0201a0a:	6161                	addi	sp,sp,80
ffffffffc0201a0c:	8082                	ret
            cputchar(c);
ffffffffc0201a0e:	4521                	li	a0,8
ffffffffc0201a10:	edafe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a14:	34fd                	addiw	s1,s1,-1
ffffffffc0201a16:	bfbd                	j	ffffffffc0201994 <readline+0x3a>

ffffffffc0201a18 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a18:	00004797          	auipc	a5,0x4
ffffffffc0201a1c:	5f078793          	addi	a5,a5,1520 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a20:	6398                	ld	a4,0(a5)
ffffffffc0201a22:	4781                	li	a5,0
ffffffffc0201a24:	88ba                	mv	a7,a4
ffffffffc0201a26:	852a                	mv	a0,a0
ffffffffc0201a28:	85be                	mv	a1,a5
ffffffffc0201a2a:	863e                	mv	a2,a5
ffffffffc0201a2c:	00000073          	ecall
ffffffffc0201a30:	87aa                	mv	a5,a0
}
ffffffffc0201a32:	8082                	ret

ffffffffc0201a34 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a34:	00005797          	auipc	a5,0x5
ffffffffc0201a38:	a0478793          	addi	a5,a5,-1532 # ffffffffc0206438 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a3c:	6398                	ld	a4,0(a5)
ffffffffc0201a3e:	4781                	li	a5,0
ffffffffc0201a40:	88ba                	mv	a7,a4
ffffffffc0201a42:	852a                	mv	a0,a0
ffffffffc0201a44:	85be                	mv	a1,a5
ffffffffc0201a46:	863e                	mv	a2,a5
ffffffffc0201a48:	00000073          	ecall
ffffffffc0201a4c:	87aa                	mv	a5,a0
}
ffffffffc0201a4e:	8082                	ret

ffffffffc0201a50 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a50:	00004797          	auipc	a5,0x4
ffffffffc0201a54:	5b078793          	addi	a5,a5,1456 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a58:	639c                	ld	a5,0(a5)
ffffffffc0201a5a:	4501                	li	a0,0
ffffffffc0201a5c:	88be                	mv	a7,a5
ffffffffc0201a5e:	852a                	mv	a0,a0
ffffffffc0201a60:	85aa                	mv	a1,a0
ffffffffc0201a62:	862a                	mv	a2,a0
ffffffffc0201a64:	00000073          	ecall
ffffffffc0201a68:	852a                	mv	a0,a0
}
ffffffffc0201a6a:	2501                	sext.w	a0,a0
ffffffffc0201a6c:	8082                	ret

ffffffffc0201a6e <sbi_shutdown>:
void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201a6e:	00004797          	auipc	a5,0x4
ffffffffc0201a72:	5a278793          	addi	a5,a5,1442 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201a76:	6398                	ld	a4,0(a5)
ffffffffc0201a78:	4781                	li	a5,0
ffffffffc0201a7a:	88ba                	mv	a7,a4
ffffffffc0201a7c:	853e                	mv	a0,a5
ffffffffc0201a7e:	85be                	mv	a1,a5
ffffffffc0201a80:	863e                	mv	a2,a5
ffffffffc0201a82:	00000073          	ecall
ffffffffc0201a86:	87aa                	mv	a5,a0
}
ffffffffc0201a88:	8082                	ret

ffffffffc0201a8a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a8a:	c185                	beqz	a1,ffffffffc0201aaa <strnlen+0x20>
ffffffffc0201a8c:	00054783          	lbu	a5,0(a0)
ffffffffc0201a90:	cf89                	beqz	a5,ffffffffc0201aaa <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a92:	4781                	li	a5,0
ffffffffc0201a94:	a021                	j	ffffffffc0201a9c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a96:	00074703          	lbu	a4,0(a4)
ffffffffc0201a9a:	c711                	beqz	a4,ffffffffc0201aa6 <strnlen+0x1c>
        cnt ++;
ffffffffc0201a9c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a9e:	00f50733          	add	a4,a0,a5
ffffffffc0201aa2:	fef59ae3          	bne	a1,a5,ffffffffc0201a96 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201aa6:	853e                	mv	a0,a5
ffffffffc0201aa8:	8082                	ret
    size_t cnt = 0;
ffffffffc0201aaa:	4781                	li	a5,0
}
ffffffffc0201aac:	853e                	mv	a0,a5
ffffffffc0201aae:	8082                	ret

ffffffffc0201ab0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ab0:	00054783          	lbu	a5,0(a0)
ffffffffc0201ab4:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ab8:	cb91                	beqz	a5,ffffffffc0201acc <strcmp+0x1c>
ffffffffc0201aba:	00e79c63          	bne	a5,a4,ffffffffc0201ad2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201abe:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201ac0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201ac4:	0585                	addi	a1,a1,1
ffffffffc0201ac6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201aca:	fbe5                	bnez	a5,ffffffffc0201aba <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201acc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201ace:	9d19                	subw	a0,a0,a4
ffffffffc0201ad0:	8082                	ret
ffffffffc0201ad2:	0007851b          	sext.w	a0,a5
ffffffffc0201ad6:	9d19                	subw	a0,a0,a4
ffffffffc0201ad8:	8082                	ret

ffffffffc0201ada <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ada:	00054783          	lbu	a5,0(a0)
ffffffffc0201ade:	cb91                	beqz	a5,ffffffffc0201af2 <strchr+0x18>
        if (*s == c) {
ffffffffc0201ae0:	00b79563          	bne	a5,a1,ffffffffc0201aea <strchr+0x10>
ffffffffc0201ae4:	a809                	j	ffffffffc0201af6 <strchr+0x1c>
ffffffffc0201ae6:	00b78763          	beq	a5,a1,ffffffffc0201af4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201aea:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201aec:	00054783          	lbu	a5,0(a0)
ffffffffc0201af0:	fbfd                	bnez	a5,ffffffffc0201ae6 <strchr+0xc>
    }
    return NULL;
ffffffffc0201af2:	4501                	li	a0,0
}
ffffffffc0201af4:	8082                	ret
ffffffffc0201af6:	8082                	ret

ffffffffc0201af8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201af8:	ca01                	beqz	a2,ffffffffc0201b08 <memset+0x10>
ffffffffc0201afa:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201afc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201afe:	0785                	addi	a5,a5,1
ffffffffc0201b00:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201b04:	fec79de3          	bne	a5,a2,ffffffffc0201afe <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b08:	8082                	ret
