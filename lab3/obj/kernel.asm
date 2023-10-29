
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2c0040ef          	jal	ra,ffffffffc020430e <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2e658593          	addi	a1,a1,742 # ffffffffc0204338 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204358 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	31d010ef          	jal	ra,ffffffffc0201b86 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5b2030ef          	jal	ra,ffffffffc0203624 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	003020ef          	jal	ra,ffffffffc020287c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	575030ef          	jal	ra,ffffffffc0203e26 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	541030ef          	jal	ra,ffffffffc0203e26 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	28850513          	addi	a0,a0,648 # ffffffffc0204390 <etext+0x58>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	29250513          	addi	a0,a0,658 # ffffffffc02043b0 <etext+0x78>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	20e58593          	addi	a1,a1,526 # ffffffffc0204338 <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	29e50513          	addi	a0,a0,670 # ffffffffc02043d0 <etext+0x98>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	2aa50513          	addi	a0,a0,682 # ffffffffc02043f0 <etext+0xb8>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	44e58593          	addi	a1,a1,1102 # ffffffffc02115a0 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	2b650513          	addi	a0,a0,694 # ffffffffc0204410 <etext+0xd8>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	83958593          	addi	a1,a1,-1991 # ffffffffc021199f <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	2a850513          	addi	a0,a0,680 # ffffffffc0204430 <etext+0xf8>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	1c860613          	addi	a2,a2,456 # ffffffffc0204360 <etext+0x28>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1d450513          	addi	a0,a0,468 # ffffffffc0204378 <etext+0x40>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	38460613          	addi	a2,a2,900 # ffffffffc0204538 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	39c58593          	addi	a1,a1,924 # ffffffffc0204558 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	39c50513          	addi	a0,a0,924 # ffffffffc0204560 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	39e60613          	addi	a2,a2,926 # ffffffffc0204570 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	3be58593          	addi	a1,a1,958 # ffffffffc0204598 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	37e50513          	addi	a0,a0,894 # ffffffffc0204560 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3ba60613          	addi	a2,a2,954 # ffffffffc02045a8 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	3d258593          	addi	a1,a1,978 # ffffffffc02045c8 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	36250513          	addi	a0,a0,866 # ffffffffc0204560 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	27050513          	addi	a0,a0,624 # ffffffffc02044a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	27650513          	addi	a0,a0,630 # ffffffffc02044d0 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	1f0c8c93          	addi	s9,s9,496 # ffffffffc0204460 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	7f098993          	addi	s3,s3,2032 # ffffffffc0205a68 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	27890913          	addi	s2,s2,632 # ffffffffc02044f8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	276b0b13          	addi	s6,s6,630 # ffffffffc0204500 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	2c6a8a93          	addi	s5,s5,710 # ffffffffc0204558 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	715030ef          	jal	ra,ffffffffc02041b2 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	040040ef          	jal	ra,ffffffffc02042f0 <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	19ad0d13          	addi	s10,s10,410 # ffffffffc0204460 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	7f3030ef          	jal	ra,ffffffffc02042c6 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	7df030ef          	jal	ra,ffffffffc02042c6 <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	7a3030ef          	jal	ra,ffffffffc02042f0 <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	1ba50513          	addi	a0,a0,442 # ffffffffc0204520 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	23250513          	addi	a0,a0,562 # ffffffffc02045d8 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	20450513          	addi	a0,a0,516 # ffffffffc02055c0 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	1fe50513          	addi	a0,a0,510 # ffffffffc02045f8 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607bb23          	sd	zero,118(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	65f030ef          	jal	ra,ffffffffc0204320 <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	639030ef          	jal	ra,ffffffffc0204320 <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	43050513          	addi	a0,a0,1072 # ffffffffc0204960 <commands+0x500>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	05c78793          	addi	a5,a5,92 # ffffffffc0211598 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	60c0306f          	j	ffffffffc0203b62 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	42660613          	addi	a2,a2,1062 # ffffffffc0204980 <commands+0x520>
ffffffffc0200562:	07b00593          	li	a1,123
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	43250513          	addi	a0,a0,1074 # ffffffffc0204998 <commands+0x538>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	50a78793          	addi	a5,a5,1290 # ffffffffc0200a80 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	41850513          	addi	a0,a0,1048 # ffffffffc02049b0 <commands+0x550>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	42050513          	addi	a0,a0,1056 # ffffffffc02049c8 <commands+0x568>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	42a50513          	addi	a0,a0,1066 # ffffffffc02049e0 <commands+0x580>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	43450513          	addi	a0,a0,1076 # ffffffffc02049f8 <commands+0x598>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	43e50513          	addi	a0,a0,1086 # ffffffffc0204a10 <commands+0x5b0>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	44850513          	addi	a0,a0,1096 # ffffffffc0204a28 <commands+0x5c8>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	45250513          	addi	a0,a0,1106 # ffffffffc0204a40 <commands+0x5e0>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	45c50513          	addi	a0,a0,1116 # ffffffffc0204a58 <commands+0x5f8>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	46650513          	addi	a0,a0,1126 # ffffffffc0204a70 <commands+0x610>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	47050513          	addi	a0,a0,1136 # ffffffffc0204a88 <commands+0x628>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	47a50513          	addi	a0,a0,1146 # ffffffffc0204aa0 <commands+0x640>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	48450513          	addi	a0,a0,1156 # ffffffffc0204ab8 <commands+0x658>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	48e50513          	addi	a0,a0,1166 # ffffffffc0204ad0 <commands+0x670>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	49850513          	addi	a0,a0,1176 # ffffffffc0204ae8 <commands+0x688>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	4a250513          	addi	a0,a0,1186 # ffffffffc0204b00 <commands+0x6a0>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204b18 <commands+0x6b8>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	4b650513          	addi	a0,a0,1206 # ffffffffc0204b30 <commands+0x6d0>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	4c050513          	addi	a0,a0,1216 # ffffffffc0204b48 <commands+0x6e8>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204b60 <commands+0x700>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	4d450513          	addi	a0,a0,1236 # ffffffffc0204b78 <commands+0x718>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	4de50513          	addi	a0,a0,1246 # ffffffffc0204b90 <commands+0x730>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	4e850513          	addi	a0,a0,1256 # ffffffffc0204ba8 <commands+0x748>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	4f250513          	addi	a0,a0,1266 # ffffffffc0204bc0 <commands+0x760>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	4fc50513          	addi	a0,a0,1276 # ffffffffc0204bd8 <commands+0x778>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	50650513          	addi	a0,a0,1286 # ffffffffc0204bf0 <commands+0x790>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	51050513          	addi	a0,a0,1296 # ffffffffc0204c08 <commands+0x7a8>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	51a50513          	addi	a0,a0,1306 # ffffffffc0204c20 <commands+0x7c0>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	52450513          	addi	a0,a0,1316 # ffffffffc0204c38 <commands+0x7d8>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	52e50513          	addi	a0,a0,1326 # ffffffffc0204c50 <commands+0x7f0>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	53850513          	addi	a0,a0,1336 # ffffffffc0204c68 <commands+0x808>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	54250513          	addi	a0,a0,1346 # ffffffffc0204c80 <commands+0x820>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	54850513          	addi	a0,a0,1352 # ffffffffc0204c98 <commands+0x838>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	54a50513          	addi	a0,a0,1354 # ffffffffc0204cb0 <commands+0x850>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	54a50513          	addi	a0,a0,1354 # ffffffffc0204cc8 <commands+0x868>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	55250513          	addi	a0,a0,1362 # ffffffffc0204ce0 <commands+0x880>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	55a50513          	addi	a0,a0,1370 # ffffffffc0204cf8 <commands+0x898>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	55e50513          	addi	a0,a0,1374 # ffffffffc0204d10 <commands+0x8b0>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	08f76e63          	bltu	a4,a5,ffffffffc0200868 <interrupt_handler+0xa8>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e4470713          	addi	a4,a4,-444 # ffffffffc0204614 <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	12e50513          	addi	a0,a0,302 # ffffffffc0204910 <commands+0x4b0>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	10250513          	addi	a0,a0,258 # ffffffffc02048f0 <commands+0x490>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	0b650513          	addi	a0,a0,182 # ffffffffc02048b0 <commands+0x450>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	0ca50513          	addi	a0,a0,202 # ffffffffc02048d0 <commands+0x470>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	12e50513          	addi	a0,a0,302 # ffffffffc0204940 <commands+0x4e0>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	bedff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            ticks++;
ffffffffc0200826:	00011717          	auipc	a4,0x11
ffffffffc020082a:	c5270713          	addi	a4,a4,-942 # ffffffffc0211478 <ticks>
ffffffffc020082e:	631c                	ld	a5,0(a4)
ffffffffc0200830:	0785                	addi	a5,a5,1
ffffffffc0200832:	00011697          	auipc	a3,0x11
ffffffffc0200836:	c4f6b323          	sd	a5,-954(a3) # ffffffffc0211478 <ticks>
            if (ticks % TICK_NUM == 0) 
ffffffffc020083a:	631c                	ld	a5,0(a4)
ffffffffc020083c:	06400713          	li	a4,100
ffffffffc0200840:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200844:	c785                	beqz	a5,ffffffffc020086c <interrupt_handler+0xac>
ffffffffc0200846:	00011797          	auipc	a5,0x11
ffffffffc020084a:	c0a78793          	addi	a5,a5,-1014 # ffffffffc0211450 <times>
ffffffffc020084e:	4398                	lw	a4,0(a5)
            if(times==10)
ffffffffc0200850:	47a9                	li	a5,10
ffffffffc0200852:	00f71863          	bne	a4,a5,ffffffffc0200862 <interrupt_handler+0xa2>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200856:	4501                	li	a0,0
ffffffffc0200858:	4581                	li	a1,0
ffffffffc020085a:	4601                	li	a2,0
ffffffffc020085c:	48a1                	li	a7,8
ffffffffc020085e:	00000073          	ecall
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200862:	60a2                	ld	ra,8(sp)
ffffffffc0200864:	0141                	addi	sp,sp,16
ffffffffc0200866:	8082                	ret
            print_trapframe(tf);
ffffffffc0200868:	ef7ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020086c:	06400593          	li	a1,100
ffffffffc0200870:	00004517          	auipc	a0,0x4
ffffffffc0200874:	0c050513          	addi	a0,a0,192 # ffffffffc0204930 <commands+0x4d0>
ffffffffc0200878:	847ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            	times++;
ffffffffc020087c:	00011797          	auipc	a5,0x11
ffffffffc0200880:	bd478793          	addi	a5,a5,-1068 # ffffffffc0211450 <times>
ffffffffc0200884:	439c                	lw	a5,0(a5)
ffffffffc0200886:	0017871b          	addiw	a4,a5,1
ffffffffc020088a:	00011697          	auipc	a3,0x11
ffffffffc020088e:	bce6a323          	sw	a4,-1082(a3) # ffffffffc0211450 <times>
ffffffffc0200892:	bf7d                	j	ffffffffc0200850 <interrupt_handler+0x90>

ffffffffc0200894 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200894:	11853783          	ld	a5,280(a0)
ffffffffc0200898:	473d                	li	a4,15
ffffffffc020089a:	1af76463          	bltu	a4,a5,ffffffffc0200a42 <exception_handler+0x1ae>
ffffffffc020089e:	00004717          	auipc	a4,0x4
ffffffffc02008a2:	da670713          	addi	a4,a4,-602 # ffffffffc0204644 <commands+0x1e4>
ffffffffc02008a6:	078a                	slli	a5,a5,0x2
ffffffffc02008a8:	97ba                	add	a5,a5,a4
ffffffffc02008aa:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e822                	sd	s0,16(sp)
ffffffffc02008b0:	ec06                	sd	ra,24(sp)
ffffffffc02008b2:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc02008b4:	97ba                	add	a5,a5,a4
ffffffffc02008b6:	842a                	mv	s0,a0
ffffffffc02008b8:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	fde50513          	addi	a0,a0,-34 # ffffffffc0204898 <commands+0x438>
ffffffffc02008c2:	ffcff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c6:	8522                	mv	a0,s0
ffffffffc02008c8:	c39ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008cc:	84aa                	mv	s1,a0
ffffffffc02008ce:	16051c63          	bnez	a0,ffffffffc0200a46 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008d2:	60e2                	ld	ra,24(sp)
ffffffffc02008d4:	6442                	ld	s0,16(sp)
ffffffffc02008d6:	64a2                	ld	s1,8(sp)
ffffffffc02008d8:	6105                	addi	sp,sp,32
ffffffffc02008da:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	dac50513          	addi	a0,a0,-596 # ffffffffc0204688 <commands+0x228>
}
ffffffffc02008e4:	6442                	ld	s0,16(sp)
ffffffffc02008e6:	60e2                	ld	ra,24(sp)
ffffffffc02008e8:	64a2                	ld	s1,8(sp)
ffffffffc02008ea:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ec:	fd2ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	db850513          	addi	a0,a0,-584 # ffffffffc02046a8 <commands+0x248>
ffffffffc02008f8:	b7f5                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Exception type: Illegal instruction\n");  // 输出异常类型
ffffffffc02008fa:	00004517          	auipc	a0,0x4
ffffffffc02008fe:	dce50513          	addi	a0,a0,-562 # ffffffffc02046c8 <commands+0x268>
ffffffffc0200902:	fbcff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);  // 输出异常指令地址
ffffffffc0200906:	10843583          	ld	a1,264(s0)
ffffffffc020090a:	00004517          	auipc	a0,0x4
ffffffffc020090e:	de650513          	addi	a0,a0,-538 # ffffffffc02046f0 <commands+0x290>
ffffffffc0200912:	facff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc += 4;  // 更新 tf->epc寄存器
ffffffffc0200916:	10843783          	ld	a5,264(s0)
ffffffffc020091a:	0791                	addi	a5,a5,4
ffffffffc020091c:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200920:	bf4d                	j	ffffffffc02008d2 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");  // 输出异常类型
ffffffffc0200922:	00004517          	auipc	a0,0x4
ffffffffc0200926:	dfe50513          	addi	a0,a0,-514 # ffffffffc0204720 <commands+0x2c0>
ffffffffc020092a:	f94ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);  // 输出异常指令地址
ffffffffc020092e:	10843583          	ld	a1,264(s0)
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	e0e50513          	addi	a0,a0,-498 # ffffffffc0204740 <commands+0x2e0>
ffffffffc020093a:	f84ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc += 2;  // 更新 tf->epc寄存器
ffffffffc020093e:	10843783          	ld	a5,264(s0)
ffffffffc0200942:	0789                	addi	a5,a5,2
ffffffffc0200944:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200948:	b769                	j	ffffffffc02008d2 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc020094a:	00004517          	auipc	a0,0x4
ffffffffc020094e:	e1650513          	addi	a0,a0,-490 # ffffffffc0204760 <commands+0x300>
ffffffffc0200952:	bf49                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200954:	00004517          	auipc	a0,0x4
ffffffffc0200958:	e2c50513          	addi	a0,a0,-468 # ffffffffc0204780 <commands+0x320>
ffffffffc020095c:	f62ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200960:	8522                	mv	a0,s0
ffffffffc0200962:	b9fff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200966:	84aa                	mv	s1,a0
ffffffffc0200968:	d52d                	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020096a:	8522                	mv	a0,s0
ffffffffc020096c:	df3ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200970:	86a6                	mv	a3,s1
ffffffffc0200972:	00004617          	auipc	a2,0x4
ffffffffc0200976:	e2660613          	addi	a2,a2,-474 # ffffffffc0204798 <commands+0x338>
ffffffffc020097a:	0d800593          	li	a1,216
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	01a50513          	addi	a0,a0,26 # ffffffffc0204998 <commands+0x538>
ffffffffc0200986:	9efff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	e2e50513          	addi	a0,a0,-466 # ffffffffc02047b8 <commands+0x358>
ffffffffc0200992:	bf89                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	e3c50513          	addi	a0,a0,-452 # ffffffffc02047d0 <commands+0x370>
ffffffffc020099c:	f22ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a0:	8522                	mv	a0,s0
ffffffffc02009a2:	b5fff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a6:	84aa                	mv	s1,a0
ffffffffc02009a8:	f20505e3          	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
ffffffffc02009ae:	db1ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b2:	86a6                	mv	a3,s1
ffffffffc02009b4:	00004617          	auipc	a2,0x4
ffffffffc02009b8:	de460613          	addi	a2,a2,-540 # ffffffffc0204798 <commands+0x338>
ffffffffc02009bc:	0e200593          	li	a1,226
ffffffffc02009c0:	00004517          	auipc	a0,0x4
ffffffffc02009c4:	fd850513          	addi	a0,a0,-40 # ffffffffc0204998 <commands+0x538>
ffffffffc02009c8:	9adff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	e1c50513          	addi	a0,a0,-484 # ffffffffc02047e8 <commands+0x388>
ffffffffc02009d4:	bf01                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	e3250513          	addi	a0,a0,-462 # ffffffffc0204808 <commands+0x3a8>
ffffffffc02009de:	b719                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009e0:	00004517          	auipc	a0,0x4
ffffffffc02009e4:	e4850513          	addi	a0,a0,-440 # ffffffffc0204828 <commands+0x3c8>
ffffffffc02009e8:	bdf5                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	e5e50513          	addi	a0,a0,-418 # ffffffffc0204848 <commands+0x3e8>
ffffffffc02009f2:	bdcd                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009f4:	00004517          	auipc	a0,0x4
ffffffffc02009f8:	e7450513          	addi	a0,a0,-396 # ffffffffc0204868 <commands+0x408>
ffffffffc02009fc:	b5e5                	j	ffffffffc02008e4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009fe:	00004517          	auipc	a0,0x4
ffffffffc0200a02:	e8250513          	addi	a0,a0,-382 # ffffffffc0204880 <commands+0x420>
ffffffffc0200a06:	eb8ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a0a:	8522                	mv	a0,s0
ffffffffc0200a0c:	af5ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200a10:	84aa                	mv	s1,a0
ffffffffc0200a12:	ec0500e3          	beqz	a0,ffffffffc02008d2 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a16:	8522                	mv	a0,s0
ffffffffc0200a18:	d47ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a1c:	86a6                	mv	a3,s1
ffffffffc0200a1e:	00004617          	auipc	a2,0x4
ffffffffc0200a22:	d7a60613          	addi	a2,a2,-646 # ffffffffc0204798 <commands+0x338>
ffffffffc0200a26:	0f800593          	li	a1,248
ffffffffc0200a2a:	00004517          	auipc	a0,0x4
ffffffffc0200a2e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0204998 <commands+0x538>
ffffffffc0200a32:	943ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc0200a36:	6442                	ld	s0,16(sp)
ffffffffc0200a38:	60e2                	ld	ra,24(sp)
ffffffffc0200a3a:	64a2                	ld	s1,8(sp)
ffffffffc0200a3c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a3e:	d21ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc0200a42:	d1dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a46:	8522                	mv	a0,s0
ffffffffc0200a48:	d17ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a4c:	86a6                	mv	a3,s1
ffffffffc0200a4e:	00004617          	auipc	a2,0x4
ffffffffc0200a52:	d4a60613          	addi	a2,a2,-694 # ffffffffc0204798 <commands+0x338>
ffffffffc0200a56:	0ff00593          	li	a1,255
ffffffffc0200a5a:	00004517          	auipc	a0,0x4
ffffffffc0200a5e:	f3e50513          	addi	a0,a0,-194 # ffffffffc0204998 <commands+0x538>
ffffffffc0200a62:	913ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a66 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a66:	11853783          	ld	a5,280(a0)
ffffffffc0200a6a:	0007c463          	bltz	a5,ffffffffc0200a72 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a6e:	e27ff06f          	j	ffffffffc0200894 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a72:	d4fff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a80 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a80:	14011073          	csrw	sscratch,sp
ffffffffc0200a84:	712d                	addi	sp,sp,-288
ffffffffc0200a86:	e406                	sd	ra,8(sp)
ffffffffc0200a88:	ec0e                	sd	gp,24(sp)
ffffffffc0200a8a:	f012                	sd	tp,32(sp)
ffffffffc0200a8c:	f416                	sd	t0,40(sp)
ffffffffc0200a8e:	f81a                	sd	t1,48(sp)
ffffffffc0200a90:	fc1e                	sd	t2,56(sp)
ffffffffc0200a92:	e0a2                	sd	s0,64(sp)
ffffffffc0200a94:	e4a6                	sd	s1,72(sp)
ffffffffc0200a96:	e8aa                	sd	a0,80(sp)
ffffffffc0200a98:	ecae                	sd	a1,88(sp)
ffffffffc0200a9a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a9c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a9e:	f8ba                	sd	a4,112(sp)
ffffffffc0200aa0:	fcbe                	sd	a5,120(sp)
ffffffffc0200aa2:	e142                	sd	a6,128(sp)
ffffffffc0200aa4:	e546                	sd	a7,136(sp)
ffffffffc0200aa6:	e94a                	sd	s2,144(sp)
ffffffffc0200aa8:	ed4e                	sd	s3,152(sp)
ffffffffc0200aaa:	f152                	sd	s4,160(sp)
ffffffffc0200aac:	f556                	sd	s5,168(sp)
ffffffffc0200aae:	f95a                	sd	s6,176(sp)
ffffffffc0200ab0:	fd5e                	sd	s7,184(sp)
ffffffffc0200ab2:	e1e2                	sd	s8,192(sp)
ffffffffc0200ab4:	e5e6                	sd	s9,200(sp)
ffffffffc0200ab6:	e9ea                	sd	s10,208(sp)
ffffffffc0200ab8:	edee                	sd	s11,216(sp)
ffffffffc0200aba:	f1f2                	sd	t3,224(sp)
ffffffffc0200abc:	f5f6                	sd	t4,232(sp)
ffffffffc0200abe:	f9fa                	sd	t5,240(sp)
ffffffffc0200ac0:	fdfe                	sd	t6,248(sp)
ffffffffc0200ac2:	14002473          	csrr	s0,sscratch
ffffffffc0200ac6:	100024f3          	csrr	s1,sstatus
ffffffffc0200aca:	14102973          	csrr	s2,sepc
ffffffffc0200ace:	143029f3          	csrr	s3,stval
ffffffffc0200ad2:	14202a73          	csrr	s4,scause
ffffffffc0200ad6:	e822                	sd	s0,16(sp)
ffffffffc0200ad8:	e226                	sd	s1,256(sp)
ffffffffc0200ada:	e64a                	sd	s2,264(sp)
ffffffffc0200adc:	ea4e                	sd	s3,272(sp)
ffffffffc0200ade:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ae0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ae2:	f85ff0ef          	jal	ra,ffffffffc0200a66 <trap>

ffffffffc0200ae6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ae6:	6492                	ld	s1,256(sp)
ffffffffc0200ae8:	6932                	ld	s2,264(sp)
ffffffffc0200aea:	10049073          	csrw	sstatus,s1
ffffffffc0200aee:	14191073          	csrw	sepc,s2
ffffffffc0200af2:	60a2                	ld	ra,8(sp)
ffffffffc0200af4:	61e2                	ld	gp,24(sp)
ffffffffc0200af6:	7202                	ld	tp,32(sp)
ffffffffc0200af8:	72a2                	ld	t0,40(sp)
ffffffffc0200afa:	7342                	ld	t1,48(sp)
ffffffffc0200afc:	73e2                	ld	t2,56(sp)
ffffffffc0200afe:	6406                	ld	s0,64(sp)
ffffffffc0200b00:	64a6                	ld	s1,72(sp)
ffffffffc0200b02:	6546                	ld	a0,80(sp)
ffffffffc0200b04:	65e6                	ld	a1,88(sp)
ffffffffc0200b06:	7606                	ld	a2,96(sp)
ffffffffc0200b08:	76a6                	ld	a3,104(sp)
ffffffffc0200b0a:	7746                	ld	a4,112(sp)
ffffffffc0200b0c:	77e6                	ld	a5,120(sp)
ffffffffc0200b0e:	680a                	ld	a6,128(sp)
ffffffffc0200b10:	68aa                	ld	a7,136(sp)
ffffffffc0200b12:	694a                	ld	s2,144(sp)
ffffffffc0200b14:	69ea                	ld	s3,152(sp)
ffffffffc0200b16:	7a0a                	ld	s4,160(sp)
ffffffffc0200b18:	7aaa                	ld	s5,168(sp)
ffffffffc0200b1a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b1c:	7bea                	ld	s7,184(sp)
ffffffffc0200b1e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b20:	6cae                	ld	s9,200(sp)
ffffffffc0200b22:	6d4e                	ld	s10,208(sp)
ffffffffc0200b24:	6dee                	ld	s11,216(sp)
ffffffffc0200b26:	7e0e                	ld	t3,224(sp)
ffffffffc0200b28:	7eae                	ld	t4,232(sp)
ffffffffc0200b2a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b2c:	7fee                	ld	t6,248(sp)
ffffffffc0200b2e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b30:	10200073          	sret
	...

ffffffffc0200b40 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b40:	00011797          	auipc	a5,0x11
ffffffffc0200b44:	94078793          	addi	a5,a5,-1728 # ffffffffc0211480 <free_area>
ffffffffc0200b48:	e79c                	sd	a5,8(a5)
ffffffffc0200b4a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b4c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b50:	8082                	ret

ffffffffc0200b52 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b52:	00011517          	auipc	a0,0x11
ffffffffc0200b56:	93e56503          	lwu	a0,-1730(a0) # ffffffffc0211490 <free_area+0x10>
ffffffffc0200b5a:	8082                	ret

ffffffffc0200b5c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b5c:	715d                	addi	sp,sp,-80
ffffffffc0200b5e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b60:	00011917          	auipc	s2,0x11
ffffffffc0200b64:	92090913          	addi	s2,s2,-1760 # ffffffffc0211480 <free_area>
ffffffffc0200b68:	00893783          	ld	a5,8(s2)
ffffffffc0200b6c:	e486                	sd	ra,72(sp)
ffffffffc0200b6e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b70:	fc26                	sd	s1,56(sp)
ffffffffc0200b72:	f44e                	sd	s3,40(sp)
ffffffffc0200b74:	f052                	sd	s4,32(sp)
ffffffffc0200b76:	ec56                	sd	s5,24(sp)
ffffffffc0200b78:	e85a                	sd	s6,16(sp)
ffffffffc0200b7a:	e45e                	sd	s7,8(sp)
ffffffffc0200b7c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b7e:	31278f63          	beq	a5,s2,ffffffffc0200e9c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b82:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b86:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b88:	8b05                	andi	a4,a4,1
ffffffffc0200b8a:	30070d63          	beqz	a4,ffffffffc0200ea4 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b8e:	4401                	li	s0,0
ffffffffc0200b90:	4481                	li	s1,0
ffffffffc0200b92:	a031                	j	ffffffffc0200b9e <default_check+0x42>
ffffffffc0200b94:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b98:	8b09                	andi	a4,a4,2
ffffffffc0200b9a:	30070563          	beqz	a4,ffffffffc0200ea4 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ba2:	679c                	ld	a5,8(a5)
ffffffffc0200ba4:	2485                	addiw	s1,s1,1
ffffffffc0200ba6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ba8:	ff2796e3          	bne	a5,s2,ffffffffc0200b94 <default_check+0x38>
ffffffffc0200bac:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200bae:	3ef000ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0200bb2:	75351963          	bne	a0,s3,ffffffffc0201304 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb6:	4505                	li	a0,1
ffffffffc0200bb8:	317000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bbc:	8a2a                	mv	s4,a0
ffffffffc0200bbe:	48050363          	beqz	a0,ffffffffc0201044 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bc2:	4505                	li	a0,1
ffffffffc0200bc4:	30b000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bc8:	89aa                	mv	s3,a0
ffffffffc0200bca:	74050d63          	beqz	a0,ffffffffc0201324 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200bce:	4505                	li	a0,1
ffffffffc0200bd0:	2ff000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200bd4:	8aaa                	mv	s5,a0
ffffffffc0200bd6:	4e050763          	beqz	a0,ffffffffc02010c4 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bda:	2f3a0563          	beq	s4,s3,ffffffffc0200ec4 <default_check+0x368>
ffffffffc0200bde:	2eaa0363          	beq	s4,a0,ffffffffc0200ec4 <default_check+0x368>
ffffffffc0200be2:	2ea98163          	beq	s3,a0,ffffffffc0200ec4 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200be6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bea:	2e079d63          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
ffffffffc0200bee:	0009a783          	lw	a5,0(s3)
ffffffffc0200bf2:	2e079963          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
ffffffffc0200bf6:	411c                	lw	a5,0(a0)
ffffffffc0200bf8:	2e079663          	bnez	a5,ffffffffc0200ee4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bfc:	00011797          	auipc	a5,0x11
ffffffffc0200c00:	8b478793          	addi	a5,a5,-1868 # ffffffffc02114b0 <pages>
ffffffffc0200c04:	639c                	ld	a5,0(a5)
ffffffffc0200c06:	00004717          	auipc	a4,0x4
ffffffffc0200c0a:	12270713          	addi	a4,a4,290 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0200c0e:	630c                	ld	a1,0(a4)
ffffffffc0200c10:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c14:	870d                	srai	a4,a4,0x3
ffffffffc0200c16:	02b70733          	mul	a4,a4,a1
ffffffffc0200c1a:	00005697          	auipc	a3,0x5
ffffffffc0200c1e:	57e68693          	addi	a3,a3,1406 # ffffffffc0206198 <nbase>
ffffffffc0200c22:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c24:	00011697          	auipc	a3,0x11
ffffffffc0200c28:	83c68693          	addi	a3,a3,-1988 # ffffffffc0211460 <npage>
ffffffffc0200c2c:	6294                	ld	a3,0(a3)
ffffffffc0200c2e:	06b2                	slli	a3,a3,0xc
ffffffffc0200c30:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c32:	0732                	slli	a4,a4,0xc
ffffffffc0200c34:	2cd77863          	bleu	a3,a4,ffffffffc0200f04 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c38:	40f98733          	sub	a4,s3,a5
ffffffffc0200c3c:	870d                	srai	a4,a4,0x3
ffffffffc0200c3e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c42:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c44:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c46:	4ed77f63          	bleu	a3,a4,ffffffffc0201144 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c4a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c4e:	878d                	srai	a5,a5,0x3
ffffffffc0200c50:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c56:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c58:	34d7f663          	bleu	a3,a5,ffffffffc0200fa4 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c5c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c5e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c62:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c66:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c6a:	00011797          	auipc	a5,0x11
ffffffffc0200c6e:	8127bf23          	sd	s2,-2018(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0200c72:	00011797          	auipc	a5,0x11
ffffffffc0200c76:	8127b723          	sd	s2,-2034(a5) # ffffffffc0211480 <free_area>
    nr_free = 0;
ffffffffc0200c7a:	00011797          	auipc	a5,0x11
ffffffffc0200c7e:	8007ab23          	sw	zero,-2026(a5) # ffffffffc0211490 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c82:	24d000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200c86:	2e051f63          	bnez	a0,ffffffffc0200f84 <default_check+0x428>
    free_page(p0);
ffffffffc0200c8a:	4585                	li	a1,1
ffffffffc0200c8c:	8552                	mv	a0,s4
ffffffffc0200c8e:	2c9000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p1);
ffffffffc0200c92:	4585                	li	a1,1
ffffffffc0200c94:	854e                	mv	a0,s3
ffffffffc0200c96:	2c1000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200c9a:	4585                	li	a1,1
ffffffffc0200c9c:	8556                	mv	a0,s5
ffffffffc0200c9e:	2b9000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(nr_free == 3);
ffffffffc0200ca2:	01092703          	lw	a4,16(s2)
ffffffffc0200ca6:	478d                	li	a5,3
ffffffffc0200ca8:	2af71e63          	bne	a4,a5,ffffffffc0200f64 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cac:	4505                	li	a0,1
ffffffffc0200cae:	221000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cb2:	89aa                	mv	s3,a0
ffffffffc0200cb4:	28050863          	beqz	a0,ffffffffc0200f44 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cb8:	4505                	li	a0,1
ffffffffc0200cba:	215000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cbe:	8aaa                	mv	s5,a0
ffffffffc0200cc0:	3e050263          	beqz	a0,ffffffffc02010a4 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	209000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cca:	8a2a                	mv	s4,a0
ffffffffc0200ccc:	3a050c63          	beqz	a0,ffffffffc0201084 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	1fd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cd6:	38051763          	bnez	a0,ffffffffc0201064 <default_check+0x508>
    free_page(p0);
ffffffffc0200cda:	4585                	li	a1,1
ffffffffc0200cdc:	854e                	mv	a0,s3
ffffffffc0200cde:	279000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ce2:	00893783          	ld	a5,8(s2)
ffffffffc0200ce6:	23278f63          	beq	a5,s2,ffffffffc0200f24 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200cea:	4505                	li	a0,1
ffffffffc0200cec:	1e3000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cf0:	32a99a63          	bne	s3,a0,ffffffffc0201024 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	1d9000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200cfa:	30051563          	bnez	a0,ffffffffc0201004 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cfe:	01092783          	lw	a5,16(s2)
ffffffffc0200d02:	2e079163          	bnez	a5,ffffffffc0200fe4 <default_check+0x488>
    free_page(p);
ffffffffc0200d06:	854e                	mv	a0,s3
ffffffffc0200d08:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d0a:	00010797          	auipc	a5,0x10
ffffffffc0200d0e:	7787bb23          	sd	s8,1910(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d12:	00010797          	auipc	a5,0x10
ffffffffc0200d16:	7777bb23          	sd	s7,1910(a5) # ffffffffc0211488 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d1a:	00010797          	auipc	a5,0x10
ffffffffc0200d1e:	7767ab23          	sw	s6,1910(a5) # ffffffffc0211490 <free_area+0x10>
    free_page(p);
ffffffffc0200d22:	235000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p1);
ffffffffc0200d26:	4585                	li	a1,1
ffffffffc0200d28:	8556                	mv	a0,s5
ffffffffc0200d2a:	22d000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200d2e:	4585                	li	a1,1
ffffffffc0200d30:	8552                	mv	a0,s4
ffffffffc0200d32:	225000ef          	jal	ra,ffffffffc0201756 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d36:	4515                	li	a0,5
ffffffffc0200d38:	197000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d3c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d3e:	28050363          	beqz	a0,ffffffffc0200fc4 <default_check+0x468>
ffffffffc0200d42:	651c                	ld	a5,8(a0)
ffffffffc0200d44:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d46:	8b85                	andi	a5,a5,1
ffffffffc0200d48:	54079e63          	bnez	a5,ffffffffc02012a4 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d4e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d52:	00893a83          	ld	s5,8(s2)
ffffffffc0200d56:	00010797          	auipc	a5,0x10
ffffffffc0200d5a:	7327b523          	sd	s2,1834(a5) # ffffffffc0211480 <free_area>
ffffffffc0200d5e:	00010797          	auipc	a5,0x10
ffffffffc0200d62:	7327b523          	sd	s2,1834(a5) # ffffffffc0211488 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d66:	169000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d6a:	50051d63          	bnez	a0,ffffffffc0201284 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d6e:	09098a13          	addi	s4,s3,144
ffffffffc0200d72:	8552                	mv	a0,s4
ffffffffc0200d74:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d76:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d7a:	00010797          	auipc	a5,0x10
ffffffffc0200d7e:	7007ab23          	sw	zero,1814(a5) # ffffffffc0211490 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d82:	1d5000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d86:	4511                	li	a0,4
ffffffffc0200d88:	147000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200d8c:	4c051c63          	bnez	a0,ffffffffc0201264 <default_check+0x708>
ffffffffc0200d90:	0989b783          	ld	a5,152(s3)
ffffffffc0200d94:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d96:	8b85                	andi	a5,a5,1
ffffffffc0200d98:	4a078663          	beqz	a5,ffffffffc0201244 <default_check+0x6e8>
ffffffffc0200d9c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200da0:	478d                	li	a5,3
ffffffffc0200da2:	4af71163          	bne	a4,a5,ffffffffc0201244 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200da6:	450d                	li	a0,3
ffffffffc0200da8:	127000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200dac:	8c2a                	mv	s8,a0
ffffffffc0200dae:	46050b63          	beqz	a0,ffffffffc0201224 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200db2:	4505                	li	a0,1
ffffffffc0200db4:	11b000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200db8:	44051663          	bnez	a0,ffffffffc0201204 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200dbc:	438a1463          	bne	s4,s8,ffffffffc02011e4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	854e                	mv	a0,s3
ffffffffc0200dc4:	193000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_pages(p1, 3);
ffffffffc0200dc8:	458d                	li	a1,3
ffffffffc0200dca:	8552                	mv	a0,s4
ffffffffc0200dcc:	18b000ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0200dd0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200dd4:	04898c13          	addi	s8,s3,72
ffffffffc0200dd8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dda:	8b85                	andi	a5,a5,1
ffffffffc0200ddc:	3e078463          	beqz	a5,ffffffffc02011c4 <default_check+0x668>
ffffffffc0200de0:	0189a703          	lw	a4,24(s3)
ffffffffc0200de4:	4785                	li	a5,1
ffffffffc0200de6:	3cf71f63          	bne	a4,a5,ffffffffc02011c4 <default_check+0x668>
ffffffffc0200dea:	008a3783          	ld	a5,8(s4)
ffffffffc0200dee:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200df0:	8b85                	andi	a5,a5,1
ffffffffc0200df2:	3a078963          	beqz	a5,ffffffffc02011a4 <default_check+0x648>
ffffffffc0200df6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dfa:	478d                	li	a5,3
ffffffffc0200dfc:	3af71463          	bne	a4,a5,ffffffffc02011a4 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e00:	4505                	li	a0,1
ffffffffc0200e02:	0cd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e06:	36a99f63          	bne	s3,a0,ffffffffc0201184 <default_check+0x628>
    free_page(p0);
ffffffffc0200e0a:	4585                	li	a1,1
ffffffffc0200e0c:	14b000ef          	jal	ra,ffffffffc0201756 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e10:	4509                	li	a0,2
ffffffffc0200e12:	0bd000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e16:	34aa1763          	bne	s4,a0,ffffffffc0201164 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200e1a:	4589                	li	a1,2
ffffffffc0200e1c:	13b000ef          	jal	ra,ffffffffc0201756 <free_pages>
    free_page(p2);
ffffffffc0200e20:	4585                	li	a1,1
ffffffffc0200e22:	8562                	mv	a0,s8
ffffffffc0200e24:	133000ef          	jal	ra,ffffffffc0201756 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e28:	4515                	li	a0,5
ffffffffc0200e2a:	0a5000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e2e:	89aa                	mv	s3,a0
ffffffffc0200e30:	48050a63          	beqz	a0,ffffffffc02012c4 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200e34:	4505                	li	a0,1
ffffffffc0200e36:	099000ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0200e3a:	2e051563          	bnez	a0,ffffffffc0201124 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200e3e:	01092783          	lw	a5,16(s2)
ffffffffc0200e42:	2c079163          	bnez	a5,ffffffffc0201104 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e46:	4595                	li	a1,5
ffffffffc0200e48:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e4a:	00010797          	auipc	a5,0x10
ffffffffc0200e4e:	6577a323          	sw	s7,1606(a5) # ffffffffc0211490 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e52:	00010797          	auipc	a5,0x10
ffffffffc0200e56:	6367b723          	sd	s6,1582(a5) # ffffffffc0211480 <free_area>
ffffffffc0200e5a:	00010797          	auipc	a5,0x10
ffffffffc0200e5e:	6357b723          	sd	s5,1582(a5) # ffffffffc0211488 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e62:	0f5000ef          	jal	ra,ffffffffc0201756 <free_pages>
    return listelm->next;
ffffffffc0200e66:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e6a:	01278963          	beq	a5,s2,ffffffffc0200e7c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e6e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e72:	679c                	ld	a5,8(a5)
ffffffffc0200e74:	34fd                	addiw	s1,s1,-1
ffffffffc0200e76:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e78:	ff279be3          	bne	a5,s2,ffffffffc0200e6e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e7c:	26049463          	bnez	s1,ffffffffc02010e4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e80:	46041263          	bnez	s0,ffffffffc02012e4 <default_check+0x788>
}
ffffffffc0200e84:	60a6                	ld	ra,72(sp)
ffffffffc0200e86:	6406                	ld	s0,64(sp)
ffffffffc0200e88:	74e2                	ld	s1,56(sp)
ffffffffc0200e8a:	7942                	ld	s2,48(sp)
ffffffffc0200e8c:	79a2                	ld	s3,40(sp)
ffffffffc0200e8e:	7a02                	ld	s4,32(sp)
ffffffffc0200e90:	6ae2                	ld	s5,24(sp)
ffffffffc0200e92:	6b42                	ld	s6,16(sp)
ffffffffc0200e94:	6ba2                	ld	s7,8(sp)
ffffffffc0200e96:	6c02                	ld	s8,0(sp)
ffffffffc0200e98:	6161                	addi	sp,sp,80
ffffffffc0200e9a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e9e:	4401                	li	s0,0
ffffffffc0200ea0:	4481                	li	s1,0
ffffffffc0200ea2:	b331                	j	ffffffffc0200bae <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	e9460613          	addi	a2,a2,-364 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200eb4:	0f000593          	li	a1,240
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	ea050513          	addi	a0,a0,-352 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200ec0:	cb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	f2c68693          	addi	a3,a3,-212 # ffffffffc0204df0 <commands+0x990>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	e7460613          	addi	a2,a2,-396 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200ed4:	0bd00593          	li	a1,189
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200ee0:	c94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	f3468693          	addi	a3,a3,-204 # ffffffffc0204e18 <commands+0x9b8>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	e5460613          	addi	a2,a2,-428 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200ef4:	0be00593          	li	a1,190
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	e6050513          	addi	a0,a0,-416 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200f00:	c74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	f5468693          	addi	a3,a3,-172 # ffffffffc0204e58 <commands+0x9f8>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	e3460613          	addi	a2,a2,-460 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200f14:	0c000593          	li	a1,192
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	e4050513          	addi	a0,a0,-448 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200f20:	c54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	fbc68693          	addi	a3,a3,-68 # ffffffffc0204ee0 <commands+0xa80>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	e1460613          	addi	a2,a2,-492 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200f34:	0d900593          	li	a1,217
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200f40:	c34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204d90 <commands+0x930>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	df460613          	addi	a2,a2,-524 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200f54:	0d200593          	li	a1,210
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200f60:	c14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	f6c68693          	addi	a3,a3,-148 # ffffffffc0204ed0 <commands+0xa70>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	dd460613          	addi	a2,a2,-556 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200f74:	0d000593          	li	a1,208
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	de050513          	addi	a0,a0,-544 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200f80:	bf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	f3468693          	addi	a3,a3,-204 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	db460613          	addi	a2,a2,-588 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200f94:	0cb00593          	li	a1,203
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	dc050513          	addi	a0,a0,-576 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200fa0:	bd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	ef468693          	addi	a3,a3,-268 # ffffffffc0204e98 <commands+0xa38>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	d9460613          	addi	a2,a2,-620 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200fb4:	0c200593          	li	a1,194
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	da050513          	addi	a0,a0,-608 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200fc0:	bb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	f6468693          	addi	a3,a3,-156 # ffffffffc0204f28 <commands+0xac8>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200fd4:	0f800593          	li	a1,248
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0200fe0:	b94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	f3468693          	addi	a3,a3,-204 # ffffffffc0204f18 <commands+0xab8>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	d5460613          	addi	a2,a2,-684 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0200ff4:	0df00593          	li	a1,223
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	d6050513          	addi	a0,a0,-672 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201000:	b74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	eb468693          	addi	a3,a3,-332 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	d3460613          	addi	a2,a2,-716 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201014:	0dd00593          	li	a1,221
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201020:	b54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	ed468693          	addi	a3,a3,-300 # ffffffffc0204ef8 <commands+0xa98>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	d1460613          	addi	a2,a2,-748 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201034:	0dc00593          	li	a1,220
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201040:	b34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204d90 <commands+0x930>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	cf460613          	addi	a2,a2,-780 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201054:	0b900593          	li	a1,185
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201060:	b14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	e5468693          	addi	a3,a3,-428 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	cd460613          	addi	a2,a2,-812 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201074:	0d600593          	li	a1,214
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201080:	af4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204dd0 <commands+0x970>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	cb460613          	addi	a2,a2,-844 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201094:	0d400593          	li	a1,212
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	cc050513          	addi	a0,a0,-832 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02010a0:	ad4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204db0 <commands+0x950>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	c9460613          	addi	a2,a2,-876 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02010b4:	0d300593          	li	a1,211
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	ca050513          	addi	a0,a0,-864 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02010c0:	ab4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204dd0 <commands+0x970>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02010d4:	0bb00593          	li	a1,187
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02010e0:	a94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	f9468693          	addi	a3,a3,-108 # ffffffffc0205078 <commands+0xc18>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	c5460613          	addi	a2,a2,-940 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02010f4:	12500593          	li	a1,293
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	c6050513          	addi	a0,a0,-928 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201100:	a74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	e1468693          	addi	a3,a3,-492 # ffffffffc0204f18 <commands+0xab8>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	c3460613          	addi	a2,a2,-972 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201114:	11a00593          	li	a1,282
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201120:	a54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	d9468693          	addi	a3,a3,-620 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201134:	11800593          	li	a1,280
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201140:	a34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	d3468693          	addi	a3,a3,-716 # ffffffffc0204e78 <commands+0xa18>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201154:	0c100593          	li	a1,193
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201160:	a14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	ed468693          	addi	a3,a3,-300 # ffffffffc0205038 <commands+0xbd8>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201174:	11200593          	li	a1,274
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201180:	9f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	e9468693          	addi	a3,a3,-364 # ffffffffc0205018 <commands+0xbb8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201194:	11000593          	li	a1,272
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02011a0:	9d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204ff0 <commands+0xb90>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02011b4:	10e00593          	li	a1,270
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02011c0:	9b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	e0468693          	addi	a3,a3,-508 # ffffffffc0204fc8 <commands+0xb68>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02011d4:	10d00593          	li	a1,269
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02011e0:	994ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	dd468693          	addi	a3,a3,-556 # ffffffffc0204fb8 <commands+0xb58>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02011f4:	10800593          	li	a1,264
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201200:	974ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	cb468693          	addi	a3,a3,-844 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201214:	10700593          	li	a1,263
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201220:	954ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	d7468693          	addi	a3,a3,-652 # ffffffffc0204f98 <commands+0xb38>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201234:	10600593          	li	a1,262
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201240:	934ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	d2468693          	addi	a3,a3,-732 # ffffffffc0204f68 <commands+0xb08>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	af460613          	addi	a2,a2,-1292 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201254:	10500593          	li	a1,261
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201260:	914ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	cec68693          	addi	a3,a3,-788 # ffffffffc0204f50 <commands+0xaf0>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201274:	10400593          	li	a1,260
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201280:	8f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	c3468693          	addi	a3,a3,-972 # ffffffffc0204eb8 <commands+0xa58>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201294:	0fe00593          	li	a1,254
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02012a0:	8d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	c9468693          	addi	a3,a3,-876 # ffffffffc0204f38 <commands+0xad8>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02012b4:	0f900593          	li	a1,249
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02012c0:	8b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	d9468693          	addi	a3,a3,-620 # ffffffffc0205058 <commands+0xbf8>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02012d4:	11700593          	li	a1,279
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02012e0:	894ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc02012e4:	00004697          	auipc	a3,0x4
ffffffffc02012e8:	da468693          	addi	a3,a3,-604 # ffffffffc0205088 <commands+0xc28>
ffffffffc02012ec:	00004617          	auipc	a2,0x4
ffffffffc02012f0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02012f4:	12600593          	li	a1,294
ffffffffc02012f8:	00004517          	auipc	a0,0x4
ffffffffc02012fc:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201300:	874ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201304:	00004697          	auipc	a3,0x4
ffffffffc0201308:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0204d70 <commands+0x910>
ffffffffc020130c:	00004617          	auipc	a2,0x4
ffffffffc0201310:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201314:	0f300593          	li	a1,243
ffffffffc0201318:	00004517          	auipc	a0,0x4
ffffffffc020131c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201320:	854ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201324:	00004697          	auipc	a3,0x4
ffffffffc0201328:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0204db0 <commands+0x950>
ffffffffc020132c:	00004617          	auipc	a2,0x4
ffffffffc0201330:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201334:	0ba00593          	li	a1,186
ffffffffc0201338:	00004517          	auipc	a0,0x4
ffffffffc020133c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc0201340:	834ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201344 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201344:	1141                	addi	sp,sp,-16
ffffffffc0201346:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201348:	18058063          	beqz	a1,ffffffffc02014c8 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020134c:	00359693          	slli	a3,a1,0x3
ffffffffc0201350:	96ae                	add	a3,a3,a1
ffffffffc0201352:	068e                	slli	a3,a3,0x3
ffffffffc0201354:	96aa                	add	a3,a3,a0
ffffffffc0201356:	02d50d63          	beq	a0,a3,ffffffffc0201390 <default_free_pages+0x4c>
ffffffffc020135a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020135c:	8b85                	andi	a5,a5,1
ffffffffc020135e:	14079563          	bnez	a5,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc0201362:	651c                	ld	a5,8(a0)
ffffffffc0201364:	8385                	srli	a5,a5,0x1
ffffffffc0201366:	8b85                	andi	a5,a5,1
ffffffffc0201368:	14079063          	bnez	a5,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc020136c:	87aa                	mv	a5,a0
ffffffffc020136e:	a809                	j	ffffffffc0201380 <default_free_pages+0x3c>
ffffffffc0201370:	6798                	ld	a4,8(a5)
ffffffffc0201372:	8b05                	andi	a4,a4,1
ffffffffc0201374:	12071a63          	bnez	a4,ffffffffc02014a8 <default_free_pages+0x164>
ffffffffc0201378:	6798                	ld	a4,8(a5)
ffffffffc020137a:	8b09                	andi	a4,a4,2
ffffffffc020137c:	12071663          	bnez	a4,ffffffffc02014a8 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201380:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201384:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201388:	04878793          	addi	a5,a5,72
ffffffffc020138c:	fed792e3          	bne	a5,a3,ffffffffc0201370 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201390:	2581                	sext.w	a1,a1
ffffffffc0201392:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201394:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201398:	4789                	li	a5,2
ffffffffc020139a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020139e:	00010697          	auipc	a3,0x10
ffffffffc02013a2:	0e268693          	addi	a3,a3,226 # ffffffffc0211480 <free_area>
ffffffffc02013a6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013a8:	669c                	ld	a5,8(a3)
ffffffffc02013aa:	9db9                	addw	a1,a1,a4
ffffffffc02013ac:	00010717          	auipc	a4,0x10
ffffffffc02013b0:	0eb72223          	sw	a1,228(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013b4:	08d78f63          	beq	a5,a3,ffffffffc0201452 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013b8:	fe078713          	addi	a4,a5,-32
ffffffffc02013bc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013be:	4801                	li	a6,0
ffffffffc02013c0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02013c4:	00e56a63          	bltu	a0,a4,ffffffffc02013d8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc02013c8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013ca:	02d70563          	beq	a4,a3,ffffffffc02013f4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ce:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013d0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02013d4:	fee57ae3          	bleu	a4,a0,ffffffffc02013c8 <default_free_pages+0x84>
ffffffffc02013d8:	00080663          	beqz	a6,ffffffffc02013e4 <default_free_pages+0xa0>
ffffffffc02013dc:	00010817          	auipc	a6,0x10
ffffffffc02013e0:	0ab83223          	sd	a1,164(a6) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013e4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013e6:	e390                	sd	a2,0(a5)
ffffffffc02013e8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ec:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013ee:	02d59163          	bne	a1,a3,ffffffffc0201410 <default_free_pages+0xcc>
ffffffffc02013f2:	a091                	j	ffffffffc0201436 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013f6:	f514                	sd	a3,40(a0)
ffffffffc02013f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013fa:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013fc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013fe:	00d70563          	beq	a4,a3,ffffffffc0201408 <default_free_pages+0xc4>
ffffffffc0201402:	4805                	li	a6,1
ffffffffc0201404:	87ba                	mv	a5,a4
ffffffffc0201406:	b7e9                	j	ffffffffc02013d0 <default_free_pages+0x8c>
ffffffffc0201408:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020140a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020140c:	02d78163          	beq	a5,a3,ffffffffc020142e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201410:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201414:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201418:	02081713          	slli	a4,a6,0x20
ffffffffc020141c:	9301                	srli	a4,a4,0x20
ffffffffc020141e:	00371793          	slli	a5,a4,0x3
ffffffffc0201422:	97ba                	add	a5,a5,a4
ffffffffc0201424:	078e                	slli	a5,a5,0x3
ffffffffc0201426:	97b2                	add	a5,a5,a2
ffffffffc0201428:	02f50e63          	beq	a0,a5,ffffffffc0201464 <default_free_pages+0x120>
ffffffffc020142c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020142e:	fe078713          	addi	a4,a5,-32
ffffffffc0201432:	00d78d63          	beq	a5,a3,ffffffffc020144c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201436:	4d0c                	lw	a1,24(a0)
ffffffffc0201438:	02059613          	slli	a2,a1,0x20
ffffffffc020143c:	9201                	srli	a2,a2,0x20
ffffffffc020143e:	00361693          	slli	a3,a2,0x3
ffffffffc0201442:	96b2                	add	a3,a3,a2
ffffffffc0201444:	068e                	slli	a3,a3,0x3
ffffffffc0201446:	96aa                	add	a3,a3,a0
ffffffffc0201448:	04d70063          	beq	a4,a3,ffffffffc0201488 <default_free_pages+0x144>
}
ffffffffc020144c:	60a2                	ld	ra,8(sp)
ffffffffc020144e:	0141                	addi	sp,sp,16
ffffffffc0201450:	8082                	ret
ffffffffc0201452:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201454:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201458:	e398                	sd	a4,0(a5)
ffffffffc020145a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020145c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020145e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201460:	0141                	addi	sp,sp,16
ffffffffc0201462:	8082                	ret
            p->property += base->property;
ffffffffc0201464:	4d1c                	lw	a5,24(a0)
ffffffffc0201466:	0107883b          	addw	a6,a5,a6
ffffffffc020146a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020146e:	57f5                	li	a5,-3
ffffffffc0201470:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201474:	02053803          	ld	a6,32(a0)
ffffffffc0201478:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020147a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020147c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201480:	659c                	ld	a5,8(a1)
ffffffffc0201482:	01073023          	sd	a6,0(a4)
ffffffffc0201486:	b765                	j	ffffffffc020142e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201488:	ff87a703          	lw	a4,-8(a5)
ffffffffc020148c:	fe878693          	addi	a3,a5,-24
ffffffffc0201490:	9db9                	addw	a1,a1,a4
ffffffffc0201492:	cd0c                	sw	a1,24(a0)
ffffffffc0201494:	5775                	li	a4,-3
ffffffffc0201496:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020149a:	6398                	ld	a4,0(a5)
ffffffffc020149c:	679c                	ld	a5,8(a5)
}
ffffffffc020149e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014a2:	e398                	sd	a4,0(a5)
ffffffffc02014a4:	0141                	addi	sp,sp,16
ffffffffc02014a6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014a8:	00004697          	auipc	a3,0x4
ffffffffc02014ac:	bf068693          	addi	a3,a3,-1040 # ffffffffc0205098 <commands+0xc38>
ffffffffc02014b0:	00004617          	auipc	a2,0x4
ffffffffc02014b4:	89060613          	addi	a2,a2,-1904 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02014b8:	08300593          	li	a1,131
ffffffffc02014bc:	00004517          	auipc	a0,0x4
ffffffffc02014c0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02014c4:	eb1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	bf868693          	addi	a3,a3,-1032 # ffffffffc02050c0 <commands+0xc60>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	87060613          	addi	a2,a2,-1936 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02014d8:	08000593          	li	a1,128
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02014e4:	e91fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014e8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014e8:	cd51                	beqz	a0,ffffffffc0201584 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014ea:	00010597          	auipc	a1,0x10
ffffffffc02014ee:	f9658593          	addi	a1,a1,-106 # ffffffffc0211480 <free_area>
ffffffffc02014f2:	0105a803          	lw	a6,16(a1)
ffffffffc02014f6:	862a                	mv	a2,a0
ffffffffc02014f8:	02081793          	slli	a5,a6,0x20
ffffffffc02014fc:	9381                	srli	a5,a5,0x20
ffffffffc02014fe:	00a7ee63          	bltu	a5,a0,ffffffffc020151a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201502:	87ae                	mv	a5,a1
ffffffffc0201504:	a801                	j	ffffffffc0201514 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201506:	ff87a703          	lw	a4,-8(a5)
ffffffffc020150a:	02071693          	slli	a3,a4,0x20
ffffffffc020150e:	9281                	srli	a3,a3,0x20
ffffffffc0201510:	00c6f763          	bleu	a2,a3,ffffffffc020151e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201514:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201516:	feb798e3          	bne	a5,a1,ffffffffc0201506 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020151a:	4501                	li	a0,0
}
ffffffffc020151c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020151e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201522:	dd6d                	beqz	a0,ffffffffc020151c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201524:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201528:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020152c:	00060e1b          	sext.w	t3,a2
ffffffffc0201530:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201534:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201538:	02d67b63          	bleu	a3,a2,ffffffffc020156e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020153c:	00361693          	slli	a3,a2,0x3
ffffffffc0201540:	96b2                	add	a3,a3,a2
ffffffffc0201542:	068e                	slli	a3,a3,0x3
ffffffffc0201544:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201546:	41c7073b          	subw	a4,a4,t3
ffffffffc020154a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020154c:	00868613          	addi	a2,a3,8
ffffffffc0201550:	4709                	li	a4,2
ffffffffc0201552:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201556:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020155a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020155e:	0105a803          	lw	a6,16(a1)
ffffffffc0201562:	e310                	sd	a2,0(a4)
ffffffffc0201564:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201568:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020156a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020156e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201572:	00010717          	auipc	a4,0x10
ffffffffc0201576:	f1072f23          	sw	a6,-226(a4) # ffffffffc0211490 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020157a:	5775                	li	a4,-3
ffffffffc020157c:	17a1                	addi	a5,a5,-24
ffffffffc020157e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201582:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201584:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201586:	00004697          	auipc	a3,0x4
ffffffffc020158a:	b3a68693          	addi	a3,a3,-1222 # ffffffffc02050c0 <commands+0xc60>
ffffffffc020158e:	00003617          	auipc	a2,0x3
ffffffffc0201592:	7b260613          	addi	a2,a2,1970 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201596:	06200593          	li	a1,98
ffffffffc020159a:	00003517          	auipc	a0,0x3
ffffffffc020159e:	7be50513          	addi	a0,a0,1982 # ffffffffc0204d58 <commands+0x8f8>
default_alloc_pages(size_t n) {
ffffffffc02015a2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015a4:	dd1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02015a8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015a8:	1141                	addi	sp,sp,-16
ffffffffc02015aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015ac:	c1fd                	beqz	a1,ffffffffc0201692 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02015ae:	00359693          	slli	a3,a1,0x3
ffffffffc02015b2:	96ae                	add	a3,a3,a1
ffffffffc02015b4:	068e                	slli	a3,a3,0x3
ffffffffc02015b6:	96aa                	add	a3,a3,a0
ffffffffc02015b8:	02d50463          	beq	a0,a3,ffffffffc02015e0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015bc:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015be:	87aa                	mv	a5,a0
ffffffffc02015c0:	8b05                	andi	a4,a4,1
ffffffffc02015c2:	e709                	bnez	a4,ffffffffc02015cc <default_init_memmap+0x24>
ffffffffc02015c4:	a07d                	j	ffffffffc0201672 <default_init_memmap+0xca>
ffffffffc02015c6:	6798                	ld	a4,8(a5)
ffffffffc02015c8:	8b05                	andi	a4,a4,1
ffffffffc02015ca:	c745                	beqz	a4,ffffffffc0201672 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02015cc:	0007ac23          	sw	zero,24(a5)
ffffffffc02015d0:	0007b423          	sd	zero,8(a5)
ffffffffc02015d4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015d8:	04878793          	addi	a5,a5,72
ffffffffc02015dc:	fed795e3          	bne	a5,a3,ffffffffc02015c6 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015e0:	2581                	sext.w	a1,a1
ffffffffc02015e2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015e4:	4789                	li	a5,2
ffffffffc02015e6:	00850713          	addi	a4,a0,8
ffffffffc02015ea:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015ee:	00010697          	auipc	a3,0x10
ffffffffc02015f2:	e9268693          	addi	a3,a3,-366 # ffffffffc0211480 <free_area>
ffffffffc02015f6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015f8:	669c                	ld	a5,8(a3)
ffffffffc02015fa:	9db9                	addw	a1,a1,a4
ffffffffc02015fc:	00010717          	auipc	a4,0x10
ffffffffc0201600:	e8b72a23          	sw	a1,-364(a4) # ffffffffc0211490 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201604:	04d78a63          	beq	a5,a3,ffffffffc0201658 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201608:	fe078713          	addi	a4,a5,-32
ffffffffc020160c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020160e:	4801                	li	a6,0
ffffffffc0201610:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201614:	00e56a63          	bltu	a0,a4,ffffffffc0201628 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201618:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020161a:	02d70563          	beq	a4,a3,ffffffffc0201644 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020161e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201620:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201624:	fee57ae3          	bleu	a4,a0,ffffffffc0201618 <default_init_memmap+0x70>
ffffffffc0201628:	00080663          	beqz	a6,ffffffffc0201634 <default_init_memmap+0x8c>
ffffffffc020162c:	00010717          	auipc	a4,0x10
ffffffffc0201630:	e4b73a23          	sd	a1,-428(a4) # ffffffffc0211480 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201634:	6398                	ld	a4,0(a5)
}
ffffffffc0201636:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201638:	e390                	sd	a2,0(a5)
ffffffffc020163a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020163c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020163e:	f118                	sd	a4,32(a0)
ffffffffc0201640:	0141                	addi	sp,sp,16
ffffffffc0201642:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201644:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201646:	f514                	sd	a3,40(a0)
ffffffffc0201648:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020164a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020164c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020164e:	00d70e63          	beq	a4,a3,ffffffffc020166a <default_init_memmap+0xc2>
ffffffffc0201652:	4805                	li	a6,1
ffffffffc0201654:	87ba                	mv	a5,a4
ffffffffc0201656:	b7e9                	j	ffffffffc0201620 <default_init_memmap+0x78>
}
ffffffffc0201658:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020165a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020165e:	e398                	sd	a4,0(a5)
ffffffffc0201660:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201662:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201664:	f11c                	sd	a5,32(a0)
}
ffffffffc0201666:	0141                	addi	sp,sp,16
ffffffffc0201668:	8082                	ret
ffffffffc020166a:	60a2                	ld	ra,8(sp)
ffffffffc020166c:	e290                	sd	a2,0(a3)
ffffffffc020166e:	0141                	addi	sp,sp,16
ffffffffc0201670:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201672:	00004697          	auipc	a3,0x4
ffffffffc0201676:	a5668693          	addi	a3,a3,-1450 # ffffffffc02050c8 <commands+0xc68>
ffffffffc020167a:	00003617          	auipc	a2,0x3
ffffffffc020167e:	6c660613          	addi	a2,a2,1734 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0201682:	04900593          	li	a1,73
ffffffffc0201686:	00003517          	auipc	a0,0x3
ffffffffc020168a:	6d250513          	addi	a0,a0,1746 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc020168e:	ce7fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201692:	00004697          	auipc	a3,0x4
ffffffffc0201696:	a2e68693          	addi	a3,a3,-1490 # ffffffffc02050c0 <commands+0xc60>
ffffffffc020169a:	00003617          	auipc	a2,0x3
ffffffffc020169e:	6a660613          	addi	a2,a2,1702 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02016a2:	04600593          	li	a1,70
ffffffffc02016a6:	00003517          	auipc	a0,0x3
ffffffffc02016aa:	6b250513          	addi	a0,a0,1714 # ffffffffc0204d58 <commands+0x8f8>
ffffffffc02016ae:	cc7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016b2 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016b2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02016b4:	00004617          	auipc	a2,0x4
ffffffffc02016b8:	aec60613          	addi	a2,a2,-1300 # ffffffffc02051a0 <default_pmm_manager+0xc8>
ffffffffc02016bc:	06500593          	li	a1,101
ffffffffc02016c0:	00004517          	auipc	a0,0x4
ffffffffc02016c4:	b0050513          	addi	a0,a0,-1280 # ffffffffc02051c0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016c8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02016ca:	cabfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016ce <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02016ce:	715d                	addi	sp,sp,-80
ffffffffc02016d0:	e0a2                	sd	s0,64(sp)
ffffffffc02016d2:	fc26                	sd	s1,56(sp)
ffffffffc02016d4:	f84a                	sd	s2,48(sp)
ffffffffc02016d6:	f44e                	sd	s3,40(sp)
ffffffffc02016d8:	f052                	sd	s4,32(sp)
ffffffffc02016da:	ec56                	sd	s5,24(sp)
ffffffffc02016dc:	e486                	sd	ra,72(sp)
ffffffffc02016de:	842a                	mv	s0,a0
ffffffffc02016e0:	00010497          	auipc	s1,0x10
ffffffffc02016e4:	db848493          	addi	s1,s1,-584 # ffffffffc0211498 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e8:	4985                	li	s3,1
ffffffffc02016ea:	00010a17          	auipc	s4,0x10
ffffffffc02016ee:	d86a0a13          	addi	s4,s4,-634 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016f2:	0005091b          	sext.w	s2,a0
ffffffffc02016f6:	00010a97          	auipc	s5,0x10
ffffffffc02016fa:	ea2a8a93          	addi	s5,s5,-350 # ffffffffc0211598 <check_mm_struct>
ffffffffc02016fe:	a00d                	j	ffffffffc0201720 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201700:	609c                	ld	a5,0(s1)
ffffffffc0201702:	6f9c                	ld	a5,24(a5)
ffffffffc0201704:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201706:	4601                	li	a2,0
ffffffffc0201708:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020170a:	ed0d                	bnez	a0,ffffffffc0201744 <alloc_pages+0x76>
ffffffffc020170c:	0289ec63          	bltu	s3,s0,ffffffffc0201744 <alloc_pages+0x76>
ffffffffc0201710:	000a2783          	lw	a5,0(s4)
ffffffffc0201714:	2781                	sext.w	a5,a5
ffffffffc0201716:	c79d                	beqz	a5,ffffffffc0201744 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201718:	000ab503          	ld	a0,0(s5)
ffffffffc020171c:	021010ef          	jal	ra,ffffffffc0202f3c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201720:	100027f3          	csrr	a5,sstatus
ffffffffc0201724:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201726:	8522                	mv	a0,s0
ffffffffc0201728:	dfe1                	beqz	a5,ffffffffc0201700 <alloc_pages+0x32>
        intr_disable();
ffffffffc020172a:	dd1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020172e:	609c                	ld	a5,0(s1)
ffffffffc0201730:	8522                	mv	a0,s0
ffffffffc0201732:	6f9c                	ld	a5,24(a5)
ffffffffc0201734:	9782                	jalr	a5
ffffffffc0201736:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201738:	dbdfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc020173c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020173e:	4601                	li	a2,0
ffffffffc0201740:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201742:	d569                	beqz	a0,ffffffffc020170c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201744:	60a6                	ld	ra,72(sp)
ffffffffc0201746:	6406                	ld	s0,64(sp)
ffffffffc0201748:	74e2                	ld	s1,56(sp)
ffffffffc020174a:	7942                	ld	s2,48(sp)
ffffffffc020174c:	79a2                	ld	s3,40(sp)
ffffffffc020174e:	7a02                	ld	s4,32(sp)
ffffffffc0201750:	6ae2                	ld	s5,24(sp)
ffffffffc0201752:	6161                	addi	sp,sp,80
ffffffffc0201754:	8082                	ret

ffffffffc0201756 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201756:	100027f3          	csrr	a5,sstatus
ffffffffc020175a:	8b89                	andi	a5,a5,2
ffffffffc020175c:	eb89                	bnez	a5,ffffffffc020176e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020175e:	00010797          	auipc	a5,0x10
ffffffffc0201762:	d3a78793          	addi	a5,a5,-710 # ffffffffc0211498 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	0207b303          	ld	t1,32(a5)
ffffffffc020176c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020176e:	1101                	addi	sp,sp,-32
ffffffffc0201770:	ec06                	sd	ra,24(sp)
ffffffffc0201772:	e822                	sd	s0,16(sp)
ffffffffc0201774:	e426                	sd	s1,8(sp)
ffffffffc0201776:	842a                	mv	s0,a0
ffffffffc0201778:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020177a:	d81fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020177e:	00010797          	auipc	a5,0x10
ffffffffc0201782:	d1a78793          	addi	a5,a5,-742 # ffffffffc0211498 <pmm_manager>
ffffffffc0201786:	639c                	ld	a5,0(a5)
ffffffffc0201788:	85a6                	mv	a1,s1
ffffffffc020178a:	8522                	mv	a0,s0
ffffffffc020178c:	739c                	ld	a5,32(a5)
ffffffffc020178e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201790:	6442                	ld	s0,16(sp)
ffffffffc0201792:	60e2                	ld	ra,24(sp)
ffffffffc0201794:	64a2                	ld	s1,8(sp)
ffffffffc0201796:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201798:	d5dfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020179c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020179c:	100027f3          	csrr	a5,sstatus
ffffffffc02017a0:	8b89                	andi	a5,a5,2
ffffffffc02017a2:	eb89                	bnez	a5,ffffffffc02017b4 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017a4:	00010797          	auipc	a5,0x10
ffffffffc02017a8:	cf478793          	addi	a5,a5,-780 # ffffffffc0211498 <pmm_manager>
ffffffffc02017ac:	639c                	ld	a5,0(a5)
ffffffffc02017ae:	0287b303          	ld	t1,40(a5)
ffffffffc02017b2:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02017b4:	1141                	addi	sp,sp,-16
ffffffffc02017b6:	e406                	sd	ra,8(sp)
ffffffffc02017b8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02017ba:	d41fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017be:	00010797          	auipc	a5,0x10
ffffffffc02017c2:	cda78793          	addi	a5,a5,-806 # ffffffffc0211498 <pmm_manager>
ffffffffc02017c6:	639c                	ld	a5,0(a5)
ffffffffc02017c8:	779c                	ld	a5,40(a5)
ffffffffc02017ca:	9782                	jalr	a5
ffffffffc02017cc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017ce:	d27fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017d2:	8522                	mv	a0,s0
ffffffffc02017d4:	60a2                	ld	ra,8(sp)
ffffffffc02017d6:	6402                	ld	s0,0(sp)
ffffffffc02017d8:	0141                	addi	sp,sp,16
ffffffffc02017da:	8082                	ret

ffffffffc02017dc <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017dc:	715d                	addi	sp,sp,-80
ffffffffc02017de:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017e0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017e4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017e8:	048e                	slli	s1,s1,0x3
ffffffffc02017ea:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ec:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ee:	f84a                	sd	s2,48(sp)
ffffffffc02017f0:	f44e                	sd	s3,40(sp)
ffffffffc02017f2:	f052                	sd	s4,32(sp)
ffffffffc02017f4:	e486                	sd	ra,72(sp)
ffffffffc02017f6:	e0a2                	sd	s0,64(sp)
ffffffffc02017f8:	ec56                	sd	s5,24(sp)
ffffffffc02017fa:	e85a                	sd	s6,16(sp)
ffffffffc02017fc:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017fe:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201802:	892e                	mv	s2,a1
ffffffffc0201804:	8a32                	mv	s4,a2
ffffffffc0201806:	00010997          	auipc	s3,0x10
ffffffffc020180a:	c5a98993          	addi	s3,s3,-934 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020180e:	e3c9                	bnez	a5,ffffffffc0201890 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201810:	16060163          	beqz	a2,ffffffffc0201972 <get_pte+0x196>
ffffffffc0201814:	4505                	li	a0,1
ffffffffc0201816:	eb9ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc020181a:	842a                	mv	s0,a0
ffffffffc020181c:	14050b63          	beqz	a0,ffffffffc0201972 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201820:	00010b97          	auipc	s7,0x10
ffffffffc0201824:	c90b8b93          	addi	s7,s7,-880 # ffffffffc02114b0 <pages>
ffffffffc0201828:	000bb503          	ld	a0,0(s7)
ffffffffc020182c:	00003797          	auipc	a5,0x3
ffffffffc0201830:	4fc78793          	addi	a5,a5,1276 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0201834:	0007bb03          	ld	s6,0(a5)
ffffffffc0201838:	40a40533          	sub	a0,s0,a0
ffffffffc020183c:	850d                	srai	a0,a0,0x3
ffffffffc020183e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201842:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201844:	00010997          	auipc	s3,0x10
ffffffffc0201848:	c1c98993          	addi	s3,s3,-996 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020184c:	00080ab7          	lui	s5,0x80
ffffffffc0201850:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201854:	c01c                	sw	a5,0(s0)
ffffffffc0201856:	57fd                	li	a5,-1
ffffffffc0201858:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020185a:	9556                	add	a0,a0,s5
ffffffffc020185c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020185e:	0532                	slli	a0,a0,0xc
ffffffffc0201860:	16e7f063          	bleu	a4,a5,ffffffffc02019c0 <get_pte+0x1e4>
ffffffffc0201864:	00010797          	auipc	a5,0x10
ffffffffc0201868:	c3c78793          	addi	a5,a5,-964 # ffffffffc02114a0 <va_pa_offset>
ffffffffc020186c:	639c                	ld	a5,0(a5)
ffffffffc020186e:	6605                	lui	a2,0x1
ffffffffc0201870:	4581                	li	a1,0
ffffffffc0201872:	953e                	add	a0,a0,a5
ffffffffc0201874:	29b020ef          	jal	ra,ffffffffc020430e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201878:	000bb683          	ld	a3,0(s7)
ffffffffc020187c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201880:	868d                	srai	a3,a3,0x3
ffffffffc0201882:	036686b3          	mul	a3,a3,s6
ffffffffc0201886:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201888:	06aa                	slli	a3,a3,0xa
ffffffffc020188a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020188e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201890:	77fd                	lui	a5,0xfffff
ffffffffc0201892:	068a                	slli	a3,a3,0x2
ffffffffc0201894:	0009b703          	ld	a4,0(s3)
ffffffffc0201898:	8efd                	and	a3,a3,a5
ffffffffc020189a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020189e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201976 <get_pte+0x19a>
ffffffffc02018a2:	00010a97          	auipc	s5,0x10
ffffffffc02018a6:	bfea8a93          	addi	s5,s5,-1026 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02018aa:	000ab403          	ld	s0,0(s5)
ffffffffc02018ae:	01595793          	srli	a5,s2,0x15
ffffffffc02018b2:	1ff7f793          	andi	a5,a5,511
ffffffffc02018b6:	96a2                	add	a3,a3,s0
ffffffffc02018b8:	00379413          	slli	s0,a5,0x3
ffffffffc02018bc:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02018be:	6014                	ld	a3,0(s0)
ffffffffc02018c0:	0016f793          	andi	a5,a3,1
ffffffffc02018c4:	ebbd                	bnez	a5,ffffffffc020193a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02018c6:	0a0a0663          	beqz	s4,ffffffffc0201972 <get_pte+0x196>
ffffffffc02018ca:	4505                	li	a0,1
ffffffffc02018cc:	e03ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc02018d0:	84aa                	mv	s1,a0
ffffffffc02018d2:	c145                	beqz	a0,ffffffffc0201972 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018d4:	00010b97          	auipc	s7,0x10
ffffffffc02018d8:	bdcb8b93          	addi	s7,s7,-1060 # ffffffffc02114b0 <pages>
ffffffffc02018dc:	000bb503          	ld	a0,0(s7)
ffffffffc02018e0:	00003797          	auipc	a5,0x3
ffffffffc02018e4:	44878793          	addi	a5,a5,1096 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc02018e8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018ec:	40a48533          	sub	a0,s1,a0
ffffffffc02018f0:	850d                	srai	a0,a0,0x3
ffffffffc02018f2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018f6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018f8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018fc:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201900:	c09c                	sw	a5,0(s1)
ffffffffc0201902:	57fd                	li	a5,-1
ffffffffc0201904:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201906:	9552                	add	a0,a0,s4
ffffffffc0201908:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020190a:	0532                	slli	a0,a0,0xc
ffffffffc020190c:	08e7fd63          	bleu	a4,a5,ffffffffc02019a6 <get_pte+0x1ca>
ffffffffc0201910:	000ab783          	ld	a5,0(s5)
ffffffffc0201914:	6605                	lui	a2,0x1
ffffffffc0201916:	4581                	li	a1,0
ffffffffc0201918:	953e                	add	a0,a0,a5
ffffffffc020191a:	1f5020ef          	jal	ra,ffffffffc020430e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020191e:	000bb683          	ld	a3,0(s7)
ffffffffc0201922:	40d486b3          	sub	a3,s1,a3
ffffffffc0201926:	868d                	srai	a3,a3,0x3
ffffffffc0201928:	036686b3          	mul	a3,a3,s6
ffffffffc020192c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020192e:	06aa                	slli	a3,a3,0xa
ffffffffc0201930:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201934:	e014                	sd	a3,0(s0)
ffffffffc0201936:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020193a:	068a                	slli	a3,a3,0x2
ffffffffc020193c:	757d                	lui	a0,0xfffff
ffffffffc020193e:	8ee9                	and	a3,a3,a0
ffffffffc0201940:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201944:	04e7f563          	bleu	a4,a5,ffffffffc020198e <get_pte+0x1b2>
ffffffffc0201948:	000ab503          	ld	a0,0(s5)
ffffffffc020194c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201950:	1ff7f793          	andi	a5,a5,511
ffffffffc0201954:	96aa                	add	a3,a3,a0
ffffffffc0201956:	00379513          	slli	a0,a5,0x3
ffffffffc020195a:	9536                	add	a0,a0,a3
}
ffffffffc020195c:	60a6                	ld	ra,72(sp)
ffffffffc020195e:	6406                	ld	s0,64(sp)
ffffffffc0201960:	74e2                	ld	s1,56(sp)
ffffffffc0201962:	7942                	ld	s2,48(sp)
ffffffffc0201964:	79a2                	ld	s3,40(sp)
ffffffffc0201966:	7a02                	ld	s4,32(sp)
ffffffffc0201968:	6ae2                	ld	s5,24(sp)
ffffffffc020196a:	6b42                	ld	s6,16(sp)
ffffffffc020196c:	6ba2                	ld	s7,8(sp)
ffffffffc020196e:	6161                	addi	sp,sp,80
ffffffffc0201970:	8082                	ret
            return NULL;
ffffffffc0201972:	4501                	li	a0,0
ffffffffc0201974:	b7e5                	j	ffffffffc020195c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201976:	00003617          	auipc	a2,0x3
ffffffffc020197a:	7b260613          	addi	a2,a2,1970 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc020197e:	10200593          	li	a1,258
ffffffffc0201982:	00003517          	auipc	a0,0x3
ffffffffc0201986:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020198a:	9ebfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020198e:	00003617          	auipc	a2,0x3
ffffffffc0201992:	79a60613          	addi	a2,a2,1946 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc0201996:	10f00593          	li	a1,271
ffffffffc020199a:	00003517          	auipc	a0,0x3
ffffffffc020199e:	7b650513          	addi	a0,a0,1974 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02019a2:	9d3fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019a6:	86aa                	mv	a3,a0
ffffffffc02019a8:	00003617          	auipc	a2,0x3
ffffffffc02019ac:	78060613          	addi	a2,a2,1920 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc02019b0:	10b00593          	li	a1,267
ffffffffc02019b4:	00003517          	auipc	a0,0x3
ffffffffc02019b8:	79c50513          	addi	a0,a0,1948 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02019bc:	9b9fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019c0:	86aa                	mv	a3,a0
ffffffffc02019c2:	00003617          	auipc	a2,0x3
ffffffffc02019c6:	76660613          	addi	a2,a2,1894 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc02019ca:	0ff00593          	li	a1,255
ffffffffc02019ce:	00003517          	auipc	a0,0x3
ffffffffc02019d2:	78250513          	addi	a0,a0,1922 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02019d6:	99ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02019da <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019da:	1141                	addi	sp,sp,-16
ffffffffc02019dc:	e022                	sd	s0,0(sp)
ffffffffc02019de:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019e2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e4:	df9ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019e8:	c011                	beqz	s0,ffffffffc02019ec <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019ea:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019ec:	c521                	beqz	a0,ffffffffc0201a34 <get_page+0x5a>
ffffffffc02019ee:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019f0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019f2:	0017f713          	andi	a4,a5,1
ffffffffc02019f6:	e709                	bnez	a4,ffffffffc0201a00 <get_page+0x26>
}
ffffffffc02019f8:	60a2                	ld	ra,8(sp)
ffffffffc02019fa:	6402                	ld	s0,0(sp)
ffffffffc02019fc:	0141                	addi	sp,sp,16
ffffffffc02019fe:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a00:	00010717          	auipc	a4,0x10
ffffffffc0201a04:	a6070713          	addi	a4,a4,-1440 # ffffffffc0211460 <npage>
ffffffffc0201a08:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a0a:	078a                	slli	a5,a5,0x2
ffffffffc0201a0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a0e:	02e7f863          	bleu	a4,a5,ffffffffc0201a3e <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a12:	fff80537          	lui	a0,0xfff80
ffffffffc0201a16:	97aa                	add	a5,a5,a0
ffffffffc0201a18:	00010697          	auipc	a3,0x10
ffffffffc0201a1c:	a9868693          	addi	a3,a3,-1384 # ffffffffc02114b0 <pages>
ffffffffc0201a20:	6288                	ld	a0,0(a3)
ffffffffc0201a22:	60a2                	ld	ra,8(sp)
ffffffffc0201a24:	6402                	ld	s0,0(sp)
ffffffffc0201a26:	00379713          	slli	a4,a5,0x3
ffffffffc0201a2a:	97ba                	add	a5,a5,a4
ffffffffc0201a2c:	078e                	slli	a5,a5,0x3
ffffffffc0201a2e:	953e                	add	a0,a0,a5
ffffffffc0201a30:	0141                	addi	sp,sp,16
ffffffffc0201a32:	8082                	ret
ffffffffc0201a34:	60a2                	ld	ra,8(sp)
ffffffffc0201a36:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201a38:	4501                	li	a0,0
}
ffffffffc0201a3a:	0141                	addi	sp,sp,16
ffffffffc0201a3c:	8082                	ret
ffffffffc0201a3e:	c75ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201a42 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a42:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a44:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a46:	e406                	sd	ra,8(sp)
ffffffffc0201a48:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a4a:	d93ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep != NULL) {
ffffffffc0201a4e:	c511                	beqz	a0,ffffffffc0201a5a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a50:	611c                	ld	a5,0(a0)
ffffffffc0201a52:	842a                	mv	s0,a0
ffffffffc0201a54:	0017f713          	andi	a4,a5,1
ffffffffc0201a58:	e709                	bnez	a4,ffffffffc0201a62 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a5a:	60a2                	ld	ra,8(sp)
ffffffffc0201a5c:	6402                	ld	s0,0(sp)
ffffffffc0201a5e:	0141                	addi	sp,sp,16
ffffffffc0201a60:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a62:	00010717          	auipc	a4,0x10
ffffffffc0201a66:	9fe70713          	addi	a4,a4,-1538 # ffffffffc0211460 <npage>
ffffffffc0201a6a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a6c:	078a                	slli	a5,a5,0x2
ffffffffc0201a6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a70:	04e7f063          	bleu	a4,a5,ffffffffc0201ab0 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a74:	fff80737          	lui	a4,0xfff80
ffffffffc0201a78:	97ba                	add	a5,a5,a4
ffffffffc0201a7a:	00010717          	auipc	a4,0x10
ffffffffc0201a7e:	a3670713          	addi	a4,a4,-1482 # ffffffffc02114b0 <pages>
ffffffffc0201a82:	6308                	ld	a0,0(a4)
ffffffffc0201a84:	00379713          	slli	a4,a5,0x3
ffffffffc0201a88:	97ba                	add	a5,a5,a4
ffffffffc0201a8a:	078e                	slli	a5,a5,0x3
ffffffffc0201a8c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a8e:	411c                	lw	a5,0(a0)
ffffffffc0201a90:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a94:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a96:	cb09                	beqz	a4,ffffffffc0201aa8 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a98:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a9c:	12000073          	sfence.vma
}
ffffffffc0201aa0:	60a2                	ld	ra,8(sp)
ffffffffc0201aa2:	6402                	ld	s0,0(sp)
ffffffffc0201aa4:	0141                	addi	sp,sp,16
ffffffffc0201aa6:	8082                	ret
            free_page(page);
ffffffffc0201aa8:	4585                	li	a1,1
ffffffffc0201aaa:	cadff0ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0201aae:	b7ed                	j	ffffffffc0201a98 <page_remove+0x56>
ffffffffc0201ab0:	c03ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201ab4 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ab4:	7179                	addi	sp,sp,-48
ffffffffc0201ab6:	87b2                	mv	a5,a2
ffffffffc0201ab8:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aba:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201abc:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201abe:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ac0:	ec26                	sd	s1,24(sp)
ffffffffc0201ac2:	f406                	sd	ra,40(sp)
ffffffffc0201ac4:	e84a                	sd	s2,16(sp)
ffffffffc0201ac6:	e44e                	sd	s3,8(sp)
ffffffffc0201ac8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201aca:	d13ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    if (ptep == NULL) {
ffffffffc0201ace:	c945                	beqz	a0,ffffffffc0201b7e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201ad0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201ad2:	611c                	ld	a5,0(a0)
ffffffffc0201ad4:	892a                	mv	s2,a0
ffffffffc0201ad6:	0016871b          	addiw	a4,a3,1
ffffffffc0201ada:	c018                	sw	a4,0(s0)
ffffffffc0201adc:	0017f713          	andi	a4,a5,1
ffffffffc0201ae0:	e339                	bnez	a4,ffffffffc0201b26 <page_insert+0x72>
ffffffffc0201ae2:	00010797          	auipc	a5,0x10
ffffffffc0201ae6:	9ce78793          	addi	a5,a5,-1586 # ffffffffc02114b0 <pages>
ffffffffc0201aea:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aec:	00003717          	auipc	a4,0x3
ffffffffc0201af0:	23c70713          	addi	a4,a4,572 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0201af4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201af8:	6300                	ld	s0,0(a4)
ffffffffc0201afa:	878d                	srai	a5,a5,0x3
ffffffffc0201afc:	000806b7          	lui	a3,0x80
ffffffffc0201b00:	028787b3          	mul	a5,a5,s0
ffffffffc0201b04:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201b06:	07aa                	slli	a5,a5,0xa
ffffffffc0201b08:	8fc5                	or	a5,a5,s1
ffffffffc0201b0a:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201b0e:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b12:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201b16:	4501                	li	a0,0
}
ffffffffc0201b18:	70a2                	ld	ra,40(sp)
ffffffffc0201b1a:	7402                	ld	s0,32(sp)
ffffffffc0201b1c:	64e2                	ld	s1,24(sp)
ffffffffc0201b1e:	6942                	ld	s2,16(sp)
ffffffffc0201b20:	69a2                	ld	s3,8(sp)
ffffffffc0201b22:	6145                	addi	sp,sp,48
ffffffffc0201b24:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201b26:	00010717          	auipc	a4,0x10
ffffffffc0201b2a:	93a70713          	addi	a4,a4,-1734 # ffffffffc0211460 <npage>
ffffffffc0201b2e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b30:	00279513          	slli	a0,a5,0x2
ffffffffc0201b34:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b36:	04e57663          	bleu	a4,a0,ffffffffc0201b82 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b3a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b3e:	953e                	add	a0,a0,a5
ffffffffc0201b40:	00010997          	auipc	s3,0x10
ffffffffc0201b44:	97098993          	addi	s3,s3,-1680 # ffffffffc02114b0 <pages>
ffffffffc0201b48:	0009b783          	ld	a5,0(s3)
ffffffffc0201b4c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b50:	953a                	add	a0,a0,a4
ffffffffc0201b52:	050e                	slli	a0,a0,0x3
ffffffffc0201b54:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b56:	00a40e63          	beq	s0,a0,ffffffffc0201b72 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b5a:	411c                	lw	a5,0(a0)
ffffffffc0201b5c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b60:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b62:	cb11                	beqz	a4,ffffffffc0201b76 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b64:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b68:	12000073          	sfence.vma
ffffffffc0201b6c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b70:	bfb5                	j	ffffffffc0201aec <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b72:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b74:	bfa5                	j	ffffffffc0201aec <page_insert+0x38>
            free_page(page);
ffffffffc0201b76:	4585                	li	a1,1
ffffffffc0201b78:	bdfff0ef          	jal	ra,ffffffffc0201756 <free_pages>
ffffffffc0201b7c:	b7e5                	j	ffffffffc0201b64 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b7e:	5571                	li	a0,-4
ffffffffc0201b80:	bf61                	j	ffffffffc0201b18 <page_insert+0x64>
ffffffffc0201b82:	b31ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>

ffffffffc0201b86 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b86:	00003797          	auipc	a5,0x3
ffffffffc0201b8a:	55278793          	addi	a5,a5,1362 # ffffffffc02050d8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b8e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b90:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b92:	00003517          	auipc	a0,0x3
ffffffffc0201b96:	65650513          	addi	a0,a0,1622 # ffffffffc02051e8 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b9a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b9c:	00010717          	auipc	a4,0x10
ffffffffc0201ba0:	8ef73e23          	sd	a5,-1796(a4) # ffffffffc0211498 <pmm_manager>
void pmm_init(void) {
ffffffffc0201ba4:	e8a2                	sd	s0,80(sp)
ffffffffc0201ba6:	e4a6                	sd	s1,72(sp)
ffffffffc0201ba8:	e0ca                	sd	s2,64(sp)
ffffffffc0201baa:	fc4e                	sd	s3,56(sp)
ffffffffc0201bac:	f852                	sd	s4,48(sp)
ffffffffc0201bae:	f456                	sd	s5,40(sp)
ffffffffc0201bb0:	f05a                	sd	s6,32(sp)
ffffffffc0201bb2:	ec5e                	sd	s7,24(sp)
ffffffffc0201bb4:	e862                	sd	s8,16(sp)
ffffffffc0201bb6:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201bb8:	00010417          	auipc	s0,0x10
ffffffffc0201bbc:	8e040413          	addi	s0,s0,-1824 # ffffffffc0211498 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bc0:	cfefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201bc4:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bc6:	49c5                	li	s3,17
ffffffffc0201bc8:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201bcc:	679c                	ld	a5,8(a5)
ffffffffc0201bce:	00010497          	auipc	s1,0x10
ffffffffc0201bd2:	89248493          	addi	s1,s1,-1902 # ffffffffc0211460 <npage>
ffffffffc0201bd6:	00010917          	auipc	s2,0x10
ffffffffc0201bda:	8da90913          	addi	s2,s2,-1830 # ffffffffc02114b0 <pages>
ffffffffc0201bde:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201be0:	57f5                	li	a5,-3
ffffffffc0201be2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201be4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201be8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bec:	015a1593          	slli	a1,s4,0x15
ffffffffc0201bf0:	00003517          	auipc	a0,0x3
ffffffffc0201bf4:	61050513          	addi	a0,a0,1552 # ffffffffc0205200 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bf8:	00010717          	auipc	a4,0x10
ffffffffc0201bfc:	8af73423          	sd	a5,-1880(a4) # ffffffffc02114a0 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201c00:	cbefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201c04:	00003517          	auipc	a0,0x3
ffffffffc0201c08:	62c50513          	addi	a0,a0,1580 # ffffffffc0205230 <default_pmm_manager+0x158>
ffffffffc0201c0c:	cb2fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201c10:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201c14:	16fd                	addi	a3,a3,-1
ffffffffc0201c16:	015a1613          	slli	a2,s4,0x15
ffffffffc0201c1a:	07e005b7          	lui	a1,0x7e00
ffffffffc0201c1e:	00003517          	auipc	a0,0x3
ffffffffc0201c22:	62a50513          	addi	a0,a0,1578 # ffffffffc0205248 <default_pmm_manager+0x170>
ffffffffc0201c26:	c98fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c2a:	777d                	lui	a4,0xfffff
ffffffffc0201c2c:	00011797          	auipc	a5,0x11
ffffffffc0201c30:	97378793          	addi	a5,a5,-1677 # ffffffffc021259f <end+0xfff>
ffffffffc0201c34:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201c36:	00088737          	lui	a4,0x88
ffffffffc0201c3a:	00010697          	auipc	a3,0x10
ffffffffc0201c3e:	82e6b323          	sd	a4,-2010(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c42:	00010717          	auipc	a4,0x10
ffffffffc0201c46:	86f73723          	sd	a5,-1938(a4) # ffffffffc02114b0 <pages>
ffffffffc0201c4a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c4c:	4701                	li	a4,0
ffffffffc0201c4e:	4585                	li	a1,1
ffffffffc0201c50:	fff80637          	lui	a2,0xfff80
ffffffffc0201c54:	a019                	j	ffffffffc0201c5a <pmm_init+0xd4>
ffffffffc0201c56:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c5a:	97b6                	add	a5,a5,a3
ffffffffc0201c5c:	07a1                	addi	a5,a5,8
ffffffffc0201c5e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c62:	609c                	ld	a5,0(s1)
ffffffffc0201c64:	0705                	addi	a4,a4,1
ffffffffc0201c66:	04868693          	addi	a3,a3,72
ffffffffc0201c6a:	00c78533          	add	a0,a5,a2
ffffffffc0201c6e:	fea764e3          	bltu	a4,a0,ffffffffc0201c56 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c72:	00093503          	ld	a0,0(s2)
ffffffffc0201c76:	00379693          	slli	a3,a5,0x3
ffffffffc0201c7a:	96be                	add	a3,a3,a5
ffffffffc0201c7c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c80:	972a                	add	a4,a4,a0
ffffffffc0201c82:	068e                	slli	a3,a3,0x3
ffffffffc0201c84:	96ba                	add	a3,a3,a4
ffffffffc0201c86:	c0200737          	lui	a4,0xc0200
ffffffffc0201c8a:	58e6ea63          	bltu	a3,a4,ffffffffc020221e <pmm_init+0x698>
ffffffffc0201c8e:	00010997          	auipc	s3,0x10
ffffffffc0201c92:	81298993          	addi	s3,s3,-2030 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0201c96:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c9a:	45c5                	li	a1,17
ffffffffc0201c9c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c9e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201ca0:	44b6ef63          	bltu	a3,a1,ffffffffc02020fe <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201ca4:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201ca6:	0000f417          	auipc	s0,0xf
ffffffffc0201caa:	7b240413          	addi	s0,s0,1970 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201cae:	7b9c                	ld	a5,48(a5)
ffffffffc0201cb0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201cb2:	00003517          	auipc	a0,0x3
ffffffffc0201cb6:	5e650513          	addi	a0,a0,1510 # ffffffffc0205298 <default_pmm_manager+0x1c0>
ffffffffc0201cba:	c04fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201cbe:	00007697          	auipc	a3,0x7
ffffffffc0201cc2:	34268693          	addi	a3,a3,834 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201cc6:	0000f797          	auipc	a5,0xf
ffffffffc0201cca:	78d7b923          	sd	a3,1938(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201cce:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cd2:	0ef6ece3          	bltu	a3,a5,ffffffffc02025ca <pmm_init+0xa44>
ffffffffc0201cd6:	0009b783          	ld	a5,0(s3)
ffffffffc0201cda:	8e9d                	sub	a3,a3,a5
ffffffffc0201cdc:	0000f797          	auipc	a5,0xf
ffffffffc0201ce0:	7cd7b623          	sd	a3,1996(a5) # ffffffffc02114a8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201ce4:	ab9ff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201ce8:	6098                	ld	a4,0(s1)
ffffffffc0201cea:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cee:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201cf0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cf2:	0ae7ece3          	bltu	a5,a4,ffffffffc02025aa <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201cf6:	6008                	ld	a0,0(s0)
ffffffffc0201cf8:	4c050363          	beqz	a0,ffffffffc02021be <pmm_init+0x638>
ffffffffc0201cfc:	6785                	lui	a5,0x1
ffffffffc0201cfe:	17fd                	addi	a5,a5,-1
ffffffffc0201d00:	8fe9                	and	a5,a5,a0
ffffffffc0201d02:	2781                	sext.w	a5,a5
ffffffffc0201d04:	4a079d63          	bnez	a5,ffffffffc02021be <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201d08:	4601                	li	a2,0
ffffffffc0201d0a:	4581                	li	a1,0
ffffffffc0201d0c:	ccfff0ef          	jal	ra,ffffffffc02019da <get_page>
ffffffffc0201d10:	4c051763          	bnez	a0,ffffffffc02021de <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201d14:	4505                	li	a0,1
ffffffffc0201d16:	9b9ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201d1a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201d1c:	6008                	ld	a0,0(s0)
ffffffffc0201d1e:	4681                	li	a3,0
ffffffffc0201d20:	4601                	li	a2,0
ffffffffc0201d22:	85d6                	mv	a1,s5
ffffffffc0201d24:	d91ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201d28:	52051763          	bnez	a0,ffffffffc0202256 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201d2c:	6008                	ld	a0,0(s0)
ffffffffc0201d2e:	4601                	li	a2,0
ffffffffc0201d30:	4581                	li	a1,0
ffffffffc0201d32:	aabff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201d36:	50050063          	beqz	a0,ffffffffc0202236 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d3a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d3c:	0017f713          	andi	a4,a5,1
ffffffffc0201d40:	46070363          	beqz	a4,ffffffffc02021a6 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d44:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d46:	078a                	slli	a5,a5,0x2
ffffffffc0201d48:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d4a:	44c7f063          	bleu	a2,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d4e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d52:	97ba                	add	a5,a5,a4
ffffffffc0201d54:	00379713          	slli	a4,a5,0x3
ffffffffc0201d58:	00093683          	ld	a3,0(s2)
ffffffffc0201d5c:	97ba                	add	a5,a5,a4
ffffffffc0201d5e:	078e                	slli	a5,a5,0x3
ffffffffc0201d60:	97b6                	add	a5,a5,a3
ffffffffc0201d62:	5efa9463          	bne	s5,a5,ffffffffc020234a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d66:	000aab83          	lw	s7,0(s5)
ffffffffc0201d6a:	4785                	li	a5,1
ffffffffc0201d6c:	5afb9f63          	bne	s7,a5,ffffffffc020232a <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d70:	6008                	ld	a0,0(s0)
ffffffffc0201d72:	76fd                	lui	a3,0xfffff
ffffffffc0201d74:	611c                	ld	a5,0(a0)
ffffffffc0201d76:	078a                	slli	a5,a5,0x2
ffffffffc0201d78:	8ff5                	and	a5,a5,a3
ffffffffc0201d7a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d7e:	58c77963          	bleu	a2,a4,ffffffffc0202310 <pmm_init+0x78a>
ffffffffc0201d82:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d86:	97e2                	add	a5,a5,s8
ffffffffc0201d88:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d8c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d8e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d92:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d96:	56c7f063          	bleu	a2,a5,ffffffffc02022f6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d9a:	4601                	li	a2,0
ffffffffc0201d9c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d9e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201da0:	a3dff0ef          	jal	ra,ffffffffc02017dc <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201da4:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201da6:	53651863          	bne	a0,s6,ffffffffc02022d6 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201daa:	4505                	li	a0,1
ffffffffc0201dac:	923ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201db0:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201db2:	6008                	ld	a0,0(s0)
ffffffffc0201db4:	46d1                	li	a3,20
ffffffffc0201db6:	6605                	lui	a2,0x1
ffffffffc0201db8:	85da                	mv	a1,s6
ffffffffc0201dba:	cfbff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201dbe:	4e051c63          	bnez	a0,ffffffffc02022b6 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201dc2:	6008                	ld	a0,0(s0)
ffffffffc0201dc4:	4601                	li	a2,0
ffffffffc0201dc6:	6585                	lui	a1,0x1
ffffffffc0201dc8:	a15ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201dcc:	4c050563          	beqz	a0,ffffffffc0202296 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201dd0:	611c                	ld	a5,0(a0)
ffffffffc0201dd2:	0107f713          	andi	a4,a5,16
ffffffffc0201dd6:	4a070063          	beqz	a4,ffffffffc0202276 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201dda:	8b91                	andi	a5,a5,4
ffffffffc0201ddc:	66078763          	beqz	a5,ffffffffc020244a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201de0:	6008                	ld	a0,0(s0)
ffffffffc0201de2:	611c                	ld	a5,0(a0)
ffffffffc0201de4:	8bc1                	andi	a5,a5,16
ffffffffc0201de6:	64078263          	beqz	a5,ffffffffc020242a <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201dea:	000b2783          	lw	a5,0(s6)
ffffffffc0201dee:	61779e63          	bne	a5,s7,ffffffffc020240a <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201df2:	4681                	li	a3,0
ffffffffc0201df4:	6605                	lui	a2,0x1
ffffffffc0201df6:	85d6                	mv	a1,s5
ffffffffc0201df8:	cbdff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201dfc:	5e051763          	bnez	a0,ffffffffc02023ea <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201e00:	000aa703          	lw	a4,0(s5)
ffffffffc0201e04:	4789                	li	a5,2
ffffffffc0201e06:	5cf71263          	bne	a4,a5,ffffffffc02023ca <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201e0a:	000b2783          	lw	a5,0(s6)
ffffffffc0201e0e:	58079e63          	bnez	a5,ffffffffc02023aa <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201e12:	6008                	ld	a0,0(s0)
ffffffffc0201e14:	4601                	li	a2,0
ffffffffc0201e16:	6585                	lui	a1,0x1
ffffffffc0201e18:	9c5ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201e1c:	56050763          	beqz	a0,ffffffffc020238a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201e20:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e22:	0016f793          	andi	a5,a3,1
ffffffffc0201e26:	38078063          	beqz	a5,ffffffffc02021a6 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e2c:	00269793          	slli	a5,a3,0x2
ffffffffc0201e30:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e32:	34e7fc63          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e36:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3a:	97ba                	add	a5,a5,a4
ffffffffc0201e3c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e40:	00093603          	ld	a2,0(s2)
ffffffffc0201e44:	97ba                	add	a5,a5,a4
ffffffffc0201e46:	078e                	slli	a5,a5,0x3
ffffffffc0201e48:	97b2                	add	a5,a5,a2
ffffffffc0201e4a:	52fa9063          	bne	s5,a5,ffffffffc020236a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e4e:	8ac1                	andi	a3,a3,16
ffffffffc0201e50:	6e069d63          	bnez	a3,ffffffffc020254a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e54:	6008                	ld	a0,0(s0)
ffffffffc0201e56:	4581                	li	a1,0
ffffffffc0201e58:	bebff0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e5c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e60:	4785                	li	a5,1
ffffffffc0201e62:	6cf71463          	bne	a4,a5,ffffffffc020252a <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e66:	000b2783          	lw	a5,0(s6)
ffffffffc0201e6a:	6a079063          	bnez	a5,ffffffffc020250a <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e6e:	6008                	ld	a0,0(s0)
ffffffffc0201e70:	6585                	lui	a1,0x1
ffffffffc0201e72:	bd1ff0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e76:	000aa783          	lw	a5,0(s5)
ffffffffc0201e7a:	66079863          	bnez	a5,ffffffffc02024ea <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e7e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e82:	70079463          	bnez	a5,ffffffffc020258a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e86:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e8a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e8c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e90:	078a                	slli	a5,a5,0x2
ffffffffc0201e92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e94:	2eb7fb63          	bleu	a1,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e98:	fff80737          	lui	a4,0xfff80
ffffffffc0201e9c:	973e                	add	a4,a4,a5
ffffffffc0201e9e:	00371793          	slli	a5,a4,0x3
ffffffffc0201ea2:	00093603          	ld	a2,0(s2)
ffffffffc0201ea6:	97ba                	add	a5,a5,a4
ffffffffc0201ea8:	078e                	slli	a5,a5,0x3
ffffffffc0201eaa:	00f60733          	add	a4,a2,a5
ffffffffc0201eae:	4314                	lw	a3,0(a4)
ffffffffc0201eb0:	4705                	li	a4,1
ffffffffc0201eb2:	6ae69c63          	bne	a3,a4,ffffffffc020256a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201eb6:	00003a97          	auipc	s5,0x3
ffffffffc0201eba:	e72a8a93          	addi	s5,s5,-398 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0201ebe:	000ab703          	ld	a4,0(s5)
ffffffffc0201ec2:	4037d693          	srai	a3,a5,0x3
ffffffffc0201ec6:	00080bb7          	lui	s7,0x80
ffffffffc0201eca:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ece:	577d                	li	a4,-1
ffffffffc0201ed0:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ed2:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ed4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ed6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ed8:	2ab77b63          	bleu	a1,a4,ffffffffc020218e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201edc:	0009b783          	ld	a5,0(s3)
ffffffffc0201ee0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ee2:	629c                	ld	a5,0(a3)
ffffffffc0201ee4:	078a                	slli	a5,a5,0x2
ffffffffc0201ee6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee8:	2ab7f163          	bleu	a1,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eec:	417787b3          	sub	a5,a5,s7
ffffffffc0201ef0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ef4:	97aa                	add	a5,a5,a0
ffffffffc0201ef6:	00379513          	slli	a0,a5,0x3
ffffffffc0201efa:	9532                	add	a0,a0,a2
ffffffffc0201efc:	4585                	li	a1,1
ffffffffc0201efe:	859ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f02:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201f06:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f08:	050a                	slli	a0,a0,0x2
ffffffffc0201f0a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f0c:	26f57f63          	bleu	a5,a0,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f10:	417507b3          	sub	a5,a0,s7
ffffffffc0201f14:	00379513          	slli	a0,a5,0x3
ffffffffc0201f18:	00093703          	ld	a4,0(s2)
ffffffffc0201f1c:	953e                	add	a0,a0,a5
ffffffffc0201f1e:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201f20:	4585                	li	a1,1
ffffffffc0201f22:	953a                	add	a0,a0,a4
ffffffffc0201f24:	833ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201f28:	601c                	ld	a5,0(s0)
ffffffffc0201f2a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201f2e:	86fff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0201f32:	2caa1663          	bne	s4,a0,ffffffffc02021fe <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f36:	00003517          	auipc	a0,0x3
ffffffffc0201f3a:	67250513          	addi	a0,a0,1650 # ffffffffc02055a8 <default_pmm_manager+0x4d0>
ffffffffc0201f3e:	980fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f42:	85bff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f46:	6098                	ld	a4,0(s1)
ffffffffc0201f48:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f4c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f4e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f52:	1cd7fd63          	bleu	a3,a5,ffffffffc020212c <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f56:	83b1                	srli	a5,a5,0xc
ffffffffc0201f58:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f5a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f5e:	1ce7f963          	bleu	a4,a5,ffffffffc0202130 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f62:	7c7d                	lui	s8,0xfffff
ffffffffc0201f64:	6b85                	lui	s7,0x1
ffffffffc0201f66:	a029                	j	ffffffffc0201f70 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f68:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f6c:	1cf77263          	bleu	a5,a4,ffffffffc0202130 <pmm_init+0x5aa>
ffffffffc0201f70:	0009b583          	ld	a1,0(s3)
ffffffffc0201f74:	4601                	li	a2,0
ffffffffc0201f76:	95d2                	add	a1,a1,s4
ffffffffc0201f78:	865ff0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0201f7c:	1c050763          	beqz	a0,ffffffffc020214a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f80:	611c                	ld	a5,0(a0)
ffffffffc0201f82:	078a                	slli	a5,a5,0x2
ffffffffc0201f84:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f88:	1f479163          	bne	a5,s4,ffffffffc020216a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f8c:	609c                	ld	a5,0(s1)
ffffffffc0201f8e:	9a5e                	add	s4,s4,s7
ffffffffc0201f90:	6008                	ld	a0,0(s0)
ffffffffc0201f92:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f96:	fcea69e3          	bltu	s4,a4,ffffffffc0201f68 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f9a:	611c                	ld	a5,0(a0)
ffffffffc0201f9c:	6a079363          	bnez	a5,ffffffffc0202642 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201fa0:	4505                	li	a0,1
ffffffffc0201fa2:	f2cff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0201fa6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201fa8:	6008                	ld	a0,0(s0)
ffffffffc0201faa:	4699                	li	a3,6
ffffffffc0201fac:	10000613          	li	a2,256
ffffffffc0201fb0:	85d2                	mv	a1,s4
ffffffffc0201fb2:	b03ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201fb6:	66051663          	bnez	a0,ffffffffc0202622 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201fba:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201fbe:	4785                	li	a5,1
ffffffffc0201fc0:	64f71163          	bne	a4,a5,ffffffffc0202602 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201fc4:	6008                	ld	a0,0(s0)
ffffffffc0201fc6:	6b85                	lui	s7,0x1
ffffffffc0201fc8:	4699                	li	a3,6
ffffffffc0201fca:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201fce:	85d2                	mv	a1,s4
ffffffffc0201fd0:	ae5ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0201fd4:	60051763          	bnez	a0,ffffffffc02025e2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201fd8:	000a2703          	lw	a4,0(s4)
ffffffffc0201fdc:	4789                	li	a5,2
ffffffffc0201fde:	4ef71663          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fe2:	00003597          	auipc	a1,0x3
ffffffffc0201fe6:	6fe58593          	addi	a1,a1,1790 # ffffffffc02056e0 <default_pmm_manager+0x608>
ffffffffc0201fea:	10000513          	li	a0,256
ffffffffc0201fee:	2c6020ef          	jal	ra,ffffffffc02042b4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ff2:	100b8593          	addi	a1,s7,256
ffffffffc0201ff6:	10000513          	li	a0,256
ffffffffc0201ffa:	2cc020ef          	jal	ra,ffffffffc02042c6 <strcmp>
ffffffffc0201ffe:	4a051663          	bnez	a0,ffffffffc02024aa <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202002:	00093683          	ld	a3,0(s2)
ffffffffc0202006:	000abc83          	ld	s9,0(s5)
ffffffffc020200a:	00080c37          	lui	s8,0x80
ffffffffc020200e:	40da06b3          	sub	a3,s4,a3
ffffffffc0202012:	868d                	srai	a3,a3,0x3
ffffffffc0202014:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202018:	5afd                	li	s5,-1
ffffffffc020201a:	609c                	ld	a5,0(s1)
ffffffffc020201c:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202020:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202022:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202026:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202028:	16f77363          	bleu	a5,a4,ffffffffc020218e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020202c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202030:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202034:	96be                	add	a3,a3,a5
ffffffffc0202036:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020203a:	236020ef          	jal	ra,ffffffffc0204270 <strlen>
ffffffffc020203e:	44051663          	bnez	a0,ffffffffc020248a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202042:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202046:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202048:	000bb783          	ld	a5,0(s7)
ffffffffc020204c:	078a                	slli	a5,a5,0x2
ffffffffc020204e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202050:	12e7fd63          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202054:	418787b3          	sub	a5,a5,s8
ffffffffc0202058:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020205c:	96be                	add	a3,a3,a5
ffffffffc020205e:	039686b3          	mul	a3,a3,s9
ffffffffc0202062:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202064:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202068:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020206a:	12eaf263          	bleu	a4,s5,ffffffffc020218e <pmm_init+0x608>
ffffffffc020206e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202072:	4585                	li	a1,1
ffffffffc0202074:	8552                	mv	a0,s4
ffffffffc0202076:	99b6                	add	s3,s3,a3
ffffffffc0202078:	edeff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020207c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202080:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202082:	078a                	slli	a5,a5,0x2
ffffffffc0202084:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202086:	10e7f263          	bleu	a4,a5,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020208a:	fff809b7          	lui	s3,0xfff80
ffffffffc020208e:	97ce                	add	a5,a5,s3
ffffffffc0202090:	00379513          	slli	a0,a5,0x3
ffffffffc0202094:	00093703          	ld	a4,0(s2)
ffffffffc0202098:	97aa                	add	a5,a5,a0
ffffffffc020209a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020209e:	953a                	add	a0,a0,a4
ffffffffc02020a0:	4585                	li	a1,1
ffffffffc02020a2:	eb4ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020a6:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02020aa:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020ac:	050a                	slli	a0,a0,0x2
ffffffffc02020ae:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b0:	0cf57d63          	bleu	a5,a0,ffffffffc020218a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b4:	013507b3          	add	a5,a0,s3
ffffffffc02020b8:	00379513          	slli	a0,a5,0x3
ffffffffc02020bc:	00093703          	ld	a4,0(s2)
ffffffffc02020c0:	953e                	add	a0,a0,a5
ffffffffc02020c2:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02020c4:	4585                	li	a1,1
ffffffffc02020c6:	953a                	add	a0,a0,a4
ffffffffc02020c8:	e8eff0ef          	jal	ra,ffffffffc0201756 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02020cc:	601c                	ld	a5,0(s0)
ffffffffc02020ce:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02020d2:	ecaff0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02020d6:	38ab1a63          	bne	s6,a0,ffffffffc020246a <pmm_init+0x8e4>
}
ffffffffc02020da:	6446                	ld	s0,80(sp)
ffffffffc02020dc:	60e6                	ld	ra,88(sp)
ffffffffc02020de:	64a6                	ld	s1,72(sp)
ffffffffc02020e0:	6906                	ld	s2,64(sp)
ffffffffc02020e2:	79e2                	ld	s3,56(sp)
ffffffffc02020e4:	7a42                	ld	s4,48(sp)
ffffffffc02020e6:	7aa2                	ld	s5,40(sp)
ffffffffc02020e8:	7b02                	ld	s6,32(sp)
ffffffffc02020ea:	6be2                	ld	s7,24(sp)
ffffffffc02020ec:	6c42                	ld	s8,16(sp)
ffffffffc02020ee:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020f0:	00003517          	auipc	a0,0x3
ffffffffc02020f4:	66850513          	addi	a0,a0,1640 # ffffffffc0205758 <default_pmm_manager+0x680>
}
ffffffffc02020f8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020fa:	fc5fd06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020fe:	6705                	lui	a4,0x1
ffffffffc0202100:	177d                	addi	a4,a4,-1
ffffffffc0202102:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202104:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202108:	08f77163          	bleu	a5,a4,ffffffffc020218a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020210c:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202110:	9732                	add	a4,a4,a2
ffffffffc0202112:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202116:	767d                	lui	a2,0xfffff
ffffffffc0202118:	8ef1                	and	a3,a3,a2
ffffffffc020211a:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020211c:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202120:	8d95                	sub	a1,a1,a3
ffffffffc0202122:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202124:	81b1                	srli	a1,a1,0xc
ffffffffc0202126:	953e                	add	a0,a0,a5
ffffffffc0202128:	9702                	jalr	a4
ffffffffc020212a:	bead                	j	ffffffffc0201ca4 <pmm_init+0x11e>
ffffffffc020212c:	6008                	ld	a0,0(s0)
ffffffffc020212e:	b5b5                	j	ffffffffc0201f9a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202130:	86d2                	mv	a3,s4
ffffffffc0202132:	00003617          	auipc	a2,0x3
ffffffffc0202136:	ff660613          	addi	a2,a2,-10 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc020213a:	1cd00593          	li	a1,461
ffffffffc020213e:	00003517          	auipc	a0,0x3
ffffffffc0202142:	01250513          	addi	a0,a0,18 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202146:	a2efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020214a:	00003697          	auipc	a3,0x3
ffffffffc020214e:	47e68693          	addi	a3,a3,1150 # ffffffffc02055c8 <default_pmm_manager+0x4f0>
ffffffffc0202152:	00003617          	auipc	a2,0x3
ffffffffc0202156:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020215a:	1cd00593          	li	a1,461
ffffffffc020215e:	00003517          	auipc	a0,0x3
ffffffffc0202162:	ff250513          	addi	a0,a0,-14 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202166:	a0efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020216a:	00003697          	auipc	a3,0x3
ffffffffc020216e:	49e68693          	addi	a3,a3,1182 # ffffffffc0205608 <default_pmm_manager+0x530>
ffffffffc0202172:	00003617          	auipc	a2,0x3
ffffffffc0202176:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020217a:	1ce00593          	li	a1,462
ffffffffc020217e:	00003517          	auipc	a0,0x3
ffffffffc0202182:	fd250513          	addi	a0,a0,-46 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202186:	9eefe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020218a:	d28ff0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020218e:	00003617          	auipc	a2,0x3
ffffffffc0202192:	f9a60613          	addi	a2,a2,-102 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc0202196:	06a00593          	li	a1,106
ffffffffc020219a:	00003517          	auipc	a0,0x3
ffffffffc020219e:	02650513          	addi	a0,a0,38 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc02021a2:	9d2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	1f260613          	addi	a2,a2,498 # ffffffffc0205398 <default_pmm_manager+0x2c0>
ffffffffc02021ae:	07000593          	li	a1,112
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	00e50513          	addi	a0,a0,14 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	11a68693          	addi	a3,a3,282 # ffffffffc02052d8 <default_pmm_manager+0x200>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02021ce:	19300593          	li	a1,403
ffffffffc02021d2:	00003517          	auipc	a0,0x3
ffffffffc02021d6:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02021da:	99afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021de:	00003697          	auipc	a3,0x3
ffffffffc02021e2:	13268693          	addi	a3,a3,306 # ffffffffc0205310 <default_pmm_manager+0x238>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02021ee:	19400593          	li	a1,404
ffffffffc02021f2:	00003517          	auipc	a0,0x3
ffffffffc02021f6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02021fa:	97afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021fe:	00003697          	auipc	a3,0x3
ffffffffc0202202:	38a68693          	addi	a3,a3,906 # ffffffffc0205588 <default_pmm_manager+0x4b0>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020220e:	1c000593          	li	a1,448
ffffffffc0202212:	00003517          	auipc	a0,0x3
ffffffffc0202216:	f3e50513          	addi	a0,a0,-194 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020221a:	95afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	05260613          	addi	a2,a2,82 # ffffffffc0205270 <default_pmm_manager+0x198>
ffffffffc0202226:	07700593          	li	a1,119
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	f2650513          	addi	a0,a0,-218 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202232:	942fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	13268693          	addi	a3,a3,306 # ffffffffc0205368 <default_pmm_manager+0x290>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202246:	19a00593          	li	a1,410
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202252:	922fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	0e268693          	addi	a3,a3,226 # ffffffffc0205338 <default_pmm_manager+0x260>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202266:	19800593          	li	a1,408
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202272:	902fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	20a68693          	addi	a3,a3,522 # ffffffffc0205480 <default_pmm_manager+0x3a8>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202286:	1a500593          	li	a1,421
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	ec650513          	addi	a0,a0,-314 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202292:	8e2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202296:	00003697          	auipc	a3,0x3
ffffffffc020229a:	1ba68693          	addi	a3,a3,442 # ffffffffc0205450 <default_pmm_manager+0x378>
ffffffffc020229e:	00003617          	auipc	a2,0x3
ffffffffc02022a2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02022a6:	1a400593          	li	a1,420
ffffffffc02022aa:	00003517          	auipc	a0,0x3
ffffffffc02022ae:	ea650513          	addi	a0,a0,-346 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02022b2:	8c2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022b6:	00003697          	auipc	a3,0x3
ffffffffc02022ba:	16268693          	addi	a3,a3,354 # ffffffffc0205418 <default_pmm_manager+0x340>
ffffffffc02022be:	00003617          	auipc	a2,0x3
ffffffffc02022c2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02022c6:	1a300593          	li	a1,419
ffffffffc02022ca:	00003517          	auipc	a0,0x3
ffffffffc02022ce:	e8650513          	addi	a0,a0,-378 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02022d2:	8a2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022d6:	00003697          	auipc	a3,0x3
ffffffffc02022da:	11a68693          	addi	a3,a3,282 # ffffffffc02053f0 <default_pmm_manager+0x318>
ffffffffc02022de:	00003617          	auipc	a2,0x3
ffffffffc02022e2:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02022e6:	1a000593          	li	a1,416
ffffffffc02022ea:	00003517          	auipc	a0,0x3
ffffffffc02022ee:	e6650513          	addi	a0,a0,-410 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02022f2:	882fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022f6:	86da                	mv	a3,s6
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	e3060613          	addi	a2,a2,-464 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc0202300:	19f00593          	li	a1,415
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020230c:	868fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202310:	86be                	mv	a3,a5
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	e1660613          	addi	a2,a2,-490 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc020231a:	19e00593          	li	a1,414
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	e3250513          	addi	a0,a0,-462 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202326:	84efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	0ae68693          	addi	a3,a3,174 # ffffffffc02053d8 <default_pmm_manager+0x300>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020233a:	19c00593          	li	a1,412
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	e1250513          	addi	a0,a0,-494 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	07668693          	addi	a3,a3,118 # ffffffffc02053c0 <default_pmm_manager+0x2e8>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020235a:	19b00593          	li	a1,411
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	df250513          	addi	a0,a0,-526 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	05668693          	addi	a3,a3,86 # ffffffffc02053c0 <default_pmm_manager+0x2e8>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020237a:	1ae00593          	li	a1,430
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	dd250513          	addi	a0,a0,-558 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	0c668693          	addi	a3,a3,198 # ffffffffc0205450 <default_pmm_manager+0x378>
ffffffffc0202392:	00003617          	auipc	a2,0x3
ffffffffc0202396:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020239a:	1ad00593          	li	a1,429
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	db250513          	addi	a0,a0,-590 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	16e68693          	addi	a3,a3,366 # ffffffffc0205518 <default_pmm_manager+0x440>
ffffffffc02023b2:	00003617          	auipc	a2,0x3
ffffffffc02023b6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02023ba:	1ac00593          	li	a1,428
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	d9250513          	addi	a0,a0,-622 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	13668693          	addi	a3,a3,310 # ffffffffc0205500 <default_pmm_manager+0x428>
ffffffffc02023d2:	00003617          	auipc	a2,0x3
ffffffffc02023d6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02023da:	1ab00593          	li	a1,427
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	d7250513          	addi	a0,a0,-654 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	0e668693          	addi	a3,a3,230 # ffffffffc02054d0 <default_pmm_manager+0x3f8>
ffffffffc02023f2:	00003617          	auipc	a2,0x3
ffffffffc02023f6:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02023fa:	1aa00593          	li	a1,426
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	d5250513          	addi	a0,a0,-686 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	0ae68693          	addi	a3,a3,174 # ffffffffc02054b8 <default_pmm_manager+0x3e0>
ffffffffc0202412:	00003617          	auipc	a2,0x3
ffffffffc0202416:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020241a:	1a800593          	li	a1,424
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	d3250513          	addi	a0,a0,-718 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	07668693          	addi	a3,a3,118 # ffffffffc02054a0 <default_pmm_manager+0x3c8>
ffffffffc0202432:	00003617          	auipc	a2,0x3
ffffffffc0202436:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020243a:	1a700593          	li	a1,423
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	d1250513          	addi	a0,a0,-750 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	04668693          	addi	a3,a3,70 # ffffffffc0205490 <default_pmm_manager+0x3b8>
ffffffffc0202452:	00003617          	auipc	a2,0x3
ffffffffc0202456:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020245a:	1a600593          	li	a1,422
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	cf250513          	addi	a0,a0,-782 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	11e68693          	addi	a3,a3,286 # ffffffffc0205588 <default_pmm_manager+0x4b0>
ffffffffc0202472:	00003617          	auipc	a2,0x3
ffffffffc0202476:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020247a:	1e800593          	li	a1,488
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	cd250513          	addi	a0,a0,-814 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	2a668693          	addi	a3,a3,678 # ffffffffc0205730 <default_pmm_manager+0x658>
ffffffffc0202492:	00003617          	auipc	a2,0x3
ffffffffc0202496:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020249a:	1e000593          	li	a1,480
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	cb250513          	addi	a0,a0,-846 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	24e68693          	addi	a3,a3,590 # ffffffffc02056f8 <default_pmm_manager+0x620>
ffffffffc02024b2:	00003617          	auipc	a2,0x3
ffffffffc02024b6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02024ba:	1dd00593          	li	a1,477
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	c9250513          	addi	a0,a0,-878 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	1fe68693          	addi	a3,a3,510 # ffffffffc02056c8 <default_pmm_manager+0x5f0>
ffffffffc02024d2:	00003617          	auipc	a2,0x3
ffffffffc02024d6:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02024da:	1d900593          	li	a1,473
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	c7250513          	addi	a0,a0,-910 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	05e68693          	addi	a3,a3,94 # ffffffffc0205548 <default_pmm_manager+0x470>
ffffffffc02024f2:	00003617          	auipc	a2,0x3
ffffffffc02024f6:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02024fa:	1b600593          	li	a1,438
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	c5250513          	addi	a0,a0,-942 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	00e68693          	addi	a3,a3,14 # ffffffffc0205518 <default_pmm_manager+0x440>
ffffffffc0202512:	00003617          	auipc	a2,0x3
ffffffffc0202516:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020251a:	1b300593          	li	a1,435
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	c3250513          	addi	a0,a0,-974 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	eae68693          	addi	a3,a3,-338 # ffffffffc02053d8 <default_pmm_manager+0x300>
ffffffffc0202532:	00003617          	auipc	a2,0x3
ffffffffc0202536:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020253a:	1b200593          	li	a1,434
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202546:	e2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	fe668693          	addi	a3,a3,-26 # ffffffffc0205530 <default_pmm_manager+0x458>
ffffffffc0202552:	00002617          	auipc	a2,0x2
ffffffffc0202556:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020255a:	1af00593          	li	a1,431
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202566:	e0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	ff668693          	addi	a3,a3,-10 # ffffffffc0205560 <default_pmm_manager+0x488>
ffffffffc0202572:	00002617          	auipc	a2,0x2
ffffffffc0202576:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020257a:	1b900593          	li	a1,441
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202586:	deffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020258a:	00003697          	auipc	a3,0x3
ffffffffc020258e:	f8e68693          	addi	a3,a3,-114 # ffffffffc0205518 <default_pmm_manager+0x440>
ffffffffc0202592:	00002617          	auipc	a2,0x2
ffffffffc0202596:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020259a:	1b700593          	li	a1,439
ffffffffc020259e:	00003517          	auipc	a0,0x3
ffffffffc02025a2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02025a6:	dcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02025aa:	00003697          	auipc	a3,0x3
ffffffffc02025ae:	d0e68693          	addi	a3,a3,-754 # ffffffffc02052b8 <default_pmm_manager+0x1e0>
ffffffffc02025b2:	00002617          	auipc	a2,0x2
ffffffffc02025b6:	78e60613          	addi	a2,a2,1934 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02025ba:	19200593          	li	a1,402
ffffffffc02025be:	00003517          	auipc	a0,0x3
ffffffffc02025c2:	b9250513          	addi	a0,a0,-1134 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02025c6:	daffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02025ca:	00003617          	auipc	a2,0x3
ffffffffc02025ce:	ca660613          	addi	a2,a2,-858 # ffffffffc0205270 <default_pmm_manager+0x198>
ffffffffc02025d2:	0bd00593          	li	a1,189
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	0a668693          	addi	a3,a3,166 # ffffffffc0205688 <default_pmm_manager+0x5b0>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	75660613          	addi	a2,a2,1878 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02025f2:	1d800593          	li	a1,472
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202602:	00003697          	auipc	a3,0x3
ffffffffc0202606:	06e68693          	addi	a3,a3,110 # ffffffffc0205670 <default_pmm_manager+0x598>
ffffffffc020260a:	00002617          	auipc	a2,0x2
ffffffffc020260e:	73660613          	addi	a2,a2,1846 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202612:	1d700593          	li	a1,471
ffffffffc0202616:	00003517          	auipc	a0,0x3
ffffffffc020261a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020261e:	d57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202622:	00003697          	auipc	a3,0x3
ffffffffc0202626:	01668693          	addi	a3,a3,22 # ffffffffc0205638 <default_pmm_manager+0x560>
ffffffffc020262a:	00002617          	auipc	a2,0x2
ffffffffc020262e:	71660613          	addi	a2,a2,1814 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202632:	1d600593          	li	a1,470
ffffffffc0202636:	00003517          	auipc	a0,0x3
ffffffffc020263a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020263e:	d37fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202642:	00003697          	auipc	a3,0x3
ffffffffc0202646:	fde68693          	addi	a3,a3,-34 # ffffffffc0205620 <default_pmm_manager+0x548>
ffffffffc020264a:	00002617          	auipc	a2,0x2
ffffffffc020264e:	6f660613          	addi	a2,a2,1782 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202652:	1d200593          	li	a1,466
ffffffffc0202656:	00003517          	auipc	a0,0x3
ffffffffc020265a:	afa50513          	addi	a0,a0,-1286 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020265e:	d17fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202662 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202662:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202666:	8082                	ret

ffffffffc0202668 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202668:	7179                	addi	sp,sp,-48
ffffffffc020266a:	e84a                	sd	s2,16(sp)
ffffffffc020266c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020266e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202670:	f022                	sd	s0,32(sp)
ffffffffc0202672:	ec26                	sd	s1,24(sp)
ffffffffc0202674:	e44e                	sd	s3,8(sp)
ffffffffc0202676:	f406                	sd	ra,40(sp)
ffffffffc0202678:	84ae                	mv	s1,a1
ffffffffc020267a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020267c:	852ff0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc0202680:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202682:	cd19                	beqz	a0,ffffffffc02026a0 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202684:	85aa                	mv	a1,a0
ffffffffc0202686:	86ce                	mv	a3,s3
ffffffffc0202688:	8626                	mv	a2,s1
ffffffffc020268a:	854a                	mv	a0,s2
ffffffffc020268c:	c28ff0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
ffffffffc0202690:	ed39                	bnez	a0,ffffffffc02026ee <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202692:	0000f797          	auipc	a5,0xf
ffffffffc0202696:	dde78793          	addi	a5,a5,-546 # ffffffffc0211470 <swap_init_ok>
ffffffffc020269a:	439c                	lw	a5,0(a5)
ffffffffc020269c:	2781                	sext.w	a5,a5
ffffffffc020269e:	eb89                	bnez	a5,ffffffffc02026b0 <pgdir_alloc_page+0x48>
}
ffffffffc02026a0:	8522                	mv	a0,s0
ffffffffc02026a2:	70a2                	ld	ra,40(sp)
ffffffffc02026a4:	7402                	ld	s0,32(sp)
ffffffffc02026a6:	64e2                	ld	s1,24(sp)
ffffffffc02026a8:	6942                	ld	s2,16(sp)
ffffffffc02026aa:	69a2                	ld	s3,8(sp)
ffffffffc02026ac:	6145                	addi	sp,sp,48
ffffffffc02026ae:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02026b0:	0000f797          	auipc	a5,0xf
ffffffffc02026b4:	ee878793          	addi	a5,a5,-280 # ffffffffc0211598 <check_mm_struct>
ffffffffc02026b8:	6388                	ld	a0,0(a5)
ffffffffc02026ba:	4681                	li	a3,0
ffffffffc02026bc:	8622                	mv	a2,s0
ffffffffc02026be:	85a6                	mv	a1,s1
ffffffffc02026c0:	06d000ef          	jal	ra,ffffffffc0202f2c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc02026c4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc02026c6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc02026c8:	4785                	li	a5,1
ffffffffc02026ca:	fcf70be3          	beq	a4,a5,ffffffffc02026a0 <pgdir_alloc_page+0x38>
ffffffffc02026ce:	00003697          	auipc	a3,0x3
ffffffffc02026d2:	b0268693          	addi	a3,a3,-1278 # ffffffffc02051d0 <default_pmm_manager+0xf8>
ffffffffc02026d6:	00002617          	auipc	a2,0x2
ffffffffc02026da:	66a60613          	addi	a2,a2,1642 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02026de:	17a00593          	li	a1,378
ffffffffc02026e2:	00003517          	auipc	a0,0x3
ffffffffc02026e6:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02026ea:	c8bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc02026ee:	8522                	mv	a0,s0
ffffffffc02026f0:	4585                	li	a1,1
ffffffffc02026f2:	864ff0ef          	jal	ra,ffffffffc0201756 <free_pages>
            return NULL;
ffffffffc02026f6:	4401                	li	s0,0
ffffffffc02026f8:	b765                	j	ffffffffc02026a0 <pgdir_alloc_page+0x38>

ffffffffc02026fa <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026fa:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026fc:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026fe:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202700:	fff50713          	addi	a4,a0,-1
ffffffffc0202704:	17f9                	addi	a5,a5,-2
ffffffffc0202706:	04e7ee63          	bltu	a5,a4,ffffffffc0202762 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020270a:	6785                	lui	a5,0x1
ffffffffc020270c:	17fd                	addi	a5,a5,-1
ffffffffc020270e:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202710:	8131                	srli	a0,a0,0xc
ffffffffc0202712:	fbdfe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
    assert(base != NULL);
ffffffffc0202716:	c159                	beqz	a0,ffffffffc020279c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202718:	0000f797          	auipc	a5,0xf
ffffffffc020271c:	d9878793          	addi	a5,a5,-616 # ffffffffc02114b0 <pages>
ffffffffc0202720:	639c                	ld	a5,0(a5)
ffffffffc0202722:	8d1d                	sub	a0,a0,a5
ffffffffc0202724:	00002797          	auipc	a5,0x2
ffffffffc0202728:	60478793          	addi	a5,a5,1540 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc020272c:	6394                	ld	a3,0(a5)
ffffffffc020272e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202730:	0000f797          	auipc	a5,0xf
ffffffffc0202734:	d3078793          	addi	a5,a5,-720 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202738:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020273c:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020273e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202742:	57fd                	li	a5,-1
ffffffffc0202744:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202746:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202748:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020274a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020274c:	02e7fb63          	bleu	a4,a5,ffffffffc0202782 <kmalloc+0x88>
ffffffffc0202750:	0000f797          	auipc	a5,0xf
ffffffffc0202754:	d5078793          	addi	a5,a5,-688 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0202758:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020275a:	60a2                	ld	ra,8(sp)
ffffffffc020275c:	953e                	add	a0,a0,a5
ffffffffc020275e:	0141                	addi	sp,sp,16
ffffffffc0202760:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202762:	00003697          	auipc	a3,0x3
ffffffffc0202766:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205170 <default_pmm_manager+0x98>
ffffffffc020276a:	00002617          	auipc	a2,0x2
ffffffffc020276e:	5d660613          	addi	a2,a2,1494 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202772:	1f000593          	li	a1,496
ffffffffc0202776:	00003517          	auipc	a0,0x3
ffffffffc020277a:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020277e:	bf7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202782:	86aa                	mv	a3,a0
ffffffffc0202784:	00003617          	auipc	a2,0x3
ffffffffc0202788:	9a460613          	addi	a2,a2,-1628 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc020278c:	06a00593          	li	a1,106
ffffffffc0202790:	00003517          	auipc	a0,0x3
ffffffffc0202794:	a3050513          	addi	a0,a0,-1488 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0202798:	bddfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020279c:	00003697          	auipc	a3,0x3
ffffffffc02027a0:	9f468693          	addi	a3,a3,-1548 # ffffffffc0205190 <default_pmm_manager+0xb8>
ffffffffc02027a4:	00002617          	auipc	a2,0x2
ffffffffc02027a8:	59c60613          	addi	a2,a2,1436 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02027ac:	1f300593          	li	a1,499
ffffffffc02027b0:	00003517          	auipc	a0,0x3
ffffffffc02027b4:	9a050513          	addi	a0,a0,-1632 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc02027b8:	bbdfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02027bc <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc02027bc:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027be:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc02027c0:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027c2:	fff58713          	addi	a4,a1,-1
ffffffffc02027c6:	17f9                	addi	a5,a5,-2
ffffffffc02027c8:	04e7eb63          	bltu	a5,a4,ffffffffc020281e <kfree+0x62>
    assert(ptr != NULL);
ffffffffc02027cc:	c941                	beqz	a0,ffffffffc020285c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027ce:	6785                	lui	a5,0x1
ffffffffc02027d0:	17fd                	addi	a5,a5,-1
ffffffffc02027d2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027d4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027d8:	81b1                	srli	a1,a1,0xc
ffffffffc02027da:	06f56463          	bltu	a0,a5,ffffffffc0202842 <kfree+0x86>
ffffffffc02027de:	0000f797          	auipc	a5,0xf
ffffffffc02027e2:	cc278793          	addi	a5,a5,-830 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02027e6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027e8:	0000f717          	auipc	a4,0xf
ffffffffc02027ec:	c7870713          	addi	a4,a4,-904 # ffffffffc0211460 <npage>
ffffffffc02027f0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027f2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027f6:	83b1                	srli	a5,a5,0xc
ffffffffc02027f8:	04e7f363          	bleu	a4,a5,ffffffffc020283e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fc:	fff80537          	lui	a0,0xfff80
ffffffffc0202800:	97aa                	add	a5,a5,a0
ffffffffc0202802:	0000f697          	auipc	a3,0xf
ffffffffc0202806:	cae68693          	addi	a3,a3,-850 # ffffffffc02114b0 <pages>
ffffffffc020280a:	6288                	ld	a0,0(a3)
ffffffffc020280c:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202810:	60a2                	ld	ra,8(sp)
ffffffffc0202812:	97ba                	add	a5,a5,a4
ffffffffc0202814:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202816:	953e                	add	a0,a0,a5
}
ffffffffc0202818:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020281a:	f3dfe06f          	j	ffffffffc0201756 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020281e:	00003697          	auipc	a3,0x3
ffffffffc0202822:	95268693          	addi	a3,a3,-1710 # ffffffffc0205170 <default_pmm_manager+0x98>
ffffffffc0202826:	00002617          	auipc	a2,0x2
ffffffffc020282a:	51a60613          	addi	a2,a2,1306 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020282e:	1f900593          	li	a1,505
ffffffffc0202832:	00003517          	auipc	a0,0x3
ffffffffc0202836:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc020283a:	b3bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020283e:	e75fe0ef          	jal	ra,ffffffffc02016b2 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202842:	86aa                	mv	a3,a0
ffffffffc0202844:	00003617          	auipc	a2,0x3
ffffffffc0202848:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0205270 <default_pmm_manager+0x198>
ffffffffc020284c:	06c00593          	li	a1,108
ffffffffc0202850:	00003517          	auipc	a0,0x3
ffffffffc0202854:	97050513          	addi	a0,a0,-1680 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0202858:	b1dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020285c:	00003697          	auipc	a3,0x3
ffffffffc0202860:	90468693          	addi	a3,a3,-1788 # ffffffffc0205160 <default_pmm_manager+0x88>
ffffffffc0202864:	00002617          	auipc	a2,0x2
ffffffffc0202868:	4dc60613          	addi	a2,a2,1244 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020286c:	1fa00593          	li	a1,506
ffffffffc0202870:	00003517          	auipc	a0,0x3
ffffffffc0202874:	8e050513          	addi	a0,a0,-1824 # ffffffffc0205150 <default_pmm_manager+0x78>
ffffffffc0202878:	afdfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020287c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020287c:	7135                	addi	sp,sp,-160
ffffffffc020287e:	ed06                	sd	ra,152(sp)
ffffffffc0202880:	e922                	sd	s0,144(sp)
ffffffffc0202882:	e526                	sd	s1,136(sp)
ffffffffc0202884:	e14a                	sd	s2,128(sp)
ffffffffc0202886:	fcce                	sd	s3,120(sp)
ffffffffc0202888:	f8d2                	sd	s4,112(sp)
ffffffffc020288a:	f4d6                	sd	s5,104(sp)
ffffffffc020288c:	f0da                	sd	s6,96(sp)
ffffffffc020288e:	ecde                	sd	s7,88(sp)
ffffffffc0202890:	e8e2                	sd	s8,80(sp)
ffffffffc0202892:	e4e6                	sd	s9,72(sp)
ffffffffc0202894:	e0ea                	sd	s10,64(sp)
ffffffffc0202896:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202898:	39e010ef          	jal	ra,ffffffffc0203c36 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020289c:	0000f797          	auipc	a5,0xf
ffffffffc02028a0:	ca478793          	addi	a5,a5,-860 # ffffffffc0211540 <max_swap_offset>
ffffffffc02028a4:	6394                	ld	a3,0(a5)
ffffffffc02028a6:	010007b7          	lui	a5,0x1000
ffffffffc02028aa:	17e1                	addi	a5,a5,-8
ffffffffc02028ac:	ff968713          	addi	a4,a3,-7
ffffffffc02028b0:	42e7ea63          	bltu	a5,a4,ffffffffc0202ce4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02028b4:	00007797          	auipc	a5,0x7
ffffffffc02028b8:	74c78793          	addi	a5,a5,1868 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02028bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02028be:	0000f697          	auipc	a3,0xf
ffffffffc02028c2:	baf6b523          	sd	a5,-1110(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc02028c6:	9702                	jalr	a4
ffffffffc02028c8:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02028ca:	c10d                	beqz	a0,ffffffffc02028ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02028cc:	60ea                	ld	ra,152(sp)
ffffffffc02028ce:	644a                	ld	s0,144(sp)
ffffffffc02028d0:	855a                	mv	a0,s6
ffffffffc02028d2:	64aa                	ld	s1,136(sp)
ffffffffc02028d4:	690a                	ld	s2,128(sp)
ffffffffc02028d6:	79e6                	ld	s3,120(sp)
ffffffffc02028d8:	7a46                	ld	s4,112(sp)
ffffffffc02028da:	7aa6                	ld	s5,104(sp)
ffffffffc02028dc:	7b06                	ld	s6,96(sp)
ffffffffc02028de:	6be6                	ld	s7,88(sp)
ffffffffc02028e0:	6c46                	ld	s8,80(sp)
ffffffffc02028e2:	6ca6                	ld	s9,72(sp)
ffffffffc02028e4:	6d06                	ld	s10,64(sp)
ffffffffc02028e6:	7de2                	ld	s11,56(sp)
ffffffffc02028e8:	610d                	addi	sp,sp,160
ffffffffc02028ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028ec:	0000f797          	auipc	a5,0xf
ffffffffc02028f0:	b7c78793          	addi	a5,a5,-1156 # ffffffffc0211468 <sm>
ffffffffc02028f4:	639c                	ld	a5,0(a5)
ffffffffc02028f6:	00003517          	auipc	a0,0x3
ffffffffc02028fa:	f0250513          	addi	a0,a0,-254 # ffffffffc02057f8 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028fe:	0000f417          	auipc	s0,0xf
ffffffffc0202902:	b8240413          	addi	s0,s0,-1150 # ffffffffc0211480 <free_area>
ffffffffc0202906:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202908:	4785                	li	a5,1
ffffffffc020290a:	0000f717          	auipc	a4,0xf
ffffffffc020290e:	b6f72323          	sw	a5,-1178(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202912:	facfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202916:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202918:	2e878a63          	beq	a5,s0,ffffffffc0202c0c <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020291c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202920:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202922:	8b05                	andi	a4,a4,1
ffffffffc0202924:	2e070863          	beqz	a4,ffffffffc0202c14 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc0202928:	4481                	li	s1,0
ffffffffc020292a:	4901                	li	s2,0
ffffffffc020292c:	a031                	j	ffffffffc0202938 <swap_init+0xbc>
ffffffffc020292e:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202932:	8b09                	andi	a4,a4,2
ffffffffc0202934:	2e070063          	beqz	a4,ffffffffc0202c14 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc0202938:	ff87a703          	lw	a4,-8(a5)
ffffffffc020293c:	679c                	ld	a5,8(a5)
ffffffffc020293e:	2905                	addiw	s2,s2,1
ffffffffc0202940:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202942:	fe8796e3          	bne	a5,s0,ffffffffc020292e <swap_init+0xb2>
ffffffffc0202946:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202948:	e55fe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc020294c:	5b351863          	bne	a0,s3,ffffffffc0202efc <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202950:	8626                	mv	a2,s1
ffffffffc0202952:	85ca                	mv	a1,s2
ffffffffc0202954:	00003517          	auipc	a0,0x3
ffffffffc0202958:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205810 <default_pmm_manager+0x738>
ffffffffc020295c:	f62fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202960:	309000ef          	jal	ra,ffffffffc0203468 <mm_create>
ffffffffc0202964:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202966:	50050b63          	beqz	a0,ffffffffc0202e7c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020296a:	0000f797          	auipc	a5,0xf
ffffffffc020296e:	c2e78793          	addi	a5,a5,-978 # ffffffffc0211598 <check_mm_struct>
ffffffffc0202972:	639c                	ld	a5,0(a5)
ffffffffc0202974:	52079463          	bnez	a5,ffffffffc0202e9c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202978:	0000f797          	auipc	a5,0xf
ffffffffc020297c:	ae078793          	addi	a5,a5,-1312 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202980:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202982:	0000f797          	auipc	a5,0xf
ffffffffc0202986:	c0a7bb23          	sd	a0,-1002(a5) # ffffffffc0211598 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020298a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020298c:	ec3a                	sd	a4,24(sp)
ffffffffc020298e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202990:	52079663          	bnez	a5,ffffffffc0202ebc <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202994:	6599                	lui	a1,0x6
ffffffffc0202996:	460d                	li	a2,3
ffffffffc0202998:	6505                	lui	a0,0x1
ffffffffc020299a:	31b000ef          	jal	ra,ffffffffc02034b4 <vma_create>
ffffffffc020299e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02029a0:	52050e63          	beqz	a0,ffffffffc0202edc <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02029a4:	855e                	mv	a0,s7
ffffffffc02029a6:	37b000ef          	jal	ra,ffffffffc0203520 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02029aa:	00003517          	auipc	a0,0x3
ffffffffc02029ae:	ed650513          	addi	a0,a0,-298 # ffffffffc0205880 <default_pmm_manager+0x7a8>
ffffffffc02029b2:	f0cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02029b6:	018bb503          	ld	a0,24(s7)
ffffffffc02029ba:	4605                	li	a2,1
ffffffffc02029bc:	6585                	lui	a1,0x1
ffffffffc02029be:	e1ffe0ef          	jal	ra,ffffffffc02017dc <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02029c2:	40050d63          	beqz	a0,ffffffffc0202ddc <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029c6:	00003517          	auipc	a0,0x3
ffffffffc02029ca:	f0a50513          	addi	a0,a0,-246 # ffffffffc02058d0 <default_pmm_manager+0x7f8>
ffffffffc02029ce:	0000fa17          	auipc	s4,0xf
ffffffffc02029d2:	aeaa0a13          	addi	s4,s4,-1302 # ffffffffc02114b8 <check_rp>
ffffffffc02029d6:	ee8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029da:	0000fa97          	auipc	s5,0xf
ffffffffc02029de:	afea8a93          	addi	s5,s5,-1282 # ffffffffc02114d8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029e2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029e4:	4505                	li	a0,1
ffffffffc02029e6:	ce9fe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
ffffffffc02029ea:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea60>
          assert(check_rp[i] != NULL );
ffffffffc02029ee:	2a050b63          	beqz	a0,ffffffffc0202ca4 <swap_init+0x428>
ffffffffc02029f2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029f4:	8b89                	andi	a5,a5,2
ffffffffc02029f6:	28079763          	bnez	a5,ffffffffc0202c84 <swap_init+0x408>
ffffffffc02029fa:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029fc:	ff5994e3          	bne	s3,s5,ffffffffc02029e4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a00:	601c                	ld	a5,0(s0)
ffffffffc0202a02:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202a06:	0000fd17          	auipc	s10,0xf
ffffffffc0202a0a:	ab2d0d13          	addi	s10,s10,-1358 # ffffffffc02114b8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202a0e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202a10:	481c                	lw	a5,16(s0)
ffffffffc0202a12:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202a14:	0000f797          	auipc	a5,0xf
ffffffffc0202a18:	a687ba23          	sd	s0,-1420(a5) # ffffffffc0211488 <free_area+0x8>
ffffffffc0202a1c:	0000f797          	auipc	a5,0xf
ffffffffc0202a20:	a687b223          	sd	s0,-1436(a5) # ffffffffc0211480 <free_area>
     nr_free = 0;
ffffffffc0202a24:	0000f797          	auipc	a5,0xf
ffffffffc0202a28:	a607a623          	sw	zero,-1428(a5) # ffffffffc0211490 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a2c:	000d3503          	ld	a0,0(s10)
ffffffffc0202a30:	4585                	li	a1,1
ffffffffc0202a32:	0d21                	addi	s10,s10,8
ffffffffc0202a34:	d23fe0ef          	jal	ra,ffffffffc0201756 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a38:	ff5d1ae3          	bne	s10,s5,ffffffffc0202a2c <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a3c:	01042d03          	lw	s10,16(s0)
ffffffffc0202a40:	4791                	li	a5,4
ffffffffc0202a42:	36fd1d63          	bne	s10,a5,ffffffffc0202dbc <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a46:	00003517          	auipc	a0,0x3
ffffffffc0202a4a:	f1250513          	addi	a0,a0,-238 # ffffffffc0205958 <default_pmm_manager+0x880>
ffffffffc0202a4e:	e70fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a52:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a54:	0000f797          	auipc	a5,0xf
ffffffffc0202a58:	a207a023          	sw	zero,-1504(a5) # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a5c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a5e:	0000f797          	auipc	a5,0xf
ffffffffc0202a62:	a1678793          	addi	a5,a5,-1514 # ffffffffc0211474 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a66:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a6a:	4398                	lw	a4,0(a5)
ffffffffc0202a6c:	4585                	li	a1,1
ffffffffc0202a6e:	2701                	sext.w	a4,a4
ffffffffc0202a70:	30b71663          	bne	a4,a1,ffffffffc0202d7c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a74:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a78:	4394                	lw	a3,0(a5)
ffffffffc0202a7a:	2681                	sext.w	a3,a3
ffffffffc0202a7c:	32e69063          	bne	a3,a4,ffffffffc0202d9c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a80:	6689                	lui	a3,0x2
ffffffffc0202a82:	462d                	li	a2,11
ffffffffc0202a84:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a88:	4398                	lw	a4,0(a5)
ffffffffc0202a8a:	4589                	li	a1,2
ffffffffc0202a8c:	2701                	sext.w	a4,a4
ffffffffc0202a8e:	26b71763          	bne	a4,a1,ffffffffc0202cfc <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a92:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a96:	4394                	lw	a3,0(a5)
ffffffffc0202a98:	2681                	sext.w	a3,a3
ffffffffc0202a9a:	28e69163          	bne	a3,a4,ffffffffc0202d1c <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a9e:	668d                	lui	a3,0x3
ffffffffc0202aa0:	4631                	li	a2,12
ffffffffc0202aa2:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202aa6:	4398                	lw	a4,0(a5)
ffffffffc0202aa8:	458d                	li	a1,3
ffffffffc0202aaa:	2701                	sext.w	a4,a4
ffffffffc0202aac:	28b71863          	bne	a4,a1,ffffffffc0202d3c <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202ab0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202ab4:	4394                	lw	a3,0(a5)
ffffffffc0202ab6:	2681                	sext.w	a3,a3
ffffffffc0202ab8:	2ae69263          	bne	a3,a4,ffffffffc0202d5c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202abc:	6691                	lui	a3,0x4
ffffffffc0202abe:	4635                	li	a2,13
ffffffffc0202ac0:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ac4:	4398                	lw	a4,0(a5)
ffffffffc0202ac6:	2701                	sext.w	a4,a4
ffffffffc0202ac8:	33a71a63          	bne	a4,s10,ffffffffc0202dfc <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202acc:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202ad0:	439c                	lw	a5,0(a5)
ffffffffc0202ad2:	2781                	sext.w	a5,a5
ffffffffc0202ad4:	34e79463          	bne	a5,a4,ffffffffc0202e1c <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202ad8:	481c                	lw	a5,16(s0)
ffffffffc0202ada:	36079163          	bnez	a5,ffffffffc0202e3c <swap_init+0x5c0>
ffffffffc0202ade:	0000f797          	auipc	a5,0xf
ffffffffc0202ae2:	9fa78793          	addi	a5,a5,-1542 # ffffffffc02114d8 <swap_in_seq_no>
ffffffffc0202ae6:	0000f717          	auipc	a4,0xf
ffffffffc0202aea:	a1a70713          	addi	a4,a4,-1510 # ffffffffc0211500 <swap_out_seq_no>
ffffffffc0202aee:	0000f617          	auipc	a2,0xf
ffffffffc0202af2:	a1260613          	addi	a2,a2,-1518 # ffffffffc0211500 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202af6:	56fd                	li	a3,-1
ffffffffc0202af8:	c394                	sw	a3,0(a5)
ffffffffc0202afa:	c314                	sw	a3,0(a4)
ffffffffc0202afc:	0791                	addi	a5,a5,4
ffffffffc0202afe:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b00:	fec79ce3          	bne	a5,a2,ffffffffc0202af8 <swap_init+0x27c>
ffffffffc0202b04:	0000f697          	auipc	a3,0xf
ffffffffc0202b08:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0211560 <check_ptep>
ffffffffc0202b0c:	0000f817          	auipc	a6,0xf
ffffffffc0202b10:	9ac80813          	addi	a6,a6,-1620 # ffffffffc02114b8 <check_rp>
ffffffffc0202b14:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202b16:	0000fc97          	auipc	s9,0xf
ffffffffc0202b1a:	94ac8c93          	addi	s9,s9,-1718 # ffffffffc0211460 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1e:	0000fd97          	auipc	s11,0xf
ffffffffc0202b22:	992d8d93          	addi	s11,s11,-1646 # ffffffffc02114b0 <pages>
ffffffffc0202b26:	00003d17          	auipc	s10,0x3
ffffffffc0202b2a:	672d0d13          	addi	s10,s10,1650 # ffffffffc0206198 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b2e:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202b30:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b34:	4601                	li	a2,0
ffffffffc0202b36:	85e2                	mv	a1,s8
ffffffffc0202b38:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202b3a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b3c:	ca1fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0202b40:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b42:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b44:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b46:	16050f63          	beqz	a0,ffffffffc0202cc4 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b4a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b4c:	0017f613          	andi	a2,a5,1
ffffffffc0202b50:	10060263          	beqz	a2,ffffffffc0202c54 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b54:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b58:	078a                	slli	a5,a5,0x2
ffffffffc0202b5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b5c:	10c7f863          	bleu	a2,a5,ffffffffc0202c6c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b60:	000d3603          	ld	a2,0(s10)
ffffffffc0202b64:	000db583          	ld	a1,0(s11)
ffffffffc0202b68:	00083503          	ld	a0,0(a6)
ffffffffc0202b6c:	8f91                	sub	a5,a5,a2
ffffffffc0202b6e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b72:	97b2                	add	a5,a5,a2
ffffffffc0202b74:	078e                	slli	a5,a5,0x3
ffffffffc0202b76:	97ae                	add	a5,a5,a1
ffffffffc0202b78:	0af51e63          	bne	a0,a5,ffffffffc0202c34 <swap_init+0x3b8>
ffffffffc0202b7c:	6785                	lui	a5,0x1
ffffffffc0202b7e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b80:	6795                	lui	a5,0x5
ffffffffc0202b82:	06a1                	addi	a3,a3,8
ffffffffc0202b84:	0821                	addi	a6,a6,8
ffffffffc0202b86:	fafc14e3          	bne	s8,a5,ffffffffc0202b2e <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b8a:	00003517          	auipc	a0,0x3
ffffffffc0202b8e:	e7650513          	addi	a0,a0,-394 # ffffffffc0205a00 <default_pmm_manager+0x928>
ffffffffc0202b92:	d2cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b96:	0000f797          	auipc	a5,0xf
ffffffffc0202b9a:	8d278793          	addi	a5,a5,-1838 # ffffffffc0211468 <sm>
ffffffffc0202b9e:	639c                	ld	a5,0(a5)
ffffffffc0202ba0:	7f9c                	ld	a5,56(a5)
ffffffffc0202ba2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202ba4:	2a051c63          	bnez	a0,ffffffffc0202e5c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202ba8:	000a3503          	ld	a0,0(s4)
ffffffffc0202bac:	4585                	li	a1,1
ffffffffc0202bae:	0a21                	addi	s4,s4,8
ffffffffc0202bb0:	ba7fe0ef          	jal	ra,ffffffffc0201756 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bb4:	ff5a1ae3          	bne	s4,s5,ffffffffc0202ba8 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202bb8:	855e                	mv	a0,s7
ffffffffc0202bba:	235000ef          	jal	ra,ffffffffc02035ee <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202bbe:	77a2                	ld	a5,40(sp)
ffffffffc0202bc0:	0000f717          	auipc	a4,0xf
ffffffffc0202bc4:	8cf72823          	sw	a5,-1840(a4) # ffffffffc0211490 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202bc8:	7782                	ld	a5,32(sp)
ffffffffc0202bca:	0000f717          	auipc	a4,0xf
ffffffffc0202bce:	8af73b23          	sd	a5,-1866(a4) # ffffffffc0211480 <free_area>
ffffffffc0202bd2:	0000f797          	auipc	a5,0xf
ffffffffc0202bd6:	8b37bb23          	sd	s3,-1866(a5) # ffffffffc0211488 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bda:	00898a63          	beq	s3,s0,ffffffffc0202bee <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202bde:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202be2:	0089b983          	ld	s3,8(s3)
ffffffffc0202be6:	397d                	addiw	s2,s2,-1
ffffffffc0202be8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bea:	fe899ae3          	bne	s3,s0,ffffffffc0202bde <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bee:	8626                	mv	a2,s1
ffffffffc0202bf0:	85ca                	mv	a1,s2
ffffffffc0202bf2:	00003517          	auipc	a0,0x3
ffffffffc0202bf6:	e3e50513          	addi	a0,a0,-450 # ffffffffc0205a30 <default_pmm_manager+0x958>
ffffffffc0202bfa:	cc4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bfe:	00003517          	auipc	a0,0x3
ffffffffc0202c02:	e5250513          	addi	a0,a0,-430 # ffffffffc0205a50 <default_pmm_manager+0x978>
ffffffffc0202c06:	cb8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202c0a:	b1c9                	j	ffffffffc02028cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202c0c:	4481                	li	s1,0
ffffffffc0202c0e:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c10:	4981                	li	s3,0
ffffffffc0202c12:	bb1d                	j	ffffffffc0202948 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202c14:	00002697          	auipc	a3,0x2
ffffffffc0202c18:	11c68693          	addi	a3,a3,284 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202c1c:	00002617          	auipc	a2,0x2
ffffffffc0202c20:	12460613          	addi	a2,a2,292 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202c24:	0ba00593          	li	a1,186
ffffffffc0202c28:	00003517          	auipc	a0,0x3
ffffffffc0202c2c:	bc050513          	addi	a0,a0,-1088 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202c30:	f44fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c34:	00003697          	auipc	a3,0x3
ffffffffc0202c38:	da468693          	addi	a3,a3,-604 # ffffffffc02059d8 <default_pmm_manager+0x900>
ffffffffc0202c3c:	00002617          	auipc	a2,0x2
ffffffffc0202c40:	10460613          	addi	a2,a2,260 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202c44:	0fa00593          	li	a1,250
ffffffffc0202c48:	00003517          	auipc	a0,0x3
ffffffffc0202c4c:	ba050513          	addi	a0,a0,-1120 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202c50:	f24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c54:	00002617          	auipc	a2,0x2
ffffffffc0202c58:	74460613          	addi	a2,a2,1860 # ffffffffc0205398 <default_pmm_manager+0x2c0>
ffffffffc0202c5c:	07000593          	li	a1,112
ffffffffc0202c60:	00002517          	auipc	a0,0x2
ffffffffc0202c64:	56050513          	addi	a0,a0,1376 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0202c68:	f0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	53460613          	addi	a2,a2,1332 # ffffffffc02051a0 <default_pmm_manager+0xc8>
ffffffffc0202c74:	06500593          	li	a1,101
ffffffffc0202c78:	00002517          	auipc	a0,0x2
ffffffffc0202c7c:	54850513          	addi	a0,a0,1352 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0202c80:	ef4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	c8c68693          	addi	a3,a3,-884 # ffffffffc0205910 <default_pmm_manager+0x838>
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	0b460613          	addi	a2,a2,180 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202c94:	0db00593          	li	a1,219
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	b5050513          	addi	a0,a0,-1200 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202ca0:	ed4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ca4:	00003697          	auipc	a3,0x3
ffffffffc0202ca8:	c5468693          	addi	a3,a3,-940 # ffffffffc02058f8 <default_pmm_manager+0x820>
ffffffffc0202cac:	00002617          	auipc	a2,0x2
ffffffffc0202cb0:	09460613          	addi	a2,a2,148 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202cb4:	0da00593          	li	a1,218
ffffffffc0202cb8:	00003517          	auipc	a0,0x3
ffffffffc0202cbc:	b3050513          	addi	a0,a0,-1232 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202cc0:	eb4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202cc4:	00003697          	auipc	a3,0x3
ffffffffc0202cc8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02059c0 <default_pmm_manager+0x8e8>
ffffffffc0202ccc:	00002617          	auipc	a2,0x2
ffffffffc0202cd0:	07460613          	addi	a2,a2,116 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202cd4:	0f900593          	li	a1,249
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	b1050513          	addi	a0,a0,-1264 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202ce0:	e94fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202ce4:	00003617          	auipc	a2,0x3
ffffffffc0202ce8:	ae460613          	addi	a2,a2,-1308 # ffffffffc02057c8 <default_pmm_manager+0x6f0>
ffffffffc0202cec:	02700593          	li	a1,39
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	af850513          	addi	a0,a0,-1288 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	c9468693          	addi	a3,a3,-876 # ffffffffc0205990 <default_pmm_manager+0x8b8>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	03c60613          	addi	a2,a2,60 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202d0c:	09500593          	li	a1,149
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	ad850513          	addi	a0,a0,-1320 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	c7468693          	addi	a3,a3,-908 # ffffffffc0205990 <default_pmm_manager+0x8b8>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	01c60613          	addi	a2,a2,28 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202d2c:	09700593          	li	a1,151
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	ab850513          	addi	a0,a0,-1352 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	c6468693          	addi	a3,a3,-924 # ffffffffc02059a0 <default_pmm_manager+0x8c8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202d4c:	09900593          	li	a1,153
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	a9850513          	addi	a0,a0,-1384 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	c4468693          	addi	a3,a3,-956 # ffffffffc02059a0 <default_pmm_manager+0x8c8>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202d6c:	09b00593          	li	a1,155
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	a7850513          	addi	a0,a0,-1416 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202d78:	dfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	c0468693          	addi	a3,a3,-1020 # ffffffffc0205980 <default_pmm_manager+0x8a8>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202d8c:	09100593          	li	a1,145
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	a5850513          	addi	a0,a0,-1448 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202d98:	ddcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	be468693          	addi	a3,a3,-1052 # ffffffffc0205980 <default_pmm_manager+0x8a8>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202dac:	09300593          	li	a1,147
ffffffffc0202db0:	00003517          	auipc	a0,0x3
ffffffffc0202db4:	a3850513          	addi	a0,a0,-1480 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202db8:	dbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	b7468693          	addi	a3,a3,-1164 # ffffffffc0205930 <default_pmm_manager+0x858>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202dcc:	0e800593          	li	a1,232
ffffffffc0202dd0:	00003517          	auipc	a0,0x3
ffffffffc0202dd4:	a1850513          	addi	a0,a0,-1512 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202dd8:	d9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202ddc:	00003697          	auipc	a3,0x3
ffffffffc0202de0:	adc68693          	addi	a3,a3,-1316 # ffffffffc02058b8 <default_pmm_manager+0x7e0>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202dec:	0d500593          	li	a1,213
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202df8:	d7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	bb468693          	addi	a3,a3,-1100 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202e0c:	09d00593          	li	a1,157
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	9d850513          	addi	a0,a0,-1576 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202e18:	d5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	b9468693          	addi	a3,a3,-1132 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202e2c:	09f00593          	li	a1,159
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	9b850513          	addi	a0,a0,-1608 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202e38:	d3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e3c:	00002697          	auipc	a3,0x2
ffffffffc0202e40:	0dc68693          	addi	a3,a3,220 # ffffffffc0204f18 <commands+0xab8>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	efc60613          	addi	a2,a2,-260 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202e4c:	0f100593          	li	a1,241
ffffffffc0202e50:	00003517          	auipc	a0,0x3
ffffffffc0202e54:	99850513          	addi	a0,a0,-1640 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202e58:	d1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e5c:	00003697          	auipc	a3,0x3
ffffffffc0202e60:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0205a28 <default_pmm_manager+0x950>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	edc60613          	addi	a2,a2,-292 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202e6c:	10000593          	li	a1,256
ffffffffc0202e70:	00003517          	auipc	a0,0x3
ffffffffc0202e74:	97850513          	addi	a0,a0,-1672 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202e78:	cfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e7c:	00003697          	auipc	a3,0x3
ffffffffc0202e80:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205838 <default_pmm_manager+0x760>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202e8c:	0c200593          	li	a1,194
ffffffffc0202e90:	00003517          	auipc	a0,0x3
ffffffffc0202e94:	95850513          	addi	a0,a0,-1704 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202e98:	cdcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e9c:	00003697          	auipc	a3,0x3
ffffffffc0202ea0:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0205848 <default_pmm_manager+0x770>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202eac:	0c500593          	li	a1,197
ffffffffc0202eb0:	00003517          	auipc	a0,0x3
ffffffffc0202eb4:	93850513          	addi	a0,a0,-1736 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202eb8:	cbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202ebc:	00003697          	auipc	a3,0x3
ffffffffc0202ec0:	9a468693          	addi	a3,a3,-1628 # ffffffffc0205860 <default_pmm_manager+0x788>
ffffffffc0202ec4:	00002617          	auipc	a2,0x2
ffffffffc0202ec8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202ecc:	0ca00593          	li	a1,202
ffffffffc0202ed0:	00003517          	auipc	a0,0x3
ffffffffc0202ed4:	91850513          	addi	a0,a0,-1768 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202ed8:	c9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202edc:	00003697          	auipc	a3,0x3
ffffffffc0202ee0:	99468693          	addi	a3,a3,-1644 # ffffffffc0205870 <default_pmm_manager+0x798>
ffffffffc0202ee4:	00002617          	auipc	a2,0x2
ffffffffc0202ee8:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202eec:	0cd00593          	li	a1,205
ffffffffc0202ef0:	00003517          	auipc	a0,0x3
ffffffffc0202ef4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202ef8:	c7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202efc:	00002697          	auipc	a3,0x2
ffffffffc0202f00:	e7468693          	addi	a3,a3,-396 # ffffffffc0204d70 <commands+0x910>
ffffffffc0202f04:	00002617          	auipc	a2,0x2
ffffffffc0202f08:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0202f0c:	0bd00593          	li	a1,189
ffffffffc0202f10:	00003517          	auipc	a0,0x3
ffffffffc0202f14:	8d850513          	addi	a0,a0,-1832 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc0202f18:	c5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202f1c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f1c:	0000e797          	auipc	a5,0xe
ffffffffc0202f20:	54c78793          	addi	a5,a5,1356 # ffffffffc0211468 <sm>
ffffffffc0202f24:	639c                	ld	a5,0(a5)
ffffffffc0202f26:	0107b303          	ld	t1,16(a5)
ffffffffc0202f2a:	8302                	jr	t1

ffffffffc0202f2c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f2c:	0000e797          	auipc	a5,0xe
ffffffffc0202f30:	53c78793          	addi	a5,a5,1340 # ffffffffc0211468 <sm>
ffffffffc0202f34:	639c                	ld	a5,0(a5)
ffffffffc0202f36:	0207b303          	ld	t1,32(a5)
ffffffffc0202f3a:	8302                	jr	t1

ffffffffc0202f3c <swap_out>:
{
ffffffffc0202f3c:	711d                	addi	sp,sp,-96
ffffffffc0202f3e:	ec86                	sd	ra,88(sp)
ffffffffc0202f40:	e8a2                	sd	s0,80(sp)
ffffffffc0202f42:	e4a6                	sd	s1,72(sp)
ffffffffc0202f44:	e0ca                	sd	s2,64(sp)
ffffffffc0202f46:	fc4e                	sd	s3,56(sp)
ffffffffc0202f48:	f852                	sd	s4,48(sp)
ffffffffc0202f4a:	f456                	sd	s5,40(sp)
ffffffffc0202f4c:	f05a                	sd	s6,32(sp)
ffffffffc0202f4e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f50:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f52:	cde9                	beqz	a1,ffffffffc020302c <swap_out+0xf0>
ffffffffc0202f54:	8ab2                	mv	s5,a2
ffffffffc0202f56:	892a                	mv	s2,a0
ffffffffc0202f58:	8a2e                	mv	s4,a1
ffffffffc0202f5a:	4401                	li	s0,0
ffffffffc0202f5c:	0000e997          	auipc	s3,0xe
ffffffffc0202f60:	50c98993          	addi	s3,s3,1292 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f64:	00003b17          	auipc	s6,0x3
ffffffffc0202f68:	b6cb0b13          	addi	s6,s6,-1172 # ffffffffc0205ad0 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f6c:	00003b97          	auipc	s7,0x3
ffffffffc0202f70:	b4cb8b93          	addi	s7,s7,-1204 # ffffffffc0205ab8 <default_pmm_manager+0x9e0>
ffffffffc0202f74:	a825                	j	ffffffffc0202fac <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f76:	67a2                	ld	a5,8(sp)
ffffffffc0202f78:	8626                	mv	a2,s1
ffffffffc0202f7a:	85a2                	mv	a1,s0
ffffffffc0202f7c:	63b4                	ld	a3,64(a5)
ffffffffc0202f7e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f80:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f82:	82b1                	srli	a3,a3,0xc
ffffffffc0202f84:	0685                	addi	a3,a3,1
ffffffffc0202f86:	938fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f8a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f8c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f8e:	613c                	ld	a5,64(a0)
ffffffffc0202f90:	83b1                	srli	a5,a5,0xc
ffffffffc0202f92:	0785                	addi	a5,a5,1
ffffffffc0202f94:	07a2                	slli	a5,a5,0x8
ffffffffc0202f96:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f9a:	fbcfe0ef          	jal	ra,ffffffffc0201756 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f9e:	01893503          	ld	a0,24(s2)
ffffffffc0202fa2:	85a6                	mv	a1,s1
ffffffffc0202fa4:	ebeff0ef          	jal	ra,ffffffffc0202662 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202fa8:	048a0d63          	beq	s4,s0,ffffffffc0203002 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202fac:	0009b783          	ld	a5,0(s3)
ffffffffc0202fb0:	8656                	mv	a2,s5
ffffffffc0202fb2:	002c                	addi	a1,sp,8
ffffffffc0202fb4:	7b9c                	ld	a5,48(a5)
ffffffffc0202fb6:	854a                	mv	a0,s2
ffffffffc0202fb8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202fba:	e12d                	bnez	a0,ffffffffc020301c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fbc:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fbe:	01893503          	ld	a0,24(s2)
ffffffffc0202fc2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fc4:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fc6:	85a6                	mv	a1,s1
ffffffffc0202fc8:	815fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fcc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fce:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd0:	8b85                	andi	a5,a5,1
ffffffffc0202fd2:	cfb9                	beqz	a5,ffffffffc0203030 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fd4:	65a2                	ld	a1,8(sp)
ffffffffc0202fd6:	61bc                	ld	a5,64(a1)
ffffffffc0202fd8:	83b1                	srli	a5,a5,0xc
ffffffffc0202fda:	00178513          	addi	a0,a5,1
ffffffffc0202fde:	0522                	slli	a0,a0,0x8
ffffffffc0202fe0:	535000ef          	jal	ra,ffffffffc0203d14 <swapfs_write>
ffffffffc0202fe4:	d949                	beqz	a0,ffffffffc0202f76 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fe6:	855e                	mv	a0,s7
ffffffffc0202fe8:	8d6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fec:	0009b783          	ld	a5,0(s3)
ffffffffc0202ff0:	6622                	ld	a2,8(sp)
ffffffffc0202ff2:	4681                	li	a3,0
ffffffffc0202ff4:	739c                	ld	a5,32(a5)
ffffffffc0202ff6:	85a6                	mv	a1,s1
ffffffffc0202ff8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ffa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ffc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202ffe:	fa8a17e3          	bne	s4,s0,ffffffffc0202fac <swap_out+0x70>
}
ffffffffc0203002:	8522                	mv	a0,s0
ffffffffc0203004:	60e6                	ld	ra,88(sp)
ffffffffc0203006:	6446                	ld	s0,80(sp)
ffffffffc0203008:	64a6                	ld	s1,72(sp)
ffffffffc020300a:	6906                	ld	s2,64(sp)
ffffffffc020300c:	79e2                	ld	s3,56(sp)
ffffffffc020300e:	7a42                	ld	s4,48(sp)
ffffffffc0203010:	7aa2                	ld	s5,40(sp)
ffffffffc0203012:	7b02                	ld	s6,32(sp)
ffffffffc0203014:	6be2                	ld	s7,24(sp)
ffffffffc0203016:	6c42                	ld	s8,16(sp)
ffffffffc0203018:	6125                	addi	sp,sp,96
ffffffffc020301a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020301c:	85a2                	mv	a1,s0
ffffffffc020301e:	00003517          	auipc	a0,0x3
ffffffffc0203022:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205a70 <default_pmm_manager+0x998>
ffffffffc0203026:	898fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc020302a:	bfe1                	j	ffffffffc0203002 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020302c:	4401                	li	s0,0
ffffffffc020302e:	bfd1                	j	ffffffffc0203002 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203030:	00003697          	auipc	a3,0x3
ffffffffc0203034:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205aa0 <default_pmm_manager+0x9c8>
ffffffffc0203038:	00002617          	auipc	a2,0x2
ffffffffc020303c:	d0860613          	addi	a2,a2,-760 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203040:	06600593          	li	a1,102
ffffffffc0203044:	00002517          	auipc	a0,0x2
ffffffffc0203048:	7a450513          	addi	a0,a0,1956 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc020304c:	b28fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203050 <swap_in>:
{
ffffffffc0203050:	7179                	addi	sp,sp,-48
ffffffffc0203052:	e84a                	sd	s2,16(sp)
ffffffffc0203054:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203056:	4505                	li	a0,1
{
ffffffffc0203058:	ec26                	sd	s1,24(sp)
ffffffffc020305a:	e44e                	sd	s3,8(sp)
ffffffffc020305c:	f406                	sd	ra,40(sp)
ffffffffc020305e:	f022                	sd	s0,32(sp)
ffffffffc0203060:	84ae                	mv	s1,a1
ffffffffc0203062:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203064:	e6afe0ef          	jal	ra,ffffffffc02016ce <alloc_pages>
     assert(result!=NULL);
ffffffffc0203068:	c129                	beqz	a0,ffffffffc02030aa <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020306a:	842a                	mv	s0,a0
ffffffffc020306c:	01893503          	ld	a0,24(s2)
ffffffffc0203070:	4601                	li	a2,0
ffffffffc0203072:	85a6                	mv	a1,s1
ffffffffc0203074:	f68fe0ef          	jal	ra,ffffffffc02017dc <get_pte>
ffffffffc0203078:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020307a:	6108                	ld	a0,0(a0)
ffffffffc020307c:	85a2                	mv	a1,s0
ffffffffc020307e:	3f1000ef          	jal	ra,ffffffffc0203c6e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203082:	00093583          	ld	a1,0(s2)
ffffffffc0203086:	8626                	mv	a2,s1
ffffffffc0203088:	00002517          	auipc	a0,0x2
ffffffffc020308c:	70050513          	addi	a0,a0,1792 # ffffffffc0205788 <default_pmm_manager+0x6b0>
ffffffffc0203090:	81a1                	srli	a1,a1,0x8
ffffffffc0203092:	82cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203096:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203098:	0089b023          	sd	s0,0(s3)
}
ffffffffc020309c:	7402                	ld	s0,32(sp)
ffffffffc020309e:	64e2                	ld	s1,24(sp)
ffffffffc02030a0:	6942                	ld	s2,16(sp)
ffffffffc02030a2:	69a2                	ld	s3,8(sp)
ffffffffc02030a4:	4501                	li	a0,0
ffffffffc02030a6:	6145                	addi	sp,sp,48
ffffffffc02030a8:	8082                	ret
     assert(result!=NULL);
ffffffffc02030aa:	00002697          	auipc	a3,0x2
ffffffffc02030ae:	6ce68693          	addi	a3,a3,1742 # ffffffffc0205778 <default_pmm_manager+0x6a0>
ffffffffc02030b2:	00002617          	auipc	a2,0x2
ffffffffc02030b6:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02030ba:	07c00593          	li	a1,124
ffffffffc02030be:	00002517          	auipc	a0,0x2
ffffffffc02030c2:	72a50513          	addi	a0,a0,1834 # ffffffffc02057e8 <default_pmm_manager+0x710>
ffffffffc02030c6:	aaefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02030ca <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02030ca:	0000e797          	auipc	a5,0xe
ffffffffc02030ce:	4b678793          	addi	a5,a5,1206 # ffffffffc0211580 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
ffffffffc02030d2:	f51c                	sd	a5,40(a0)
ffffffffc02030d4:	e79c                	sd	a5,8(a5)
ffffffffc02030d6:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc02030d8:	0000e717          	auipc	a4,0xe
ffffffffc02030dc:	4af73c23          	sd	a5,1208(a4) # ffffffffc0211590 <curr_ptr>
     return 0;
}
ffffffffc02030e0:	4501                	li	a0,0
ffffffffc02030e2:	8082                	ret

ffffffffc02030e4 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02030e4:	4501                	li	a0,0
ffffffffc02030e6:	8082                	ret

ffffffffc02030e8 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02030e8:	4501                	li	a0,0
ffffffffc02030ea:	8082                	ret

ffffffffc02030ec <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02030ec:	4501                	li	a0,0
ffffffffc02030ee:	8082                	ret

ffffffffc02030f0 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02030f0:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030f2:	678d                	lui	a5,0x3
ffffffffc02030f4:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02030f6:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030f8:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02030fc:	0000e797          	auipc	a5,0xe
ffffffffc0203100:	37878793          	addi	a5,a5,888 # ffffffffc0211474 <pgfault_num>
ffffffffc0203104:	4398                	lw	a4,0(a5)
ffffffffc0203106:	4691                	li	a3,4
ffffffffc0203108:	2701                	sext.w	a4,a4
ffffffffc020310a:	08d71f63          	bne	a4,a3,ffffffffc02031a8 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020310e:	6685                	lui	a3,0x1
ffffffffc0203110:	4629                	li	a2,10
ffffffffc0203112:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203116:	4394                	lw	a3,0(a5)
ffffffffc0203118:	2681                	sext.w	a3,a3
ffffffffc020311a:	20e69763          	bne	a3,a4,ffffffffc0203328 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020311e:	6711                	lui	a4,0x4
ffffffffc0203120:	4635                	li	a2,13
ffffffffc0203122:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203126:	4398                	lw	a4,0(a5)
ffffffffc0203128:	2701                	sext.w	a4,a4
ffffffffc020312a:	1cd71f63          	bne	a4,a3,ffffffffc0203308 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020312e:	6689                	lui	a3,0x2
ffffffffc0203130:	462d                	li	a2,11
ffffffffc0203132:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203136:	4394                	lw	a3,0(a5)
ffffffffc0203138:	2681                	sext.w	a3,a3
ffffffffc020313a:	1ae69763          	bne	a3,a4,ffffffffc02032e8 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020313e:	6715                	lui	a4,0x5
ffffffffc0203140:	46b9                	li	a3,14
ffffffffc0203142:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203146:	4398                	lw	a4,0(a5)
ffffffffc0203148:	4695                	li	a3,5
ffffffffc020314a:	2701                	sext.w	a4,a4
ffffffffc020314c:	16d71e63          	bne	a4,a3,ffffffffc02032c8 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203150:	4394                	lw	a3,0(a5)
ffffffffc0203152:	2681                	sext.w	a3,a3
ffffffffc0203154:	14e69a63          	bne	a3,a4,ffffffffc02032a8 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc0203158:	4398                	lw	a4,0(a5)
ffffffffc020315a:	2701                	sext.w	a4,a4
ffffffffc020315c:	12d71663          	bne	a4,a3,ffffffffc0203288 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203160:	4394                	lw	a3,0(a5)
ffffffffc0203162:	2681                	sext.w	a3,a3
ffffffffc0203164:	10e69263          	bne	a3,a4,ffffffffc0203268 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc0203168:	4398                	lw	a4,0(a5)
ffffffffc020316a:	2701                	sext.w	a4,a4
ffffffffc020316c:	0cd71e63          	bne	a4,a3,ffffffffc0203248 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203170:	4394                	lw	a3,0(a5)
ffffffffc0203172:	2681                	sext.w	a3,a3
ffffffffc0203174:	0ae69a63          	bne	a3,a4,ffffffffc0203228 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203178:	6715                	lui	a4,0x5
ffffffffc020317a:	46b9                	li	a3,14
ffffffffc020317c:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203180:	4398                	lw	a4,0(a5)
ffffffffc0203182:	4695                	li	a3,5
ffffffffc0203184:	2701                	sext.w	a4,a4
ffffffffc0203186:	08d71163          	bne	a4,a3,ffffffffc0203208 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020318a:	6705                	lui	a4,0x1
ffffffffc020318c:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203190:	4729                	li	a4,10
ffffffffc0203192:	04e69b63          	bne	a3,a4,ffffffffc02031e8 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc0203196:	439c                	lw	a5,0(a5)
ffffffffc0203198:	4719                	li	a4,6
ffffffffc020319a:	2781                	sext.w	a5,a5
ffffffffc020319c:	02e79663          	bne	a5,a4,ffffffffc02031c8 <_clock_check_swap+0xd8>
}
ffffffffc02031a0:	60a2                	ld	ra,8(sp)
ffffffffc02031a2:	4501                	li	a0,0
ffffffffc02031a4:	0141                	addi	sp,sp,16
ffffffffc02031a6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02031a8:	00003697          	auipc	a3,0x3
ffffffffc02031ac:	80868693          	addi	a3,a3,-2040 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc02031b0:	00002617          	auipc	a2,0x2
ffffffffc02031b4:	b9060613          	addi	a2,a2,-1136 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02031b8:	08c00593          	li	a1,140
ffffffffc02031bc:	00003517          	auipc	a0,0x3
ffffffffc02031c0:	95450513          	addi	a0,a0,-1708 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc02031c4:	9b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc02031c8:	00003697          	auipc	a3,0x3
ffffffffc02031cc:	99868693          	addi	a3,a3,-1640 # ffffffffc0205b60 <default_pmm_manager+0xa88>
ffffffffc02031d0:	00002617          	auipc	a2,0x2
ffffffffc02031d4:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02031d8:	0a300593          	li	a1,163
ffffffffc02031dc:	00003517          	auipc	a0,0x3
ffffffffc02031e0:	93450513          	addi	a0,a0,-1740 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc02031e4:	990fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031e8:	00003697          	auipc	a3,0x3
ffffffffc02031ec:	95068693          	addi	a3,a3,-1712 # ffffffffc0205b38 <default_pmm_manager+0xa60>
ffffffffc02031f0:	00002617          	auipc	a2,0x2
ffffffffc02031f4:	b5060613          	addi	a2,a2,-1200 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02031f8:	0a100593          	li	a1,161
ffffffffc02031fc:	00003517          	auipc	a0,0x3
ffffffffc0203200:	91450513          	addi	a0,a0,-1772 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203204:	970fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203208:	00003697          	auipc	a3,0x3
ffffffffc020320c:	92068693          	addi	a3,a3,-1760 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc0203210:	00002617          	auipc	a2,0x2
ffffffffc0203214:	b3060613          	addi	a2,a2,-1232 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203218:	0a000593          	li	a1,160
ffffffffc020321c:	00003517          	auipc	a0,0x3
ffffffffc0203220:	8f450513          	addi	a0,a0,-1804 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203224:	950fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203228:	00003697          	auipc	a3,0x3
ffffffffc020322c:	90068693          	addi	a3,a3,-1792 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc0203230:	00002617          	auipc	a2,0x2
ffffffffc0203234:	b1060613          	addi	a2,a2,-1264 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203238:	09e00593          	li	a1,158
ffffffffc020323c:	00003517          	auipc	a0,0x3
ffffffffc0203240:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203244:	930fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203248:	00003697          	auipc	a3,0x3
ffffffffc020324c:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc0203250:	00002617          	auipc	a2,0x2
ffffffffc0203254:	af060613          	addi	a2,a2,-1296 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203258:	09c00593          	li	a1,156
ffffffffc020325c:	00003517          	auipc	a0,0x3
ffffffffc0203260:	8b450513          	addi	a0,a0,-1868 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203264:	910fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203268:	00003697          	auipc	a3,0x3
ffffffffc020326c:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc0203270:	00002617          	auipc	a2,0x2
ffffffffc0203274:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203278:	09a00593          	li	a1,154
ffffffffc020327c:	00003517          	auipc	a0,0x3
ffffffffc0203280:	89450513          	addi	a0,a0,-1900 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203284:	8f0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203288:	00003697          	auipc	a3,0x3
ffffffffc020328c:	8a068693          	addi	a3,a3,-1888 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc0203290:	00002617          	auipc	a2,0x2
ffffffffc0203294:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203298:	09800593          	li	a1,152
ffffffffc020329c:	00003517          	auipc	a0,0x3
ffffffffc02032a0:	87450513          	addi	a0,a0,-1932 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc02032a4:	8d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032a8:	00003697          	auipc	a3,0x3
ffffffffc02032ac:	88068693          	addi	a3,a3,-1920 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc02032b0:	00002617          	auipc	a2,0x2
ffffffffc02032b4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02032b8:	09600593          	li	a1,150
ffffffffc02032bc:	00003517          	auipc	a0,0x3
ffffffffc02032c0:	85450513          	addi	a0,a0,-1964 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc02032c4:	8b0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02032c8:	00003697          	auipc	a3,0x3
ffffffffc02032cc:	86068693          	addi	a3,a3,-1952 # ffffffffc0205b28 <default_pmm_manager+0xa50>
ffffffffc02032d0:	00002617          	auipc	a2,0x2
ffffffffc02032d4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02032d8:	09400593          	li	a1,148
ffffffffc02032dc:	00003517          	auipc	a0,0x3
ffffffffc02032e0:	83450513          	addi	a0,a0,-1996 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc02032e4:	890fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032e8:	00002697          	auipc	a3,0x2
ffffffffc02032ec:	6c868693          	addi	a3,a3,1736 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc02032f0:	00002617          	auipc	a2,0x2
ffffffffc02032f4:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02032f8:	09200593          	li	a1,146
ffffffffc02032fc:	00003517          	auipc	a0,0x3
ffffffffc0203300:	81450513          	addi	a0,a0,-2028 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203304:	870fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203308:	00002697          	auipc	a3,0x2
ffffffffc020330c:	6a868693          	addi	a3,a3,1704 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc0203310:	00002617          	auipc	a2,0x2
ffffffffc0203314:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203318:	09000593          	li	a1,144
ffffffffc020331c:	00002517          	auipc	a0,0x2
ffffffffc0203320:	7f450513          	addi	a0,a0,2036 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203324:	850fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203328:	00002697          	auipc	a3,0x2
ffffffffc020332c:	68868693          	addi	a3,a3,1672 # ffffffffc02059b0 <default_pmm_manager+0x8d8>
ffffffffc0203330:	00002617          	auipc	a2,0x2
ffffffffc0203334:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203338:	08e00593          	li	a1,142
ffffffffc020333c:	00002517          	auipc	a0,0x2
ffffffffc0203340:	7d450513          	addi	a0,a0,2004 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203344:	830fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203348 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203348:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc020334c:	c395                	beqz	a5,ffffffffc0203370 <_clock_map_swappable+0x28>
ffffffffc020334e:	0000e717          	auipc	a4,0xe
ffffffffc0203352:	24270713          	addi	a4,a4,578 # ffffffffc0211590 <curr_ptr>
ffffffffc0203356:	6318                	ld	a4,0(a4)
ffffffffc0203358:	cf01                	beqz	a4,ffffffffc0203370 <_clock_map_swappable+0x28>
    list_add(head->prev, entry);
ffffffffc020335a:	7518                	ld	a4,40(a0)
}
ffffffffc020335c:	4501                	li	a0,0
    list_add(head->prev, entry);
ffffffffc020335e:	6318                	ld	a4,0(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203360:	6714                	ld	a3,8(a4)
    prev->next = next->prev = elm;
ffffffffc0203362:	e29c                	sd	a5,0(a3)
ffffffffc0203364:	e71c                	sd	a5,8(a4)
    page->visited = 1;
ffffffffc0203366:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203368:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc020336a:	fa18                	sd	a4,48(a2)
ffffffffc020336c:	ea1c                	sd	a5,16(a2)
}
ffffffffc020336e:	8082                	ret
{
ffffffffc0203370:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203372:	00002697          	auipc	a3,0x2
ffffffffc0203376:	7fe68693          	addi	a3,a3,2046 # ffffffffc0205b70 <default_pmm_manager+0xa98>
ffffffffc020337a:	00002617          	auipc	a2,0x2
ffffffffc020337e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203382:	03600593          	li	a1,54
ffffffffc0203386:	00002517          	auipc	a0,0x2
ffffffffc020338a:	78a50513          	addi	a0,a0,1930 # ffffffffc0205b10 <default_pmm_manager+0xa38>
{
ffffffffc020338e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203390:	fe5fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203394 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203394:	7508                	ld	a0,40(a0)
{
ffffffffc0203396:	1141                	addi	sp,sp,-16
ffffffffc0203398:	e406                	sd	ra,8(sp)
ffffffffc020339a:	e022                	sd	s0,0(sp)
         assert(head != NULL);
ffffffffc020339c:	c525                	beqz	a0,ffffffffc0203404 <_clock_swap_out_victim+0x70>
     assert(in_tick==0);
ffffffffc020339e:	e259                	bnez	a2,ffffffffc0203424 <_clock_swap_out_victim+0x90>
ffffffffc02033a0:	0000e417          	auipc	s0,0xe
ffffffffc02033a4:	1f040413          	addi	s0,s0,496 # ffffffffc0211590 <curr_ptr>
ffffffffc02033a8:	601c                	ld	a5,0(s0)
ffffffffc02033aa:	4681                	li	a3,0
    return listelm->next;
ffffffffc02033ac:	4605                	li	a2,1
        if (curr_ptr == head){  // 由于是将页面page插入到页面链表pra_list_head的末尾，所以pra_list_head制起标识头部的作用，跳过
ffffffffc02033ae:	00a78c63          	beq	a5,a0,ffffffffc02033c6 <_clock_swap_out_victim+0x32>
        if (curr_page->visited != 1){
ffffffffc02033b2:	fe07b703          	ld	a4,-32(a5)
ffffffffc02033b6:	00c71e63          	bne	a4,a2,ffffffffc02033d2 <_clock_swap_out_victim+0x3e>
            curr_page->visited = 0;
ffffffffc02033ba:	fe07b023          	sd	zero,-32(a5)
ffffffffc02033be:	679c                	ld	a5,8(a5)
        if (curr_ptr == head){  // 由于是将页面page插入到页面链表pra_list_head的末尾，所以pra_list_head制起标识头部的作用，跳过
ffffffffc02033c0:	4685                	li	a3,1
ffffffffc02033c2:	fea798e3          	bne	a5,a0,ffffffffc02033b2 <_clock_swap_out_victim+0x1e>
ffffffffc02033c6:	679c                	ld	a5,8(a5)
ffffffffc02033c8:	4685                	li	a3,1
        if (curr_page->visited != 1){
ffffffffc02033ca:	fe07b703          	ld	a4,-32(a5)
ffffffffc02033ce:	fec706e3          	beq	a4,a2,ffffffffc02033ba <_clock_swap_out_victim+0x26>
ffffffffc02033d2:	c689                	beqz	a3,ffffffffc02033dc <_clock_swap_out_victim+0x48>
ffffffffc02033d4:	0000e717          	auipc	a4,0xe
ffffffffc02033d8:	1af73e23          	sd	a5,444(a4) # ffffffffc0211590 <curr_ptr>
        curr_page = le2page(curr_ptr, pra_page_link);
ffffffffc02033dc:	fd078713          	addi	a4,a5,-48
            *ptr_page = curr_page;
ffffffffc02033e0:	e198                	sd	a4,0(a1)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc02033e2:	00002517          	auipc	a0,0x2
ffffffffc02033e6:	7d650513          	addi	a0,a0,2006 # ffffffffc0205bb8 <default_pmm_manager+0xae0>
ffffffffc02033ea:	85be                	mv	a1,a5
ffffffffc02033ec:	cd3fc0ef          	jal	ra,ffffffffc02000be <cprintf>
            list_del(curr_ptr);
ffffffffc02033f0:	601c                	ld	a5,0(s0)
}
ffffffffc02033f2:	60a2                	ld	ra,8(sp)
ffffffffc02033f4:	6402                	ld	s0,0(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033f6:	6398                	ld	a4,0(a5)
ffffffffc02033f8:	679c                	ld	a5,8(a5)
ffffffffc02033fa:	4501                	li	a0,0
    prev->next = next;
ffffffffc02033fc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033fe:	e398                	sd	a4,0(a5)
ffffffffc0203400:	0141                	addi	sp,sp,16
ffffffffc0203402:	8082                	ret
         assert(head != NULL);
ffffffffc0203404:	00002697          	auipc	a3,0x2
ffffffffc0203408:	79468693          	addi	a3,a3,1940 # ffffffffc0205b98 <default_pmm_manager+0xac0>
ffffffffc020340c:	00002617          	auipc	a2,0x2
ffffffffc0203410:	93460613          	addi	a2,a2,-1740 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203414:	04900593          	li	a1,73
ffffffffc0203418:	00002517          	auipc	a0,0x2
ffffffffc020341c:	6f850513          	addi	a0,a0,1784 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203420:	f55fc0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(in_tick==0);
ffffffffc0203424:	00002697          	auipc	a3,0x2
ffffffffc0203428:	78468693          	addi	a3,a3,1924 # ffffffffc0205ba8 <default_pmm_manager+0xad0>
ffffffffc020342c:	00002617          	auipc	a2,0x2
ffffffffc0203430:	91460613          	addi	a2,a2,-1772 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203434:	04a00593          	li	a1,74
ffffffffc0203438:	00002517          	auipc	a0,0x2
ffffffffc020343c:	6d850513          	addi	a0,a0,1752 # ffffffffc0205b10 <default_pmm_manager+0xa38>
ffffffffc0203440:	f35fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203444 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203444:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203446:	00002697          	auipc	a3,0x2
ffffffffc020344a:	79a68693          	addi	a3,a3,1946 # ffffffffc0205be0 <default_pmm_manager+0xb08>
ffffffffc020344e:	00002617          	auipc	a2,0x2
ffffffffc0203452:	8f260613          	addi	a2,a2,-1806 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203456:	07d00593          	li	a1,125
ffffffffc020345a:	00002517          	auipc	a0,0x2
ffffffffc020345e:	7a650513          	addi	a0,a0,1958 # ffffffffc0205c00 <default_pmm_manager+0xb28>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203462:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203464:	f11fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203468 <mm_create>:
mm_create(void) {
ffffffffc0203468:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020346a:	03000513          	li	a0,48
mm_create(void) {
ffffffffc020346e:	e022                	sd	s0,0(sp)
ffffffffc0203470:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203472:	a88ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc0203476:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203478:	c115                	beqz	a0,ffffffffc020349c <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020347a:	0000e797          	auipc	a5,0xe
ffffffffc020347e:	ff678793          	addi	a5,a5,-10 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203482:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203484:	e408                	sd	a0,8(s0)
ffffffffc0203486:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0203488:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020348c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203490:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203494:	2781                	sext.w	a5,a5
ffffffffc0203496:	eb81                	bnez	a5,ffffffffc02034a6 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0203498:	02053423          	sd	zero,40(a0)
}
ffffffffc020349c:	8522                	mv	a0,s0
ffffffffc020349e:	60a2                	ld	ra,8(sp)
ffffffffc02034a0:	6402                	ld	s0,0(sp)
ffffffffc02034a2:	0141                	addi	sp,sp,16
ffffffffc02034a4:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02034a6:	a77ff0ef          	jal	ra,ffffffffc0202f1c <swap_init_mm>
}
ffffffffc02034aa:	8522                	mv	a0,s0
ffffffffc02034ac:	60a2                	ld	ra,8(sp)
ffffffffc02034ae:	6402                	ld	s0,0(sp)
ffffffffc02034b0:	0141                	addi	sp,sp,16
ffffffffc02034b2:	8082                	ret

ffffffffc02034b4 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034b4:	1101                	addi	sp,sp,-32
ffffffffc02034b6:	e04a                	sd	s2,0(sp)
ffffffffc02034b8:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ba:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034be:	e822                	sd	s0,16(sp)
ffffffffc02034c0:	e426                	sd	s1,8(sp)
ffffffffc02034c2:	ec06                	sd	ra,24(sp)
ffffffffc02034c4:	84ae                	mv	s1,a1
ffffffffc02034c6:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034c8:	a32ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
    if (vma != NULL) {
ffffffffc02034cc:	c509                	beqz	a0,ffffffffc02034d6 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034ce:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034d2:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034d4:	ed00                	sd	s0,24(a0)
}
ffffffffc02034d6:	60e2                	ld	ra,24(sp)
ffffffffc02034d8:	6442                	ld	s0,16(sp)
ffffffffc02034da:	64a2                	ld	s1,8(sp)
ffffffffc02034dc:	6902                	ld	s2,0(sp)
ffffffffc02034de:	6105                	addi	sp,sp,32
ffffffffc02034e0:	8082                	ret

ffffffffc02034e2 <find_vma>:
    if (mm != NULL) {
ffffffffc02034e2:	c51d                	beqz	a0,ffffffffc0203510 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034e4:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034e6:	c781                	beqz	a5,ffffffffc02034ee <find_vma+0xc>
ffffffffc02034e8:	6798                	ld	a4,8(a5)
ffffffffc02034ea:	02e5f663          	bleu	a4,a1,ffffffffc0203516 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034ee:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034f0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034f2:	00f50f63          	beq	a0,a5,ffffffffc0203510 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034f6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034fa:	fee5ebe3          	bltu	a1,a4,ffffffffc02034f0 <find_vma+0xe>
ffffffffc02034fe:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203502:	fee5f7e3          	bleu	a4,a1,ffffffffc02034f0 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203506:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203508:	c781                	beqz	a5,ffffffffc0203510 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020350a:	e91c                	sd	a5,16(a0)
}
ffffffffc020350c:	853e                	mv	a0,a5
ffffffffc020350e:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203510:	4781                	li	a5,0
}
ffffffffc0203512:	853e                	mv	a0,a5
ffffffffc0203514:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203516:	6b98                	ld	a4,16(a5)
ffffffffc0203518:	fce5fbe3          	bleu	a4,a1,ffffffffc02034ee <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020351c:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020351e:	b7fd                	j	ffffffffc020350c <find_vma+0x2a>

ffffffffc0203520 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203520:	6590                	ld	a2,8(a1)
ffffffffc0203522:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203526:	1141                	addi	sp,sp,-16
ffffffffc0203528:	e406                	sd	ra,8(sp)
ffffffffc020352a:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020352c:	01066863          	bltu	a2,a6,ffffffffc020353c <insert_vma_struct+0x1c>
ffffffffc0203530:	a8b9                	j	ffffffffc020358e <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203532:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203536:	04d66763          	bltu	a2,a3,ffffffffc0203584 <insert_vma_struct+0x64>
ffffffffc020353a:	873e                	mv	a4,a5
ffffffffc020353c:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020353e:	fef51ae3          	bne	a0,a5,ffffffffc0203532 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203542:	02a70463          	beq	a4,a0,ffffffffc020356a <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203546:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020354a:	fe873883          	ld	a7,-24(a4)
ffffffffc020354e:	08d8f063          	bleu	a3,a7,ffffffffc02035ce <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203552:	04d66e63          	bltu	a2,a3,ffffffffc02035ae <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203556:	00f50a63          	beq	a0,a5,ffffffffc020356a <insert_vma_struct+0x4a>
ffffffffc020355a:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020355e:	0506e863          	bltu	a3,a6,ffffffffc02035ae <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203562:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203566:	02c6f263          	bleu	a2,a3,ffffffffc020358a <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020356a:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020356c:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020356e:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203572:	e390                	sd	a2,0(a5)
ffffffffc0203574:	e710                	sd	a2,8(a4)
}
ffffffffc0203576:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203578:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020357a:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020357c:	2685                	addiw	a3,a3,1
ffffffffc020357e:	d114                	sw	a3,32(a0)
}
ffffffffc0203580:	0141                	addi	sp,sp,16
ffffffffc0203582:	8082                	ret
    if (le_prev != list) {
ffffffffc0203584:	fca711e3          	bne	a4,a0,ffffffffc0203546 <insert_vma_struct+0x26>
ffffffffc0203588:	bfd9                	j	ffffffffc020355e <insert_vma_struct+0x3e>
ffffffffc020358a:	ebbff0ef          	jal	ra,ffffffffc0203444 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020358e:	00002697          	auipc	a3,0x2
ffffffffc0203592:	70268693          	addi	a3,a3,1794 # ffffffffc0205c90 <default_pmm_manager+0xbb8>
ffffffffc0203596:	00001617          	auipc	a2,0x1
ffffffffc020359a:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020359e:	08400593          	li	a1,132
ffffffffc02035a2:	00002517          	auipc	a0,0x2
ffffffffc02035a6:	65e50513          	addi	a0,a0,1630 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02035aa:	dcbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035ae:	00002697          	auipc	a3,0x2
ffffffffc02035b2:	72268693          	addi	a3,a3,1826 # ffffffffc0205cd0 <default_pmm_manager+0xbf8>
ffffffffc02035b6:	00001617          	auipc	a2,0x1
ffffffffc02035ba:	78a60613          	addi	a2,a2,1930 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02035be:	07c00593          	li	a1,124
ffffffffc02035c2:	00002517          	auipc	a0,0x2
ffffffffc02035c6:	63e50513          	addi	a0,a0,1598 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02035ca:	dabfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035ce:	00002697          	auipc	a3,0x2
ffffffffc02035d2:	6e268693          	addi	a3,a3,1762 # ffffffffc0205cb0 <default_pmm_manager+0xbd8>
ffffffffc02035d6:	00001617          	auipc	a2,0x1
ffffffffc02035da:	76a60613          	addi	a2,a2,1898 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02035de:	07b00593          	li	a1,123
ffffffffc02035e2:	00002517          	auipc	a0,0x2
ffffffffc02035e6:	61e50513          	addi	a0,a0,1566 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02035ea:	d8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035ee <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035ee:	1141                	addi	sp,sp,-16
ffffffffc02035f0:	e022                	sd	s0,0(sp)
ffffffffc02035f2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035f4:	6508                	ld	a0,8(a0)
ffffffffc02035f6:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035f8:	00a40e63          	beq	s0,a0,ffffffffc0203614 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035fc:	6118                	ld	a4,0(a0)
ffffffffc02035fe:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203600:	03000593          	li	a1,48
ffffffffc0203604:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203606:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203608:	e398                	sd	a4,0(a5)
ffffffffc020360a:	9b2ff0ef          	jal	ra,ffffffffc02027bc <kfree>
    return listelm->next;
ffffffffc020360e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203610:	fea416e3          	bne	s0,a0,ffffffffc02035fc <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203614:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203616:	6402                	ld	s0,0(sp)
ffffffffc0203618:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020361a:	03000593          	li	a1,48
}
ffffffffc020361e:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203620:	99cff06f          	j	ffffffffc02027bc <kfree>

ffffffffc0203624 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203624:	715d                	addi	sp,sp,-80
ffffffffc0203626:	e486                	sd	ra,72(sp)
ffffffffc0203628:	e0a2                	sd	s0,64(sp)
ffffffffc020362a:	fc26                	sd	s1,56(sp)
ffffffffc020362c:	f84a                	sd	s2,48(sp)
ffffffffc020362e:	f052                	sd	s4,32(sp)
ffffffffc0203630:	f44e                	sd	s3,40(sp)
ffffffffc0203632:	ec56                	sd	s5,24(sp)
ffffffffc0203634:	e85a                	sd	s6,16(sp)
ffffffffc0203636:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203638:	964fe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc020363c:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020363e:	95efe0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc0203642:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203644:	e25ff0ef          	jal	ra,ffffffffc0203468 <mm_create>
    assert(mm != NULL);
ffffffffc0203648:	842a                	mv	s0,a0
ffffffffc020364a:	03200493          	li	s1,50
ffffffffc020364e:	e919                	bnez	a0,ffffffffc0203664 <vmm_init+0x40>
ffffffffc0203650:	aeed                	j	ffffffffc0203a4a <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203652:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203654:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203656:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020365a:	14ed                	addi	s1,s1,-5
ffffffffc020365c:	8522                	mv	a0,s0
ffffffffc020365e:	ec3ff0ef          	jal	ra,ffffffffc0203520 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203662:	c88d                	beqz	s1,ffffffffc0203694 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203664:	03000513          	li	a0,48
ffffffffc0203668:	892ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc020366c:	85aa                	mv	a1,a0
ffffffffc020366e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203672:	f165                	bnez	a0,ffffffffc0203652 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0203674:	00002697          	auipc	a3,0x2
ffffffffc0203678:	1fc68693          	addi	a3,a3,508 # ffffffffc0205870 <default_pmm_manager+0x798>
ffffffffc020367c:	00001617          	auipc	a2,0x1
ffffffffc0203680:	6c460613          	addi	a2,a2,1732 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203684:	0ce00593          	li	a1,206
ffffffffc0203688:	00002517          	auipc	a0,0x2
ffffffffc020368c:	57850513          	addi	a0,a0,1400 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203690:	ce5fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203694:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203698:	1f900993          	li	s3,505
ffffffffc020369c:	a819                	j	ffffffffc02036b2 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc020369e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02036a0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02036a2:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02036a6:	0495                	addi	s1,s1,5
ffffffffc02036a8:	8522                	mv	a0,s0
ffffffffc02036aa:	e77ff0ef          	jal	ra,ffffffffc0203520 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036ae:	03348a63          	beq	s1,s3,ffffffffc02036e2 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036b2:	03000513          	li	a0,48
ffffffffc02036b6:	844ff0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc02036ba:	85aa                	mv	a1,a0
ffffffffc02036bc:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036c0:	fd79                	bnez	a0,ffffffffc020369e <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036c2:	00002697          	auipc	a3,0x2
ffffffffc02036c6:	1ae68693          	addi	a3,a3,430 # ffffffffc0205870 <default_pmm_manager+0x798>
ffffffffc02036ca:	00001617          	auipc	a2,0x1
ffffffffc02036ce:	67660613          	addi	a2,a2,1654 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02036d2:	0d400593          	li	a1,212
ffffffffc02036d6:	00002517          	auipc	a0,0x2
ffffffffc02036da:	52a50513          	addi	a0,a0,1322 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02036de:	c97fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02036e2:	6418                	ld	a4,8(s0)
ffffffffc02036e4:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036e6:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036ea:	2ae40063          	beq	s0,a4,ffffffffc020398a <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036ee:	fe873603          	ld	a2,-24(a4)
ffffffffc02036f2:	ffe78693          	addi	a3,a5,-2
ffffffffc02036f6:	20d61a63          	bne	a2,a3,ffffffffc020390a <vmm_init+0x2e6>
ffffffffc02036fa:	ff073683          	ld	a3,-16(a4)
ffffffffc02036fe:	20d79663          	bne	a5,a3,ffffffffc020390a <vmm_init+0x2e6>
ffffffffc0203702:	0795                	addi	a5,a5,5
ffffffffc0203704:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203706:	feb792e3          	bne	a5,a1,ffffffffc02036ea <vmm_init+0xc6>
ffffffffc020370a:	499d                	li	s3,7
ffffffffc020370c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020370e:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203712:	85a6                	mv	a1,s1
ffffffffc0203714:	8522                	mv	a0,s0
ffffffffc0203716:	dcdff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
ffffffffc020371a:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc020371c:	2e050763          	beqz	a0,ffffffffc0203a0a <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203720:	00148593          	addi	a1,s1,1
ffffffffc0203724:	8522                	mv	a0,s0
ffffffffc0203726:	dbdff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
ffffffffc020372a:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020372c:	2a050f63          	beqz	a0,ffffffffc02039ea <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203730:	85ce                	mv	a1,s3
ffffffffc0203732:	8522                	mv	a0,s0
ffffffffc0203734:	dafff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203738:	28051963          	bnez	a0,ffffffffc02039ca <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020373c:	00348593          	addi	a1,s1,3
ffffffffc0203740:	8522                	mv	a0,s0
ffffffffc0203742:	da1ff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203746:	26051263          	bnez	a0,ffffffffc02039aa <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020374a:	00448593          	addi	a1,s1,4
ffffffffc020374e:	8522                	mv	a0,s0
ffffffffc0203750:	d93ff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203754:	2c051b63          	bnez	a0,ffffffffc0203a2a <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203758:	008b3783          	ld	a5,8(s6)
ffffffffc020375c:	1c979763          	bne	a5,s1,ffffffffc020392a <vmm_init+0x306>
ffffffffc0203760:	010b3783          	ld	a5,16(s6)
ffffffffc0203764:	1d379363          	bne	a5,s3,ffffffffc020392a <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203768:	008ab783          	ld	a5,8(s5)
ffffffffc020376c:	1c979f63          	bne	a5,s1,ffffffffc020394a <vmm_init+0x326>
ffffffffc0203770:	010ab783          	ld	a5,16(s5)
ffffffffc0203774:	1d379b63          	bne	a5,s3,ffffffffc020394a <vmm_init+0x326>
ffffffffc0203778:	0495                	addi	s1,s1,5
ffffffffc020377a:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020377c:	f9749be3          	bne	s1,s7,ffffffffc0203712 <vmm_init+0xee>
ffffffffc0203780:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203782:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203784:	85a6                	mv	a1,s1
ffffffffc0203786:	8522                	mv	a0,s0
ffffffffc0203788:	d5bff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
ffffffffc020378c:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203790:	c90d                	beqz	a0,ffffffffc02037c2 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203792:	6914                	ld	a3,16(a0)
ffffffffc0203794:	6510                	ld	a2,8(a0)
ffffffffc0203796:	00002517          	auipc	a0,0x2
ffffffffc020379a:	65a50513          	addi	a0,a0,1626 # ffffffffc0205df0 <default_pmm_manager+0xd18>
ffffffffc020379e:	921fc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02037a2:	00002697          	auipc	a3,0x2
ffffffffc02037a6:	67668693          	addi	a3,a3,1654 # ffffffffc0205e18 <default_pmm_manager+0xd40>
ffffffffc02037aa:	00001617          	auipc	a2,0x1
ffffffffc02037ae:	59660613          	addi	a2,a2,1430 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02037b2:	0f600593          	li	a1,246
ffffffffc02037b6:	00002517          	auipc	a0,0x2
ffffffffc02037ba:	44a50513          	addi	a0,a0,1098 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02037be:	bb7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02037c2:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037c4:	fd3490e3          	bne	s1,s3,ffffffffc0203784 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037c8:	8522                	mv	a0,s0
ffffffffc02037ca:	e25ff0ef          	jal	ra,ffffffffc02035ee <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037ce:	fcffd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02037d2:	28aa1c63          	bne	s4,a0,ffffffffc0203a6a <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037d6:	00002517          	auipc	a0,0x2
ffffffffc02037da:	68250513          	addi	a0,a0,1666 # ffffffffc0205e58 <default_pmm_manager+0xd80>
ffffffffc02037de:	8e1fc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037e2:	fbbfd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02037e6:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037e8:	c81ff0ef          	jal	ra,ffffffffc0203468 <mm_create>
ffffffffc02037ec:	0000e797          	auipc	a5,0xe
ffffffffc02037f0:	daa7b623          	sd	a0,-596(a5) # ffffffffc0211598 <check_mm_struct>
ffffffffc02037f4:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037f6:	2a050a63          	beqz	a0,ffffffffc0203aaa <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037fa:	0000e797          	auipc	a5,0xe
ffffffffc02037fe:	c5e78793          	addi	a5,a5,-930 # ffffffffc0211458 <boot_pgdir>
ffffffffc0203802:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203804:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203806:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203808:	32079d63          	bnez	a5,ffffffffc0203b42 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020380c:	03000513          	li	a0,48
ffffffffc0203810:	eebfe0ef          	jal	ra,ffffffffc02026fa <kmalloc>
ffffffffc0203814:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203816:	14050a63          	beqz	a0,ffffffffc020396a <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc020381a:	002007b7          	lui	a5,0x200
ffffffffc020381e:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203822:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203824:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203826:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020382a:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020382c:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203830:	cf1ff0ef          	jal	ra,ffffffffc0203520 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203834:	10000593          	li	a1,256
ffffffffc0203838:	8522                	mv	a0,s0
ffffffffc020383a:	ca9ff0ef          	jal	ra,ffffffffc02034e2 <find_vma>
ffffffffc020383e:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203842:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203846:	2aaa1263          	bne	s4,a0,ffffffffc0203aea <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc020384a:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc020384e:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203850:	fee79de3          	bne	a5,a4,ffffffffc020384a <vmm_init+0x226>
        sum += i;
ffffffffc0203854:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203856:	10000793          	li	a5,256
        sum += i;
ffffffffc020385a:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020385e:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203862:	0007c683          	lbu	a3,0(a5)
ffffffffc0203866:	0785                	addi	a5,a5,1
ffffffffc0203868:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020386a:	fec79ce3          	bne	a5,a2,ffffffffc0203862 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc020386e:	2a071a63          	bnez	a4,ffffffffc0203b22 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203872:	4581                	li	a1,0
ffffffffc0203874:	8526                	mv	a0,s1
ffffffffc0203876:	9ccfe0ef          	jal	ra,ffffffffc0201a42 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020387a:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020387c:	0000e717          	auipc	a4,0xe
ffffffffc0203880:	be470713          	addi	a4,a4,-1052 # ffffffffc0211460 <npage>
ffffffffc0203884:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203886:	078a                	slli	a5,a5,0x2
ffffffffc0203888:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020388a:	28e7f063          	bleu	a4,a5,ffffffffc0203b0a <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc020388e:	00003717          	auipc	a4,0x3
ffffffffc0203892:	90a70713          	addi	a4,a4,-1782 # ffffffffc0206198 <nbase>
ffffffffc0203896:	6318                	ld	a4,0(a4)
ffffffffc0203898:	0000e697          	auipc	a3,0xe
ffffffffc020389c:	c1868693          	addi	a3,a3,-1000 # ffffffffc02114b0 <pages>
ffffffffc02038a0:	6288                	ld	a0,0(a3)
ffffffffc02038a2:	8f99                	sub	a5,a5,a4
ffffffffc02038a4:	00379713          	slli	a4,a5,0x3
ffffffffc02038a8:	97ba                	add	a5,a5,a4
ffffffffc02038aa:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02038ac:	953e                	add	a0,a0,a5
ffffffffc02038ae:	4585                	li	a1,1
ffffffffc02038b0:	ea7fd0ef          	jal	ra,ffffffffc0201756 <free_pages>

    pgdir[0] = 0;
ffffffffc02038b4:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02038b8:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02038ba:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038be:	d31ff0ef          	jal	ra,ffffffffc02035ee <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038c2:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038c4:	0000e797          	auipc	a5,0xe
ffffffffc02038c8:	cc07ba23          	sd	zero,-812(a5) # ffffffffc0211598 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038cc:	ed1fd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
ffffffffc02038d0:	1aa99d63          	bne	s3,a0,ffffffffc0203a8a <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038d4:	00002517          	auipc	a0,0x2
ffffffffc02038d8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205ec0 <default_pmm_manager+0xde8>
ffffffffc02038dc:	fe2fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038e0:	ebdfd0ef          	jal	ra,ffffffffc020179c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038e4:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038e6:	1ea91263          	bne	s2,a0,ffffffffc0203aca <vmm_init+0x4a6>
}
ffffffffc02038ea:	6406                	ld	s0,64(sp)
ffffffffc02038ec:	60a6                	ld	ra,72(sp)
ffffffffc02038ee:	74e2                	ld	s1,56(sp)
ffffffffc02038f0:	7942                	ld	s2,48(sp)
ffffffffc02038f2:	79a2                	ld	s3,40(sp)
ffffffffc02038f4:	7a02                	ld	s4,32(sp)
ffffffffc02038f6:	6ae2                	ld	s5,24(sp)
ffffffffc02038f8:	6b42                	ld	s6,16(sp)
ffffffffc02038fa:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038fc:	00002517          	auipc	a0,0x2
ffffffffc0203900:	5e450513          	addi	a0,a0,1508 # ffffffffc0205ee0 <default_pmm_manager+0xe08>
}
ffffffffc0203904:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203906:	fb8fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020390a:	00002697          	auipc	a3,0x2
ffffffffc020390e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0205d08 <default_pmm_manager+0xc30>
ffffffffc0203912:	00001617          	auipc	a2,0x1
ffffffffc0203916:	42e60613          	addi	a2,a2,1070 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020391a:	0dd00593          	li	a1,221
ffffffffc020391e:	00002517          	auipc	a0,0x2
ffffffffc0203922:	2e250513          	addi	a0,a0,738 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203926:	a4ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020392a:	00002697          	auipc	a3,0x2
ffffffffc020392e:	46668693          	addi	a3,a3,1126 # ffffffffc0205d90 <default_pmm_manager+0xcb8>
ffffffffc0203932:	00001617          	auipc	a2,0x1
ffffffffc0203936:	40e60613          	addi	a2,a2,1038 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020393a:	0ed00593          	li	a1,237
ffffffffc020393e:	00002517          	auipc	a0,0x2
ffffffffc0203942:	2c250513          	addi	a0,a0,706 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203946:	a2ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020394a:	00002697          	auipc	a3,0x2
ffffffffc020394e:	47668693          	addi	a3,a3,1142 # ffffffffc0205dc0 <default_pmm_manager+0xce8>
ffffffffc0203952:	00001617          	auipc	a2,0x1
ffffffffc0203956:	3ee60613          	addi	a2,a2,1006 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020395a:	0ee00593          	li	a1,238
ffffffffc020395e:	00002517          	auipc	a0,0x2
ffffffffc0203962:	2a250513          	addi	a0,a0,674 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203966:	a0ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc020396a:	00002697          	auipc	a3,0x2
ffffffffc020396e:	f0668693          	addi	a3,a3,-250 # ffffffffc0205870 <default_pmm_manager+0x798>
ffffffffc0203972:	00001617          	auipc	a2,0x1
ffffffffc0203976:	3ce60613          	addi	a2,a2,974 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020397a:	11100593          	li	a1,273
ffffffffc020397e:	00002517          	auipc	a0,0x2
ffffffffc0203982:	28250513          	addi	a0,a0,642 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203986:	9effc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020398a:	00002697          	auipc	a3,0x2
ffffffffc020398e:	36668693          	addi	a3,a3,870 # ffffffffc0205cf0 <default_pmm_manager+0xc18>
ffffffffc0203992:	00001617          	auipc	a2,0x1
ffffffffc0203996:	3ae60613          	addi	a2,a2,942 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc020399a:	0db00593          	li	a1,219
ffffffffc020399e:	00002517          	auipc	a0,0x2
ffffffffc02039a2:	26250513          	addi	a0,a0,610 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02039a6:	9cffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc02039aa:	00002697          	auipc	a3,0x2
ffffffffc02039ae:	3c668693          	addi	a3,a3,966 # ffffffffc0205d70 <default_pmm_manager+0xc98>
ffffffffc02039b2:	00001617          	auipc	a2,0x1
ffffffffc02039b6:	38e60613          	addi	a2,a2,910 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02039ba:	0e900593          	li	a1,233
ffffffffc02039be:	00002517          	auipc	a0,0x2
ffffffffc02039c2:	24250513          	addi	a0,a0,578 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02039c6:	9affc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc02039ca:	00002697          	auipc	a3,0x2
ffffffffc02039ce:	39668693          	addi	a3,a3,918 # ffffffffc0205d60 <default_pmm_manager+0xc88>
ffffffffc02039d2:	00001617          	auipc	a2,0x1
ffffffffc02039d6:	36e60613          	addi	a2,a2,878 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02039da:	0e700593          	li	a1,231
ffffffffc02039de:	00002517          	auipc	a0,0x2
ffffffffc02039e2:	22250513          	addi	a0,a0,546 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc02039e6:	98ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc02039ea:	00002697          	auipc	a3,0x2
ffffffffc02039ee:	36668693          	addi	a3,a3,870 # ffffffffc0205d50 <default_pmm_manager+0xc78>
ffffffffc02039f2:	00001617          	auipc	a2,0x1
ffffffffc02039f6:	34e60613          	addi	a2,a2,846 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc02039fa:	0e500593          	li	a1,229
ffffffffc02039fe:	00002517          	auipc	a0,0x2
ffffffffc0203a02:	20250513          	addi	a0,a0,514 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203a06:	96ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc0203a0a:	00002697          	auipc	a3,0x2
ffffffffc0203a0e:	33668693          	addi	a3,a3,822 # ffffffffc0205d40 <default_pmm_manager+0xc68>
ffffffffc0203a12:	00001617          	auipc	a2,0x1
ffffffffc0203a16:	32e60613          	addi	a2,a2,814 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203a1a:	0e300593          	li	a1,227
ffffffffc0203a1e:	00002517          	auipc	a0,0x2
ffffffffc0203a22:	1e250513          	addi	a0,a0,482 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203a26:	94ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203a2a:	00002697          	auipc	a3,0x2
ffffffffc0203a2e:	35668693          	addi	a3,a3,854 # ffffffffc0205d80 <default_pmm_manager+0xca8>
ffffffffc0203a32:	00001617          	auipc	a2,0x1
ffffffffc0203a36:	30e60613          	addi	a2,a2,782 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203a3a:	0eb00593          	li	a1,235
ffffffffc0203a3e:	00002517          	auipc	a0,0x2
ffffffffc0203a42:	1c250513          	addi	a0,a0,450 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203a46:	92ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203a4a:	00002697          	auipc	a3,0x2
ffffffffc0203a4e:	dee68693          	addi	a3,a3,-530 # ffffffffc0205838 <default_pmm_manager+0x760>
ffffffffc0203a52:	00001617          	auipc	a2,0x1
ffffffffc0203a56:	2ee60613          	addi	a2,a2,750 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203a5a:	0c700593          	li	a1,199
ffffffffc0203a5e:	00002517          	auipc	a0,0x2
ffffffffc0203a62:	1a250513          	addi	a0,a0,418 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203a66:	90ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a6a:	00002697          	auipc	a3,0x2
ffffffffc0203a6e:	3c668693          	addi	a3,a3,966 # ffffffffc0205e30 <default_pmm_manager+0xd58>
ffffffffc0203a72:	00001617          	auipc	a2,0x1
ffffffffc0203a76:	2ce60613          	addi	a2,a2,718 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203a7a:	0fb00593          	li	a1,251
ffffffffc0203a7e:	00002517          	auipc	a0,0x2
ffffffffc0203a82:	18250513          	addi	a0,a0,386 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203a86:	8effc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a8a:	00002697          	auipc	a3,0x2
ffffffffc0203a8e:	3a668693          	addi	a3,a3,934 # ffffffffc0205e30 <default_pmm_manager+0xd58>
ffffffffc0203a92:	00001617          	auipc	a2,0x1
ffffffffc0203a96:	2ae60613          	addi	a2,a2,686 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203a9a:	12e00593          	li	a1,302
ffffffffc0203a9e:	00002517          	auipc	a0,0x2
ffffffffc0203aa2:	16250513          	addi	a0,a0,354 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203aa6:	8cffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203aaa:	00002697          	auipc	a3,0x2
ffffffffc0203aae:	3ce68693          	addi	a3,a3,974 # ffffffffc0205e78 <default_pmm_manager+0xda0>
ffffffffc0203ab2:	00001617          	auipc	a2,0x1
ffffffffc0203ab6:	28e60613          	addi	a2,a2,654 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203aba:	10a00593          	li	a1,266
ffffffffc0203abe:	00002517          	auipc	a0,0x2
ffffffffc0203ac2:	14250513          	addi	a0,a0,322 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203ac6:	8affc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203aca:	00002697          	auipc	a3,0x2
ffffffffc0203ace:	36668693          	addi	a3,a3,870 # ffffffffc0205e30 <default_pmm_manager+0xd58>
ffffffffc0203ad2:	00001617          	auipc	a2,0x1
ffffffffc0203ad6:	26e60613          	addi	a2,a2,622 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203ada:	0bd00593          	li	a1,189
ffffffffc0203ade:	00002517          	auipc	a0,0x2
ffffffffc0203ae2:	12250513          	addi	a0,a0,290 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203ae6:	88ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203aea:	00002697          	auipc	a3,0x2
ffffffffc0203aee:	3a668693          	addi	a3,a3,934 # ffffffffc0205e90 <default_pmm_manager+0xdb8>
ffffffffc0203af2:	00001617          	auipc	a2,0x1
ffffffffc0203af6:	24e60613          	addi	a2,a2,590 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203afa:	11600593          	li	a1,278
ffffffffc0203afe:	00002517          	auipc	a0,0x2
ffffffffc0203b02:	10250513          	addi	a0,a0,258 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203b06:	86ffc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203b0a:	00001617          	auipc	a2,0x1
ffffffffc0203b0e:	69660613          	addi	a2,a2,1686 # ffffffffc02051a0 <default_pmm_manager+0xc8>
ffffffffc0203b12:	06500593          	li	a1,101
ffffffffc0203b16:	00001517          	auipc	a0,0x1
ffffffffc0203b1a:	6aa50513          	addi	a0,a0,1706 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0203b1e:	857fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203b22:	00002697          	auipc	a3,0x2
ffffffffc0203b26:	38e68693          	addi	a3,a3,910 # ffffffffc0205eb0 <default_pmm_manager+0xdd8>
ffffffffc0203b2a:	00001617          	auipc	a2,0x1
ffffffffc0203b2e:	21660613          	addi	a2,a2,534 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203b32:	12000593          	li	a1,288
ffffffffc0203b36:	00002517          	auipc	a0,0x2
ffffffffc0203b3a:	0ca50513          	addi	a0,a0,202 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203b3e:	837fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b42:	00002697          	auipc	a3,0x2
ffffffffc0203b46:	d1e68693          	addi	a3,a3,-738 # ffffffffc0205860 <default_pmm_manager+0x788>
ffffffffc0203b4a:	00001617          	auipc	a2,0x1
ffffffffc0203b4e:	1f660613          	addi	a2,a2,502 # ffffffffc0204d40 <commands+0x8e0>
ffffffffc0203b52:	10d00593          	li	a1,269
ffffffffc0203b56:	00002517          	auipc	a0,0x2
ffffffffc0203b5a:	0aa50513          	addi	a0,a0,170 # ffffffffc0205c00 <default_pmm_manager+0xb28>
ffffffffc0203b5e:	817fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b62 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b62:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b64:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b66:	f022                	sd	s0,32(sp)
ffffffffc0203b68:	ec26                	sd	s1,24(sp)
ffffffffc0203b6a:	f406                	sd	ra,40(sp)
ffffffffc0203b6c:	e84a                	sd	s2,16(sp)
ffffffffc0203b6e:	8432                	mv	s0,a2
ffffffffc0203b70:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b72:	971ff0ef          	jal	ra,ffffffffc02034e2 <find_vma>

    pgfault_num++;
ffffffffc0203b76:	0000e797          	auipc	a5,0xe
ffffffffc0203b7a:	8fe78793          	addi	a5,a5,-1794 # ffffffffc0211474 <pgfault_num>
ffffffffc0203b7e:	439c                	lw	a5,0(a5)
ffffffffc0203b80:	2785                	addiw	a5,a5,1
ffffffffc0203b82:	0000e717          	auipc	a4,0xe
ffffffffc0203b86:	8ef72923          	sw	a5,-1806(a4) # ffffffffc0211474 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b8a:	c549                	beqz	a0,ffffffffc0203c14 <do_pgfault+0xb2>
ffffffffc0203b8c:	651c                	ld	a5,8(a0)
ffffffffc0203b8e:	08f46363          	bltu	s0,a5,ffffffffc0203c14 <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b92:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b94:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b96:	8b89                	andi	a5,a5,2
ffffffffc0203b98:	efa9                	bnez	a5,ffffffffc0203bf2 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b9a:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b9c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b9e:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203ba0:	85a2                	mv	a1,s0
ffffffffc0203ba2:	4605                	li	a2,1
ffffffffc0203ba4:	c39fd0ef          	jal	ra,ffffffffc02017dc <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203ba8:	610c                	ld	a1,0(a0)
ffffffffc0203baa:	c5b1                	beqz	a1,ffffffffc0203bf6 <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203bac:	0000e797          	auipc	a5,0xe
ffffffffc0203bb0:	8c478793          	addi	a5,a5,-1852 # ffffffffc0211470 <swap_init_ok>
ffffffffc0203bb4:	439c                	lw	a5,0(a5)
ffffffffc0203bb6:	2781                	sext.w	a5,a5
ffffffffc0203bb8:	c7bd                	beqz	a5,ffffffffc0203c26 <do_pgfault+0xc4>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);//分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203bba:	85a2                	mv	a1,s0
ffffffffc0203bbc:	0030                	addi	a2,sp,8
ffffffffc0203bbe:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203bc0:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);//分配一个内存页并从磁盘上的交换文件加载数据到该内存页
ffffffffc0203bc2:	c8eff0ef          	jal	ra,ffffffffc0203050 <swap_in>
            page_insert(mm->pgdir,page,addr,perm);//建立内存页 page 的物理地址和线性地址 addr 之间的映射
ffffffffc0203bc6:	65a2                	ld	a1,8(sp)
ffffffffc0203bc8:	6c88                	ld	a0,24(s1)
ffffffffc0203bca:	86ca                	mv	a3,s2
ffffffffc0203bcc:	8622                	mv	a2,s0
ffffffffc0203bce:	ee7fd0ef          	jal	ra,ffffffffc0201ab4 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将页面标记为可交换
ffffffffc0203bd2:	6622                	ld	a2,8(sp)
ffffffffc0203bd4:	4685                	li	a3,1
ffffffffc0203bd6:	85a2                	mv	a1,s0
ffffffffc0203bd8:	8526                	mv	a0,s1
ffffffffc0203bda:	b52ff0ef          	jal	ra,ffffffffc0202f2c <swap_map_swappable>
            page->pra_vaddr = addr;//跟踪页面映射的线性地址
ffffffffc0203bde:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203be0:	4781                	li	a5,0
            page->pra_vaddr = addr;//跟踪页面映射的线性地址
ffffffffc0203be2:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203be4:	70a2                	ld	ra,40(sp)
ffffffffc0203be6:	7402                	ld	s0,32(sp)
ffffffffc0203be8:	64e2                	ld	s1,24(sp)
ffffffffc0203bea:	6942                	ld	s2,16(sp)
ffffffffc0203bec:	853e                	mv	a0,a5
ffffffffc0203bee:	6145                	addi	sp,sp,48
ffffffffc0203bf0:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203bf2:	4959                	li	s2,22
ffffffffc0203bf4:	b75d                	j	ffffffffc0203b9a <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bf6:	6c88                	ld	a0,24(s1)
ffffffffc0203bf8:	864a                	mv	a2,s2
ffffffffc0203bfa:	85a2                	mv	a1,s0
ffffffffc0203bfc:	a6dfe0ef          	jal	ra,ffffffffc0202668 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203c00:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203c02:	f16d                	bnez	a0,ffffffffc0203be4 <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203c04:	00002517          	auipc	a0,0x2
ffffffffc0203c08:	03c50513          	addi	a0,a0,60 # ffffffffc0205c40 <default_pmm_manager+0xb68>
ffffffffc0203c0c:	cb2fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c10:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c12:	bfc9                	j	ffffffffc0203be4 <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203c14:	85a2                	mv	a1,s0
ffffffffc0203c16:	00002517          	auipc	a0,0x2
ffffffffc0203c1a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0205c10 <default_pmm_manager+0xb38>
ffffffffc0203c1e:	ca0fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c22:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203c24:	b7c1                	j	ffffffffc0203be4 <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c26:	00002517          	auipc	a0,0x2
ffffffffc0203c2a:	04250513          	addi	a0,a0,66 # ffffffffc0205c68 <default_pmm_manager+0xb90>
ffffffffc0203c2e:	c90fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c32:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c34:	bf45                	j	ffffffffc0203be4 <do_pgfault+0x82>

ffffffffc0203c36 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c36:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c38:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c3a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c3c:	863fc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203c40:	cd01                	beqz	a0,ffffffffc0203c58 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c42:	4505                	li	a0,1
ffffffffc0203c44:	861fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203c48:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c4a:	810d                	srli	a0,a0,0x3
ffffffffc0203c4c:	0000e797          	auipc	a5,0xe
ffffffffc0203c50:	8ea7ba23          	sd	a0,-1804(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203c54:	0141                	addi	sp,sp,16
ffffffffc0203c56:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c58:	00002617          	auipc	a2,0x2
ffffffffc0203c5c:	2a060613          	addi	a2,a2,672 # ffffffffc0205ef8 <default_pmm_manager+0xe20>
ffffffffc0203c60:	45b5                	li	a1,13
ffffffffc0203c62:	00002517          	auipc	a0,0x2
ffffffffc0203c66:	2b650513          	addi	a0,a0,694 # ffffffffc0205f18 <default_pmm_manager+0xe40>
ffffffffc0203c6a:	f0afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c6e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c6e:	1141                	addi	sp,sp,-16
ffffffffc0203c70:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c72:	00855793          	srli	a5,a0,0x8
ffffffffc0203c76:	c7b5                	beqz	a5,ffffffffc0203ce2 <swapfs_read+0x74>
ffffffffc0203c78:	0000e717          	auipc	a4,0xe
ffffffffc0203c7c:	8c870713          	addi	a4,a4,-1848 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203c80:	6318                	ld	a4,0(a4)
ffffffffc0203c82:	06e7f063          	bleu	a4,a5,ffffffffc0203ce2 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c86:	0000e717          	auipc	a4,0xe
ffffffffc0203c8a:	82a70713          	addi	a4,a4,-2006 # ffffffffc02114b0 <pages>
ffffffffc0203c8e:	6310                	ld	a2,0(a4)
ffffffffc0203c90:	00001717          	auipc	a4,0x1
ffffffffc0203c94:	09870713          	addi	a4,a4,152 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0203c98:	00002697          	auipc	a3,0x2
ffffffffc0203c9c:	50068693          	addi	a3,a3,1280 # ffffffffc0206198 <nbase>
ffffffffc0203ca0:	40c58633          	sub	a2,a1,a2
ffffffffc0203ca4:	630c                	ld	a1,0(a4)
ffffffffc0203ca6:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca8:	0000d717          	auipc	a4,0xd
ffffffffc0203cac:	7b870713          	addi	a4,a4,1976 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cb0:	02b60633          	mul	a2,a2,a1
ffffffffc0203cb4:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cb8:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cba:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cbc:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cbe:	57fd                	li	a5,-1
ffffffffc0203cc0:	83b1                	srli	a5,a5,0xc
ffffffffc0203cc2:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cc4:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cc6:	02e7fa63          	bleu	a4,a5,ffffffffc0203cfa <swapfs_read+0x8c>
ffffffffc0203cca:	0000d797          	auipc	a5,0xd
ffffffffc0203cce:	7d678793          	addi	a5,a5,2006 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203cd2:	639c                	ld	a5,0(a5)
}
ffffffffc0203cd4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd6:	46a1                	li	a3,8
ffffffffc0203cd8:	963e                	add	a2,a2,a5
ffffffffc0203cda:	4505                	li	a0,1
}
ffffffffc0203cdc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cde:	fccfc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203ce2:	86aa                	mv	a3,a0
ffffffffc0203ce4:	00002617          	auipc	a2,0x2
ffffffffc0203ce8:	24c60613          	addi	a2,a2,588 # ffffffffc0205f30 <default_pmm_manager+0xe58>
ffffffffc0203cec:	45d1                	li	a1,20
ffffffffc0203cee:	00002517          	auipc	a0,0x2
ffffffffc0203cf2:	22a50513          	addi	a0,a0,554 # ffffffffc0205f18 <default_pmm_manager+0xe40>
ffffffffc0203cf6:	e7efc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203cfa:	86b2                	mv	a3,a2
ffffffffc0203cfc:	06a00593          	li	a1,106
ffffffffc0203d00:	00001617          	auipc	a2,0x1
ffffffffc0203d04:	42860613          	addi	a2,a2,1064 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc0203d08:	00001517          	auipc	a0,0x1
ffffffffc0203d0c:	4b850513          	addi	a0,a0,1208 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0203d10:	e64fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d14 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d14:	1141                	addi	sp,sp,-16
ffffffffc0203d16:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d18:	00855793          	srli	a5,a0,0x8
ffffffffc0203d1c:	c7b5                	beqz	a5,ffffffffc0203d88 <swapfs_write+0x74>
ffffffffc0203d1e:	0000e717          	auipc	a4,0xe
ffffffffc0203d22:	82270713          	addi	a4,a4,-2014 # ffffffffc0211540 <max_swap_offset>
ffffffffc0203d26:	6318                	ld	a4,0(a4)
ffffffffc0203d28:	06e7f063          	bleu	a4,a5,ffffffffc0203d88 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d2c:	0000d717          	auipc	a4,0xd
ffffffffc0203d30:	78470713          	addi	a4,a4,1924 # ffffffffc02114b0 <pages>
ffffffffc0203d34:	6310                	ld	a2,0(a4)
ffffffffc0203d36:	00001717          	auipc	a4,0x1
ffffffffc0203d3a:	ff270713          	addi	a4,a4,-14 # ffffffffc0204d28 <commands+0x8c8>
ffffffffc0203d3e:	00002697          	auipc	a3,0x2
ffffffffc0203d42:	45a68693          	addi	a3,a3,1114 # ffffffffc0206198 <nbase>
ffffffffc0203d46:	40c58633          	sub	a2,a1,a2
ffffffffc0203d4a:	630c                	ld	a1,0(a4)
ffffffffc0203d4c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d4e:	0000d717          	auipc	a4,0xd
ffffffffc0203d52:	71270713          	addi	a4,a4,1810 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d56:	02b60633          	mul	a2,a2,a1
ffffffffc0203d5a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d5e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d60:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d62:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d64:	57fd                	li	a5,-1
ffffffffc0203d66:	83b1                	srli	a5,a5,0xc
ffffffffc0203d68:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d6a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d6c:	02e7fa63          	bleu	a4,a5,ffffffffc0203da0 <swapfs_write+0x8c>
ffffffffc0203d70:	0000d797          	auipc	a5,0xd
ffffffffc0203d74:	73078793          	addi	a5,a5,1840 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203d78:	639c                	ld	a5,0(a5)
}
ffffffffc0203d7a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d7c:	46a1                	li	a3,8
ffffffffc0203d7e:	963e                	add	a2,a2,a5
ffffffffc0203d80:	4505                	li	a0,1
}
ffffffffc0203d82:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d84:	f4afc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203d88:	86aa                	mv	a3,a0
ffffffffc0203d8a:	00002617          	auipc	a2,0x2
ffffffffc0203d8e:	1a660613          	addi	a2,a2,422 # ffffffffc0205f30 <default_pmm_manager+0xe58>
ffffffffc0203d92:	45e5                	li	a1,25
ffffffffc0203d94:	00002517          	auipc	a0,0x2
ffffffffc0203d98:	18450513          	addi	a0,a0,388 # ffffffffc0205f18 <default_pmm_manager+0xe40>
ffffffffc0203d9c:	dd8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203da0:	86b2                	mv	a3,a2
ffffffffc0203da2:	06a00593          	li	a1,106
ffffffffc0203da6:	00001617          	auipc	a2,0x1
ffffffffc0203daa:	38260613          	addi	a2,a2,898 # ffffffffc0205128 <default_pmm_manager+0x50>
ffffffffc0203dae:	00001517          	auipc	a0,0x1
ffffffffc0203db2:	41250513          	addi	a0,a0,1042 # ffffffffc02051c0 <default_pmm_manager+0xe8>
ffffffffc0203db6:	dbefc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203dba <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203dba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dbe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203dc0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dc4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203dc6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dca:	f022                	sd	s0,32(sp)
ffffffffc0203dcc:	ec26                	sd	s1,24(sp)
ffffffffc0203dce:	e84a                	sd	s2,16(sp)
ffffffffc0203dd0:	f406                	sd	ra,40(sp)
ffffffffc0203dd2:	e44e                	sd	s3,8(sp)
ffffffffc0203dd4:	84aa                	mv	s1,a0
ffffffffc0203dd6:	892e                	mv	s2,a1
ffffffffc0203dd8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203ddc:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203dde:	03067e63          	bleu	a6,a2,ffffffffc0203e1a <printnum+0x60>
ffffffffc0203de2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203de4:	00805763          	blez	s0,ffffffffc0203df2 <printnum+0x38>
ffffffffc0203de8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203dea:	85ca                	mv	a1,s2
ffffffffc0203dec:	854e                	mv	a0,s3
ffffffffc0203dee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203df0:	fc65                	bnez	s0,ffffffffc0203de8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203df2:	1a02                	slli	s4,s4,0x20
ffffffffc0203df4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203df8:	00002797          	auipc	a5,0x2
ffffffffc0203dfc:	2e878793          	addi	a5,a5,744 # ffffffffc02060e0 <error_string+0x38>
ffffffffc0203e00:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e02:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e04:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e08:	70a2                	ld	ra,40(sp)
ffffffffc0203e0a:	69a2                	ld	s3,8(sp)
ffffffffc0203e0c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e0e:	85ca                	mv	a1,s2
ffffffffc0203e10:	8326                	mv	t1,s1
}
ffffffffc0203e12:	6942                	ld	s2,16(sp)
ffffffffc0203e14:	64e2                	ld	s1,24(sp)
ffffffffc0203e16:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e18:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e1a:	03065633          	divu	a2,a2,a6
ffffffffc0203e1e:	8722                	mv	a4,s0
ffffffffc0203e20:	f9bff0ef          	jal	ra,ffffffffc0203dba <printnum>
ffffffffc0203e24:	b7f9                	j	ffffffffc0203df2 <printnum+0x38>

ffffffffc0203e26 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e26:	7119                	addi	sp,sp,-128
ffffffffc0203e28:	f4a6                	sd	s1,104(sp)
ffffffffc0203e2a:	f0ca                	sd	s2,96(sp)
ffffffffc0203e2c:	e8d2                	sd	s4,80(sp)
ffffffffc0203e2e:	e4d6                	sd	s5,72(sp)
ffffffffc0203e30:	e0da                	sd	s6,64(sp)
ffffffffc0203e32:	fc5e                	sd	s7,56(sp)
ffffffffc0203e34:	f862                	sd	s8,48(sp)
ffffffffc0203e36:	f06a                	sd	s10,32(sp)
ffffffffc0203e38:	fc86                	sd	ra,120(sp)
ffffffffc0203e3a:	f8a2                	sd	s0,112(sp)
ffffffffc0203e3c:	ecce                	sd	s3,88(sp)
ffffffffc0203e3e:	f466                	sd	s9,40(sp)
ffffffffc0203e40:	ec6e                	sd	s11,24(sp)
ffffffffc0203e42:	892a                	mv	s2,a0
ffffffffc0203e44:	84ae                	mv	s1,a1
ffffffffc0203e46:	8d32                	mv	s10,a2
ffffffffc0203e48:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e4a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e4c:	00002a17          	auipc	s4,0x2
ffffffffc0203e50:	104a0a13          	addi	s4,s4,260 # ffffffffc0205f50 <default_pmm_manager+0xe78>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e54:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e58:	00002c17          	auipc	s8,0x2
ffffffffc0203e5c:	250c0c13          	addi	s8,s8,592 # ffffffffc02060a8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e60:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e64:	02500793          	li	a5,37
ffffffffc0203e68:	001d0413          	addi	s0,s10,1
ffffffffc0203e6c:	00f50e63          	beq	a0,a5,ffffffffc0203e88 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e70:	c521                	beqz	a0,ffffffffc0203eb8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e72:	02500993          	li	s3,37
ffffffffc0203e76:	a011                	j	ffffffffc0203e7a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e78:	c121                	beqz	a0,ffffffffc0203eb8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e7a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e7c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e7e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e80:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e84:	ff351ae3          	bne	a0,s3,ffffffffc0203e78 <vprintfmt+0x52>
ffffffffc0203e88:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e8c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e90:	4981                	li	s3,0
ffffffffc0203e92:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e94:	5cfd                	li	s9,-1
ffffffffc0203e96:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e98:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e9c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e9e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ea2:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ea6:	00140d13          	addi	s10,s0,1
ffffffffc0203eaa:	20d5e563          	bltu	a1,a3,ffffffffc02040b4 <vprintfmt+0x28e>
ffffffffc0203eae:	068a                	slli	a3,a3,0x2
ffffffffc0203eb0:	96d2                	add	a3,a3,s4
ffffffffc0203eb2:	4294                	lw	a3,0(a3)
ffffffffc0203eb4:	96d2                	add	a3,a3,s4
ffffffffc0203eb6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eb8:	70e6                	ld	ra,120(sp)
ffffffffc0203eba:	7446                	ld	s0,112(sp)
ffffffffc0203ebc:	74a6                	ld	s1,104(sp)
ffffffffc0203ebe:	7906                	ld	s2,96(sp)
ffffffffc0203ec0:	69e6                	ld	s3,88(sp)
ffffffffc0203ec2:	6a46                	ld	s4,80(sp)
ffffffffc0203ec4:	6aa6                	ld	s5,72(sp)
ffffffffc0203ec6:	6b06                	ld	s6,64(sp)
ffffffffc0203ec8:	7be2                	ld	s7,56(sp)
ffffffffc0203eca:	7c42                	ld	s8,48(sp)
ffffffffc0203ecc:	7ca2                	ld	s9,40(sp)
ffffffffc0203ece:	7d02                	ld	s10,32(sp)
ffffffffc0203ed0:	6de2                	ld	s11,24(sp)
ffffffffc0203ed2:	6109                	addi	sp,sp,128
ffffffffc0203ed4:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ed6:	4705                	li	a4,1
ffffffffc0203ed8:	008a8593          	addi	a1,s5,8
ffffffffc0203edc:	01074463          	blt	a4,a6,ffffffffc0203ee4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203ee0:	26080363          	beqz	a6,ffffffffc0204146 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203ee4:	000ab603          	ld	a2,0(s5)
ffffffffc0203ee8:	46c1                	li	a3,16
ffffffffc0203eea:	8aae                	mv	s5,a1
ffffffffc0203eec:	a06d                	j	ffffffffc0203f96 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203eee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203ef2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ef4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ef6:	b765                	j	ffffffffc0203e9e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ef8:	000aa503          	lw	a0,0(s5)
ffffffffc0203efc:	85a6                	mv	a1,s1
ffffffffc0203efe:	0aa1                	addi	s5,s5,8
ffffffffc0203f00:	9902                	jalr	s2
            break;
ffffffffc0203f02:	bfb9                	j	ffffffffc0203e60 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f04:	4705                	li	a4,1
ffffffffc0203f06:	008a8993          	addi	s3,s5,8
ffffffffc0203f0a:	01074463          	blt	a4,a6,ffffffffc0203f12 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f0e:	22080463          	beqz	a6,ffffffffc0204136 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f12:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f16:	24044463          	bltz	s0,ffffffffc020415e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f1a:	8622                	mv	a2,s0
ffffffffc0203f1c:	8ace                	mv	s5,s3
ffffffffc0203f1e:	46a9                	li	a3,10
ffffffffc0203f20:	a89d                	j	ffffffffc0203f96 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f22:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f26:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f28:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f2a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f2e:	8fb5                	xor	a5,a5,a3
ffffffffc0203f30:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f34:	1ad74363          	blt	a4,a3,ffffffffc02040da <vprintfmt+0x2b4>
ffffffffc0203f38:	00369793          	slli	a5,a3,0x3
ffffffffc0203f3c:	97e2                	add	a5,a5,s8
ffffffffc0203f3e:	639c                	ld	a5,0(a5)
ffffffffc0203f40:	18078d63          	beqz	a5,ffffffffc02040da <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f44:	86be                	mv	a3,a5
ffffffffc0203f46:	00002617          	auipc	a2,0x2
ffffffffc0203f4a:	24a60613          	addi	a2,a2,586 # ffffffffc0206190 <error_string+0xe8>
ffffffffc0203f4e:	85a6                	mv	a1,s1
ffffffffc0203f50:	854a                	mv	a0,s2
ffffffffc0203f52:	240000ef          	jal	ra,ffffffffc0204192 <printfmt>
ffffffffc0203f56:	b729                	j	ffffffffc0203e60 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f58:	00144603          	lbu	a2,1(s0)
ffffffffc0203f5c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f5e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f60:	bf3d                	j	ffffffffc0203e9e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f62:	4705                	li	a4,1
ffffffffc0203f64:	008a8593          	addi	a1,s5,8
ffffffffc0203f68:	01074463          	blt	a4,a6,ffffffffc0203f70 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f6c:	1e080263          	beqz	a6,ffffffffc0204150 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f70:	000ab603          	ld	a2,0(s5)
ffffffffc0203f74:	46a1                	li	a3,8
ffffffffc0203f76:	8aae                	mv	s5,a1
ffffffffc0203f78:	a839                	j	ffffffffc0203f96 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f7a:	03000513          	li	a0,48
ffffffffc0203f7e:	85a6                	mv	a1,s1
ffffffffc0203f80:	e03e                	sd	a5,0(sp)
ffffffffc0203f82:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f84:	85a6                	mv	a1,s1
ffffffffc0203f86:	07800513          	li	a0,120
ffffffffc0203f8a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f8c:	0aa1                	addi	s5,s5,8
ffffffffc0203f8e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203f92:	6782                	ld	a5,0(sp)
ffffffffc0203f94:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203f96:	876e                	mv	a4,s11
ffffffffc0203f98:	85a6                	mv	a1,s1
ffffffffc0203f9a:	854a                	mv	a0,s2
ffffffffc0203f9c:	e1fff0ef          	jal	ra,ffffffffc0203dba <printnum>
            break;
ffffffffc0203fa0:	b5c1                	j	ffffffffc0203e60 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fa2:	000ab603          	ld	a2,0(s5)
ffffffffc0203fa6:	0aa1                	addi	s5,s5,8
ffffffffc0203fa8:	1c060663          	beqz	a2,ffffffffc0204174 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203fac:	00160413          	addi	s0,a2,1
ffffffffc0203fb0:	17b05c63          	blez	s11,ffffffffc0204128 <vprintfmt+0x302>
ffffffffc0203fb4:	02d00593          	li	a1,45
ffffffffc0203fb8:	14b79263          	bne	a5,a1,ffffffffc02040fc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fbc:	00064783          	lbu	a5,0(a2)
ffffffffc0203fc0:	0007851b          	sext.w	a0,a5
ffffffffc0203fc4:	c905                	beqz	a0,ffffffffc0203ff4 <vprintfmt+0x1ce>
ffffffffc0203fc6:	000cc563          	bltz	s9,ffffffffc0203fd0 <vprintfmt+0x1aa>
ffffffffc0203fca:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fcc:	036c8263          	beq	s9,s6,ffffffffc0203ff0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203fd0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fd2:	18098463          	beqz	s3,ffffffffc020415a <vprintfmt+0x334>
ffffffffc0203fd6:	3781                	addiw	a5,a5,-32
ffffffffc0203fd8:	18fbf163          	bleu	a5,s7,ffffffffc020415a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203fdc:	03f00513          	li	a0,63
ffffffffc0203fe0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fe2:	0405                	addi	s0,s0,1
ffffffffc0203fe4:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fe8:	3dfd                	addiw	s11,s11,-1
ffffffffc0203fea:	0007851b          	sext.w	a0,a5
ffffffffc0203fee:	fd61                	bnez	a0,ffffffffc0203fc6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203ff0:	e7b058e3          	blez	s11,ffffffffc0203e60 <vprintfmt+0x3a>
ffffffffc0203ff4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203ff6:	85a6                	mv	a1,s1
ffffffffc0203ff8:	02000513          	li	a0,32
ffffffffc0203ffc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ffe:	e60d81e3          	beqz	s11,ffffffffc0203e60 <vprintfmt+0x3a>
ffffffffc0204002:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204004:	85a6                	mv	a1,s1
ffffffffc0204006:	02000513          	li	a0,32
ffffffffc020400a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020400c:	fe0d94e3          	bnez	s11,ffffffffc0203ff4 <vprintfmt+0x1ce>
ffffffffc0204010:	bd81                	j	ffffffffc0203e60 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204012:	4705                	li	a4,1
ffffffffc0204014:	008a8593          	addi	a1,s5,8
ffffffffc0204018:	01074463          	blt	a4,a6,ffffffffc0204020 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020401c:	12080063          	beqz	a6,ffffffffc020413c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204020:	000ab603          	ld	a2,0(s5)
ffffffffc0204024:	46a9                	li	a3,10
ffffffffc0204026:	8aae                	mv	s5,a1
ffffffffc0204028:	b7bd                	j	ffffffffc0203f96 <vprintfmt+0x170>
ffffffffc020402a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020402e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204032:	846a                	mv	s0,s10
ffffffffc0204034:	b5ad                	j	ffffffffc0203e9e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204036:	85a6                	mv	a1,s1
ffffffffc0204038:	02500513          	li	a0,37
ffffffffc020403c:	9902                	jalr	s2
            break;
ffffffffc020403e:	b50d                	j	ffffffffc0203e60 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204040:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204044:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204048:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020404a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020404c:	e40dd9e3          	bgez	s11,ffffffffc0203e9e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204050:	8de6                	mv	s11,s9
ffffffffc0204052:	5cfd                	li	s9,-1
ffffffffc0204054:	b5a9                	j	ffffffffc0203e9e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204056:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020405a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020405e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204060:	bd3d                	j	ffffffffc0203e9e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204062:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204066:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020406a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020406c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204070:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204074:	fcd56ce3          	bltu	a0,a3,ffffffffc020404c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204078:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020407a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020407e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204082:	0196873b          	addw	a4,a3,s9
ffffffffc0204086:	0017171b          	slliw	a4,a4,0x1
ffffffffc020408a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020408e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204092:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204096:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020409a:	fcd57fe3          	bleu	a3,a0,ffffffffc0204078 <vprintfmt+0x252>
ffffffffc020409e:	b77d                	j	ffffffffc020404c <vprintfmt+0x226>
            if (width < 0)
ffffffffc02040a0:	fffdc693          	not	a3,s11
ffffffffc02040a4:	96fd                	srai	a3,a3,0x3f
ffffffffc02040a6:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040aa:	00144603          	lbu	a2,1(s0)
ffffffffc02040ae:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040b0:	846a                	mv	s0,s10
ffffffffc02040b2:	b3f5                	j	ffffffffc0203e9e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040b4:	85a6                	mv	a1,s1
ffffffffc02040b6:	02500513          	li	a0,37
ffffffffc02040ba:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040bc:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040c0:	02500793          	li	a5,37
ffffffffc02040c4:	8d22                	mv	s10,s0
ffffffffc02040c6:	d8f70de3          	beq	a4,a5,ffffffffc0203e60 <vprintfmt+0x3a>
ffffffffc02040ca:	02500713          	li	a4,37
ffffffffc02040ce:	1d7d                	addi	s10,s10,-1
ffffffffc02040d0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040d4:	fee79de3          	bne	a5,a4,ffffffffc02040ce <vprintfmt+0x2a8>
ffffffffc02040d8:	b361                	j	ffffffffc0203e60 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040da:	00002617          	auipc	a2,0x2
ffffffffc02040de:	0a660613          	addi	a2,a2,166 # ffffffffc0206180 <error_string+0xd8>
ffffffffc02040e2:	85a6                	mv	a1,s1
ffffffffc02040e4:	854a                	mv	a0,s2
ffffffffc02040e6:	0ac000ef          	jal	ra,ffffffffc0204192 <printfmt>
ffffffffc02040ea:	bb9d                	j	ffffffffc0203e60 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02040ec:	00002617          	auipc	a2,0x2
ffffffffc02040f0:	08c60613          	addi	a2,a2,140 # ffffffffc0206178 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02040f4:	00002417          	auipc	s0,0x2
ffffffffc02040f8:	08540413          	addi	s0,s0,133 # ffffffffc0206179 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040fc:	8532                	mv	a0,a2
ffffffffc02040fe:	85e6                	mv	a1,s9
ffffffffc0204100:	e032                	sd	a2,0(sp)
ffffffffc0204102:	e43e                	sd	a5,8(sp)
ffffffffc0204104:	18a000ef          	jal	ra,ffffffffc020428e <strnlen>
ffffffffc0204108:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020410c:	6602                	ld	a2,0(sp)
ffffffffc020410e:	01b05d63          	blez	s11,ffffffffc0204128 <vprintfmt+0x302>
ffffffffc0204112:	67a2                	ld	a5,8(sp)
ffffffffc0204114:	2781                	sext.w	a5,a5
ffffffffc0204116:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204118:	6522                	ld	a0,8(sp)
ffffffffc020411a:	85a6                	mv	a1,s1
ffffffffc020411c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020411e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204120:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204122:	6602                	ld	a2,0(sp)
ffffffffc0204124:	fe0d9ae3          	bnez	s11,ffffffffc0204118 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204128:	00064783          	lbu	a5,0(a2)
ffffffffc020412c:	0007851b          	sext.w	a0,a5
ffffffffc0204130:	e8051be3          	bnez	a0,ffffffffc0203fc6 <vprintfmt+0x1a0>
ffffffffc0204134:	b335                	j	ffffffffc0203e60 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204136:	000aa403          	lw	s0,0(s5)
ffffffffc020413a:	bbf1                	j	ffffffffc0203f16 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020413c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204140:	46a9                	li	a3,10
ffffffffc0204142:	8aae                	mv	s5,a1
ffffffffc0204144:	bd89                	j	ffffffffc0203f96 <vprintfmt+0x170>
ffffffffc0204146:	000ae603          	lwu	a2,0(s5)
ffffffffc020414a:	46c1                	li	a3,16
ffffffffc020414c:	8aae                	mv	s5,a1
ffffffffc020414e:	b5a1                	j	ffffffffc0203f96 <vprintfmt+0x170>
ffffffffc0204150:	000ae603          	lwu	a2,0(s5)
ffffffffc0204154:	46a1                	li	a3,8
ffffffffc0204156:	8aae                	mv	s5,a1
ffffffffc0204158:	bd3d                	j	ffffffffc0203f96 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020415a:	9902                	jalr	s2
ffffffffc020415c:	b559                	j	ffffffffc0203fe2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020415e:	85a6                	mv	a1,s1
ffffffffc0204160:	02d00513          	li	a0,45
ffffffffc0204164:	e03e                	sd	a5,0(sp)
ffffffffc0204166:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204168:	8ace                	mv	s5,s3
ffffffffc020416a:	40800633          	neg	a2,s0
ffffffffc020416e:	46a9                	li	a3,10
ffffffffc0204170:	6782                	ld	a5,0(sp)
ffffffffc0204172:	b515                	j	ffffffffc0203f96 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204174:	01b05663          	blez	s11,ffffffffc0204180 <vprintfmt+0x35a>
ffffffffc0204178:	02d00693          	li	a3,45
ffffffffc020417c:	f6d798e3          	bne	a5,a3,ffffffffc02040ec <vprintfmt+0x2c6>
ffffffffc0204180:	00002417          	auipc	s0,0x2
ffffffffc0204184:	ff940413          	addi	s0,s0,-7 # ffffffffc0206179 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204188:	02800513          	li	a0,40
ffffffffc020418c:	02800793          	li	a5,40
ffffffffc0204190:	bd1d                	j	ffffffffc0203fc6 <vprintfmt+0x1a0>

ffffffffc0204192 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204192:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204194:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204198:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020419a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020419c:	ec06                	sd	ra,24(sp)
ffffffffc020419e:	f83a                	sd	a4,48(sp)
ffffffffc02041a0:	fc3e                	sd	a5,56(sp)
ffffffffc02041a2:	e0c2                	sd	a6,64(sp)
ffffffffc02041a4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041a6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041a8:	c7fff0ef          	jal	ra,ffffffffc0203e26 <vprintfmt>
}
ffffffffc02041ac:	60e2                	ld	ra,24(sp)
ffffffffc02041ae:	6161                	addi	sp,sp,80
ffffffffc02041b0:	8082                	ret

ffffffffc02041b2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041b2:	715d                	addi	sp,sp,-80
ffffffffc02041b4:	e486                	sd	ra,72(sp)
ffffffffc02041b6:	e0a2                	sd	s0,64(sp)
ffffffffc02041b8:	fc26                	sd	s1,56(sp)
ffffffffc02041ba:	f84a                	sd	s2,48(sp)
ffffffffc02041bc:	f44e                	sd	s3,40(sp)
ffffffffc02041be:	f052                	sd	s4,32(sp)
ffffffffc02041c0:	ec56                	sd	s5,24(sp)
ffffffffc02041c2:	e85a                	sd	s6,16(sp)
ffffffffc02041c4:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041c6:	c901                	beqz	a0,ffffffffc02041d6 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041c8:	85aa                	mv	a1,a0
ffffffffc02041ca:	00002517          	auipc	a0,0x2
ffffffffc02041ce:	fc650513          	addi	a0,a0,-58 # ffffffffc0206190 <error_string+0xe8>
ffffffffc02041d2:	eedfb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041d6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041d8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041da:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041dc:	4aa9                	li	s5,10
ffffffffc02041de:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041e0:	0000db97          	auipc	s7,0xd
ffffffffc02041e4:	e60b8b93          	addi	s7,s7,-416 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041e8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02041ec:	f0bfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041f0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041f2:	00054b63          	bltz	a0,ffffffffc0204208 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041f6:	00a95b63          	ble	a0,s2,ffffffffc020420c <readline+0x5a>
ffffffffc02041fa:	029a5463          	ble	s1,s4,ffffffffc0204222 <readline+0x70>
        c = getchar();
ffffffffc02041fe:	ef9fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204202:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204204:	fe0559e3          	bgez	a0,ffffffffc02041f6 <readline+0x44>
            return NULL;
ffffffffc0204208:	4501                	li	a0,0
ffffffffc020420a:	a099                	j	ffffffffc0204250 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020420c:	03341463          	bne	s0,s3,ffffffffc0204234 <readline+0x82>
ffffffffc0204210:	e8b9                	bnez	s1,ffffffffc0204266 <readline+0xb4>
        c = getchar();
ffffffffc0204212:	ee5fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204216:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204218:	fe0548e3          	bltz	a0,ffffffffc0204208 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020421c:	fea958e3          	ble	a0,s2,ffffffffc020420c <readline+0x5a>
ffffffffc0204220:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204222:	8522                	mv	a0,s0
ffffffffc0204224:	ecffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0204228:	009b87b3          	add	a5,s7,s1
ffffffffc020422c:	00878023          	sb	s0,0(a5)
ffffffffc0204230:	2485                	addiw	s1,s1,1
ffffffffc0204232:	bf6d                	j	ffffffffc02041ec <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204234:	01540463          	beq	s0,s5,ffffffffc020423c <readline+0x8a>
ffffffffc0204238:	fb641ae3          	bne	s0,s6,ffffffffc02041ec <readline+0x3a>
            cputchar(c);
ffffffffc020423c:	8522                	mv	a0,s0
ffffffffc020423e:	eb5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204242:	0000d517          	auipc	a0,0xd
ffffffffc0204246:	dfe50513          	addi	a0,a0,-514 # ffffffffc0211040 <buf>
ffffffffc020424a:	94aa                	add	s1,s1,a0
ffffffffc020424c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204250:	60a6                	ld	ra,72(sp)
ffffffffc0204252:	6406                	ld	s0,64(sp)
ffffffffc0204254:	74e2                	ld	s1,56(sp)
ffffffffc0204256:	7942                	ld	s2,48(sp)
ffffffffc0204258:	79a2                	ld	s3,40(sp)
ffffffffc020425a:	7a02                	ld	s4,32(sp)
ffffffffc020425c:	6ae2                	ld	s5,24(sp)
ffffffffc020425e:	6b42                	ld	s6,16(sp)
ffffffffc0204260:	6ba2                	ld	s7,8(sp)
ffffffffc0204262:	6161                	addi	sp,sp,80
ffffffffc0204264:	8082                	ret
            cputchar(c);
ffffffffc0204266:	4521                	li	a0,8
ffffffffc0204268:	e8bfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc020426c:	34fd                	addiw	s1,s1,-1
ffffffffc020426e:	bfbd                	j	ffffffffc02041ec <readline+0x3a>

ffffffffc0204270 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204270:	00054783          	lbu	a5,0(a0)
ffffffffc0204274:	cb91                	beqz	a5,ffffffffc0204288 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204276:	4781                	li	a5,0
        cnt ++;
ffffffffc0204278:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020427a:	00f50733          	add	a4,a0,a5
ffffffffc020427e:	00074703          	lbu	a4,0(a4)
ffffffffc0204282:	fb7d                	bnez	a4,ffffffffc0204278 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204284:	853e                	mv	a0,a5
ffffffffc0204286:	8082                	ret
    size_t cnt = 0;
ffffffffc0204288:	4781                	li	a5,0
}
ffffffffc020428a:	853e                	mv	a0,a5
ffffffffc020428c:	8082                	ret

ffffffffc020428e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020428e:	c185                	beqz	a1,ffffffffc02042ae <strnlen+0x20>
ffffffffc0204290:	00054783          	lbu	a5,0(a0)
ffffffffc0204294:	cf89                	beqz	a5,ffffffffc02042ae <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204296:	4781                	li	a5,0
ffffffffc0204298:	a021                	j	ffffffffc02042a0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020429a:	00074703          	lbu	a4,0(a4)
ffffffffc020429e:	c711                	beqz	a4,ffffffffc02042aa <strnlen+0x1c>
        cnt ++;
ffffffffc02042a0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042a2:	00f50733          	add	a4,a0,a5
ffffffffc02042a6:	fef59ae3          	bne	a1,a5,ffffffffc020429a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042aa:	853e                	mv	a0,a5
ffffffffc02042ac:	8082                	ret
    size_t cnt = 0;
ffffffffc02042ae:	4781                	li	a5,0
}
ffffffffc02042b0:	853e                	mv	a0,a5
ffffffffc02042b2:	8082                	ret

ffffffffc02042b4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042b4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042b6:	0585                	addi	a1,a1,1
ffffffffc02042b8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042bc:	0785                	addi	a5,a5,1
ffffffffc02042be:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042c2:	fb75                	bnez	a4,ffffffffc02042b6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042c4:	8082                	ret

ffffffffc02042c6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042c6:	00054783          	lbu	a5,0(a0)
ffffffffc02042ca:	0005c703          	lbu	a4,0(a1)
ffffffffc02042ce:	cb91                	beqz	a5,ffffffffc02042e2 <strcmp+0x1c>
ffffffffc02042d0:	00e79c63          	bne	a5,a4,ffffffffc02042e8 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042d4:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042d6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042da:	0585                	addi	a1,a1,1
ffffffffc02042dc:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042e0:	fbe5                	bnez	a5,ffffffffc02042d0 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042e2:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042e4:	9d19                	subw	a0,a0,a4
ffffffffc02042e6:	8082                	ret
ffffffffc02042e8:	0007851b          	sext.w	a0,a5
ffffffffc02042ec:	9d19                	subw	a0,a0,a4
ffffffffc02042ee:	8082                	ret

ffffffffc02042f0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02042f0:	00054783          	lbu	a5,0(a0)
ffffffffc02042f4:	cb91                	beqz	a5,ffffffffc0204308 <strchr+0x18>
        if (*s == c) {
ffffffffc02042f6:	00b79563          	bne	a5,a1,ffffffffc0204300 <strchr+0x10>
ffffffffc02042fa:	a809                	j	ffffffffc020430c <strchr+0x1c>
ffffffffc02042fc:	00b78763          	beq	a5,a1,ffffffffc020430a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204300:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204302:	00054783          	lbu	a5,0(a0)
ffffffffc0204306:	fbfd                	bnez	a5,ffffffffc02042fc <strchr+0xc>
    }
    return NULL;
ffffffffc0204308:	4501                	li	a0,0
}
ffffffffc020430a:	8082                	ret
ffffffffc020430c:	8082                	ret

ffffffffc020430e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020430e:	ca01                	beqz	a2,ffffffffc020431e <memset+0x10>
ffffffffc0204310:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204312:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204314:	0785                	addi	a5,a5,1
ffffffffc0204316:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020431a:	fec79de3          	bne	a5,a2,ffffffffc0204314 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020431e:	8082                	ret

ffffffffc0204320 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204320:	ca19                	beqz	a2,ffffffffc0204336 <memcpy+0x16>
ffffffffc0204322:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204324:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204326:	0585                	addi	a1,a1,1
ffffffffc0204328:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020432c:	0785                	addi	a5,a5,1
ffffffffc020432e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204332:	fec59ae3          	bne	a1,a2,ffffffffc0204326 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204336:	8082                	ret
