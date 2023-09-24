
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	201000ef          	jal	ra,80200a24 <memset>

    cons_init();  // init the console
    80200028:	14c000ef          	jal	ra,80200174 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a0c58593          	addi	a1,a1,-1524 # 80200a38 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a2450513          	addi	a0,a0,-1500 # 80200a58 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	060000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200044:	140000ef          	jal	ra,80200184 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0e8000ef          	jal	ra,80200130 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004c:	132000ef          	jal	ra,8020017e <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	11c000ef          	jal	ra,80200176 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	862a                	mv	a2,a0
    8020007a:	004c                	addi	a1,sp,4
    8020007c:	00000517          	auipc	a0,0x0
    80200080:	fd650513          	addi	a0,a0,-42 # 80200052 <cputch>
    80200084:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	58a000ef          	jal	ra,8020061e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	9be50513          	addi	a0,a0,-1602 # 80200a60 <etext+0x2a>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5c58593          	addi	a1,a1,-164 # 8020000c <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	9c850513          	addi	a0,a0,-1592 # 80200a80 <etext+0x4a>
    802000c0:	fadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	97258593          	addi	a1,a1,-1678 # 80200a36 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	9d450513          	addi	a0,a0,-1580 # 80200aa0 <etext+0x6a>
    802000d4:	f99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <edata>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	9e050513          	addi	a0,a0,-1568 # 80200ac0 <etext+0x8a>
    802000e8:	f85ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	9ec50513          	addi	a0,a0,-1556 # 80200ae0 <etext+0xaa>
    802000fc:	f71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0478793          	addi	a5,a5,-252 # 8020000c <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	9de50513          	addi	a0,a0,-1570 # 80200b00 <etext+0xca>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	f41ff06f          	j	8020006c <cprintf>

0000000080200130 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200130:	1141                	addi	sp,sp,-16
    80200132:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200134:	02000793          	li	a5,32
    80200138:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200140:	67e1                	lui	a5,0x18
    80200142:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200146:	953e                	add	a0,a0,a5
    80200148:	07f000ef          	jal	ra,802009c6 <sbi_set_timer>
}
    8020014c:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014e:	00004797          	auipc	a5,0x4
    80200152:	ec07b923          	sd	zero,-302(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200156:	00001517          	auipc	a0,0x1
    8020015a:	9da50513          	addi	a0,a0,-1574 # 80200b30 <etext+0xfa>
}
    8020015e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200160:	f0dff06f          	j	8020006c <cprintf>

0000000080200164 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200164:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200168:	67e1                	lui	a5,0x18
    8020016a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020016e:	953e                	add	a0,a0,a5
    80200170:	0570006f          	j	802009c6 <sbi_set_timer>

0000000080200174 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200174:	8082                	ret

0000000080200176 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200176:	0ff57513          	andi	a0,a0,255
    8020017a:	0310006f          	j	802009aa <sbi_console_putchar>

000000008020017e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017e:	100167f3          	csrrsi	a5,sstatus,2
    80200182:	8082                	ret

0000000080200184 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200184:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200188:	00000797          	auipc	a5,0x0
    8020018c:	37478793          	addi	a5,a5,884 # 802004fc <__alltraps>
    80200190:	10579073          	csrw	stvec,a5
}
    80200194:	8082                	ret

0000000080200196 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200198:	1141                	addi	sp,sp,-16
    8020019a:	e022                	sd	s0,0(sp)
    8020019c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	00001517          	auipc	a0,0x1
    802001a2:	aea50513          	addi	a0,a0,-1302 # 80200c88 <etext+0x252>
void print_regs(struct pushregs *gpr) {
    802001a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a8:	ec5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ac:	640c                	ld	a1,8(s0)
    802001ae:	00001517          	auipc	a0,0x1
    802001b2:	af250513          	addi	a0,a0,-1294 # 80200ca0 <etext+0x26a>
    802001b6:	eb7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001ba:	680c                	ld	a1,16(s0)
    802001bc:	00001517          	auipc	a0,0x1
    802001c0:	afc50513          	addi	a0,a0,-1284 # 80200cb8 <etext+0x282>
    802001c4:	ea9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c8:	6c0c                	ld	a1,24(s0)
    802001ca:	00001517          	auipc	a0,0x1
    802001ce:	b0650513          	addi	a0,a0,-1274 # 80200cd0 <etext+0x29a>
    802001d2:	e9bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d6:	700c                	ld	a1,32(s0)
    802001d8:	00001517          	auipc	a0,0x1
    802001dc:	b1050513          	addi	a0,a0,-1264 # 80200ce8 <etext+0x2b2>
    802001e0:	e8dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e4:	740c                	ld	a1,40(s0)
    802001e6:	00001517          	auipc	a0,0x1
    802001ea:	b1a50513          	addi	a0,a0,-1254 # 80200d00 <etext+0x2ca>
    802001ee:	e7fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f2:	780c                	ld	a1,48(s0)
    802001f4:	00001517          	auipc	a0,0x1
    802001f8:	b2450513          	addi	a0,a0,-1244 # 80200d18 <etext+0x2e2>
    802001fc:	e71ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200200:	7c0c                	ld	a1,56(s0)
    80200202:	00001517          	auipc	a0,0x1
    80200206:	b2e50513          	addi	a0,a0,-1234 # 80200d30 <etext+0x2fa>
    8020020a:	e63ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020e:	602c                	ld	a1,64(s0)
    80200210:	00001517          	auipc	a0,0x1
    80200214:	b3850513          	addi	a0,a0,-1224 # 80200d48 <etext+0x312>
    80200218:	e55ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021c:	642c                	ld	a1,72(s0)
    8020021e:	00001517          	auipc	a0,0x1
    80200222:	b4250513          	addi	a0,a0,-1214 # 80200d60 <etext+0x32a>
    80200226:	e47ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022a:	682c                	ld	a1,80(s0)
    8020022c:	00001517          	auipc	a0,0x1
    80200230:	b4c50513          	addi	a0,a0,-1204 # 80200d78 <etext+0x342>
    80200234:	e39ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200238:	6c2c                	ld	a1,88(s0)
    8020023a:	00001517          	auipc	a0,0x1
    8020023e:	b5650513          	addi	a0,a0,-1194 # 80200d90 <etext+0x35a>
    80200242:	e2bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200246:	702c                	ld	a1,96(s0)
    80200248:	00001517          	auipc	a0,0x1
    8020024c:	b6050513          	addi	a0,a0,-1184 # 80200da8 <etext+0x372>
    80200250:	e1dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200254:	742c                	ld	a1,104(s0)
    80200256:	00001517          	auipc	a0,0x1
    8020025a:	b6a50513          	addi	a0,a0,-1174 # 80200dc0 <etext+0x38a>
    8020025e:	e0fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200262:	782c                	ld	a1,112(s0)
    80200264:	00001517          	auipc	a0,0x1
    80200268:	b7450513          	addi	a0,a0,-1164 # 80200dd8 <etext+0x3a2>
    8020026c:	e01ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200270:	7c2c                	ld	a1,120(s0)
    80200272:	00001517          	auipc	a0,0x1
    80200276:	b7e50513          	addi	a0,a0,-1154 # 80200df0 <etext+0x3ba>
    8020027a:	df3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027e:	604c                	ld	a1,128(s0)
    80200280:	00001517          	auipc	a0,0x1
    80200284:	b8850513          	addi	a0,a0,-1144 # 80200e08 <etext+0x3d2>
    80200288:	de5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028c:	644c                	ld	a1,136(s0)
    8020028e:	00001517          	auipc	a0,0x1
    80200292:	b9250513          	addi	a0,a0,-1134 # 80200e20 <etext+0x3ea>
    80200296:	dd7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029a:	684c                	ld	a1,144(s0)
    8020029c:	00001517          	auipc	a0,0x1
    802002a0:	b9c50513          	addi	a0,a0,-1124 # 80200e38 <etext+0x402>
    802002a4:	dc9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a8:	6c4c                	ld	a1,152(s0)
    802002aa:	00001517          	auipc	a0,0x1
    802002ae:	ba650513          	addi	a0,a0,-1114 # 80200e50 <etext+0x41a>
    802002b2:	dbbff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b6:	704c                	ld	a1,160(s0)
    802002b8:	00001517          	auipc	a0,0x1
    802002bc:	bb050513          	addi	a0,a0,-1104 # 80200e68 <etext+0x432>
    802002c0:	dadff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c4:	744c                	ld	a1,168(s0)
    802002c6:	00001517          	auipc	a0,0x1
    802002ca:	bba50513          	addi	a0,a0,-1094 # 80200e80 <etext+0x44a>
    802002ce:	d9fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d2:	784c                	ld	a1,176(s0)
    802002d4:	00001517          	auipc	a0,0x1
    802002d8:	bc450513          	addi	a0,a0,-1084 # 80200e98 <etext+0x462>
    802002dc:	d91ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e0:	7c4c                	ld	a1,184(s0)
    802002e2:	00001517          	auipc	a0,0x1
    802002e6:	bce50513          	addi	a0,a0,-1074 # 80200eb0 <etext+0x47a>
    802002ea:	d83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ee:	606c                	ld	a1,192(s0)
    802002f0:	00001517          	auipc	a0,0x1
    802002f4:	bd850513          	addi	a0,a0,-1064 # 80200ec8 <etext+0x492>
    802002f8:	d75ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fc:	646c                	ld	a1,200(s0)
    802002fe:	00001517          	auipc	a0,0x1
    80200302:	be250513          	addi	a0,a0,-1054 # 80200ee0 <etext+0x4aa>
    80200306:	d67ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030a:	686c                	ld	a1,208(s0)
    8020030c:	00001517          	auipc	a0,0x1
    80200310:	bec50513          	addi	a0,a0,-1044 # 80200ef8 <etext+0x4c2>
    80200314:	d59ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200318:	6c6c                	ld	a1,216(s0)
    8020031a:	00001517          	auipc	a0,0x1
    8020031e:	bf650513          	addi	a0,a0,-1034 # 80200f10 <etext+0x4da>
    80200322:	d4bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200326:	706c                	ld	a1,224(s0)
    80200328:	00001517          	auipc	a0,0x1
    8020032c:	c0050513          	addi	a0,a0,-1024 # 80200f28 <etext+0x4f2>
    80200330:	d3dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200334:	746c                	ld	a1,232(s0)
    80200336:	00001517          	auipc	a0,0x1
    8020033a:	c0a50513          	addi	a0,a0,-1014 # 80200f40 <etext+0x50a>
    8020033e:	d2fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200342:	786c                	ld	a1,240(s0)
    80200344:	00001517          	auipc	a0,0x1
    80200348:	c1450513          	addi	a0,a0,-1004 # 80200f58 <etext+0x522>
    8020034c:	d21ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	7c6c                	ld	a1,248(s0)
}
    80200352:	6402                	ld	s0,0(sp)
    80200354:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	00001517          	auipc	a0,0x1
    8020035a:	c1a50513          	addi	a0,a0,-998 # 80200f70 <etext+0x53a>
}
    8020035e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200360:	d0dff06f          	j	8020006c <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	c1c50513          	addi	a0,a0,-996 # 80200f88 <etext+0x552>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cf7ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1bff0ef          	jal	ra,80200196 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	c1c50513          	addi	a0,a0,-996 # 80200fa0 <etext+0x56a>
    8020038c:	ce1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	c2450513          	addi	a0,a0,-988 # 80200fb8 <etext+0x582>
    8020039c:	cd1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	c2c50513          	addi	a0,a0,-980 # 80200fd0 <etext+0x59a>
    802003ac:	cc1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	c3050513          	addi	a0,a0,-976 # 80200fe8 <etext+0x5b2>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	cabff06f          	j	8020006c <cprintf>

00000000802003c6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c6:	11853783          	ld	a5,280(a0)
    802003ca:	577d                	li	a4,-1
    802003cc:	8305                	srli	a4,a4,0x1
    802003ce:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d0:	472d                	li	a4,11
    802003d2:	08f76a63          	bltu	a4,a5,80200466 <interrupt_handler+0xa0>
    802003d6:	00000717          	auipc	a4,0x0
    802003da:	77670713          	addi	a4,a4,1910 # 80200b4c <etext+0x116>
    802003de:	078a                	slli	a5,a5,0x2
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	439c                	lw	a5,0(a5)
    802003e4:	97ba                	add	a5,a5,a4
    802003e6:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	85050513          	addi	a0,a0,-1968 # 80200c38 <etext+0x202>
    802003f0:	c7dff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f4:	00001517          	auipc	a0,0x1
    802003f8:	82450513          	addi	a0,a0,-2012 # 80200c18 <etext+0x1e2>
    802003fc:	c71ff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200400:	00000517          	auipc	a0,0x0
    80200404:	7d850513          	addi	a0,a0,2008 # 80200bd8 <etext+0x1a2>
    80200408:	c65ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00000517          	auipc	a0,0x0
    80200410:	7ec50513          	addi	a0,a0,2028 # 80200bf8 <etext+0x1c2>
    80200414:	c59ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200418:	00001517          	auipc	a0,0x1
    8020041c:	85050513          	addi	a0,a0,-1968 # 80200c68 <etext+0x232>
    80200420:	c4dff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200424:	1141                	addi	sp,sp,-16
    80200426:	e022                	sd	s0,0(sp)
    80200428:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    8020042a:	d3bff0ef          	jal	ra,80200164 <clock_set_next_event>
            ticks++;
    8020042e:	00004717          	auipc	a4,0x4
    80200432:	bf270713          	addi	a4,a4,-1038 # 80204020 <ticks>
    80200436:	631c                	ld	a5,0(a4)
    80200438:	00004417          	auipc	s0,0x4
    8020043c:	bd840413          	addi	s0,s0,-1064 # 80204010 <edata>
    80200440:	0785                	addi	a5,a5,1
    80200442:	00004697          	auipc	a3,0x4
    80200446:	bcf6bf23          	sd	a5,-1058(a3) # 80204020 <ticks>
            if(ticks%100==0){
    8020044a:	631c                	ld	a5,0(a4)
    8020044c:	06400713          	li	a4,100
    80200450:	02e7f7b3          	remu	a5,a5,a4
    80200454:	cb99                	beqz	a5,8020046a <interrupt_handler+0xa4>
	if(num==10){
    80200456:	6018                	ld	a4,0(s0)
    80200458:	47a9                	li	a5,10
    8020045a:	02f70763          	beq	a4,a5,80200488 <interrupt_handler+0xc2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020045e:	60a2                	ld	ra,8(sp)
    80200460:	6402                	ld	s0,0(sp)
    80200462:	0141                	addi	sp,sp,16
    80200464:	8082                	ret
            print_trapframe(tf);
    80200466:	effff06f          	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020046a:	06400593          	li	a1,100
    8020046e:	00000517          	auipc	a0,0x0
    80200472:	7ea50513          	addi	a0,a0,2026 # 80200c58 <etext+0x222>
    80200476:	bf7ff0ef          	jal	ra,8020006c <cprintf>
            num++;
    8020047a:	601c                	ld	a5,0(s0)
    8020047c:	0785                	addi	a5,a5,1
    8020047e:	00004717          	auipc	a4,0x4
    80200482:	b8f73923          	sd	a5,-1134(a4) # 80204010 <edata>
    80200486:	bfc1                	j	80200456 <interrupt_handler+0x90>
}
    80200488:	6402                	ld	s0,0(sp)
    8020048a:	60a2                	ld	ra,8(sp)
    8020048c:	0141                	addi	sp,sp,16
	sbi_shutdown();
    8020048e:	5540006f          	j	802009e2 <sbi_shutdown>

0000000080200492 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200492:	11853783          	ld	a5,280(a0)
    80200496:	472d                	li	a4,11
    80200498:	00f76b63          	bltu	a4,a5,802004ae <exception_handler+0x1c>
    8020049c:	4705                	li	a4,1
    8020049e:	00f71733          	sll	a4,a4,a5
    802004a2:	6785                	lui	a5,0x1
    802004a4:	17cd                	addi	a5,a5,-13
    802004a6:	8ff9                	and	a5,a5,a4
    802004a8:	e789                	bnez	a5,802004b2 <exception_handler+0x20>
    802004aa:	8b31                	andi	a4,a4,12
    802004ac:	e701                	bnez	a4,802004b4 <exception_handler+0x22>
        case CAUSE_HYPERVISOR_ECALL:
            break;
        case CAUSE_MACHINE_ECALL:
            break;
        default:
            print_trapframe(tf);
    802004ae:	eb7ff06f          	j	80200364 <print_trapframe>
    802004b2:	8082                	ret
void exception_handler(struct trapframe *tf) {
    802004b4:	1141                	addi	sp,sp,-16
    802004b6:	e022                	sd	s0,0(sp)
    802004b8:	842a                	mv	s0,a0
            cprintf("Exception type:Illegal instruction\n");
    802004ba:	00000517          	auipc	a0,0x0
    802004be:	6c650513          	addi	a0,a0,1734 # 80200b80 <etext+0x14a>
void exception_handler(struct trapframe *tf) {
    802004c2:	e406                	sd	ra,8(sp)
            cprintf("Exception type:Illegal instruction\n");
    802004c4:	ba9ff0ef          	jal	ra,8020006c <cprintf>
             cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
    802004c8:	10843583          	ld	a1,264(s0)
    802004cc:	00000517          	auipc	a0,0x0
    802004d0:	6dc50513          	addi	a0,a0,1756 # 80200ba8 <etext+0x172>
    802004d4:	b99ff0ef          	jal	ra,8020006c <cprintf>
              tf->epc += 4;     //更新 tf->epc寄存器,机器模式异常返回指令mret是32位指令，长4字节
    802004d8:	10843783          	ld	a5,264(s0)
            break;
    }
}
    802004dc:	60a2                	ld	ra,8(sp)
              tf->epc += 4;     //更新 tf->epc寄存器,机器模式异常返回指令mret是32位指令，长4字节
    802004de:	0791                	addi	a5,a5,4
    802004e0:	10f43423          	sd	a5,264(s0)
}
    802004e4:	6402                	ld	s0,0(sp)
    802004e6:	0141                	addi	sp,sp,16
    802004e8:	8082                	ret

00000000802004ea <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004ea:	11853783          	ld	a5,280(a0)
    802004ee:	0007c463          	bltz	a5,802004f6 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004f2:	fa1ff06f          	j	80200492 <exception_handler>
        interrupt_handler(tf);
    802004f6:	ed1ff06f          	j	802003c6 <interrupt_handler>
	...

00000000802004fc <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004fc:	14011073          	csrw	sscratch,sp
    80200500:	712d                	addi	sp,sp,-288
    80200502:	e002                	sd	zero,0(sp)
    80200504:	e406                	sd	ra,8(sp)
    80200506:	ec0e                	sd	gp,24(sp)
    80200508:	f012                	sd	tp,32(sp)
    8020050a:	f416                	sd	t0,40(sp)
    8020050c:	f81a                	sd	t1,48(sp)
    8020050e:	fc1e                	sd	t2,56(sp)
    80200510:	e0a2                	sd	s0,64(sp)
    80200512:	e4a6                	sd	s1,72(sp)
    80200514:	e8aa                	sd	a0,80(sp)
    80200516:	ecae                	sd	a1,88(sp)
    80200518:	f0b2                	sd	a2,96(sp)
    8020051a:	f4b6                	sd	a3,104(sp)
    8020051c:	f8ba                	sd	a4,112(sp)
    8020051e:	fcbe                	sd	a5,120(sp)
    80200520:	e142                	sd	a6,128(sp)
    80200522:	e546                	sd	a7,136(sp)
    80200524:	e94a                	sd	s2,144(sp)
    80200526:	ed4e                	sd	s3,152(sp)
    80200528:	f152                	sd	s4,160(sp)
    8020052a:	f556                	sd	s5,168(sp)
    8020052c:	f95a                	sd	s6,176(sp)
    8020052e:	fd5e                	sd	s7,184(sp)
    80200530:	e1e2                	sd	s8,192(sp)
    80200532:	e5e6                	sd	s9,200(sp)
    80200534:	e9ea                	sd	s10,208(sp)
    80200536:	edee                	sd	s11,216(sp)
    80200538:	f1f2                	sd	t3,224(sp)
    8020053a:	f5f6                	sd	t4,232(sp)
    8020053c:	f9fa                	sd	t5,240(sp)
    8020053e:	fdfe                	sd	t6,248(sp)
    80200540:	14001473          	csrrw	s0,sscratch,zero
    80200544:	100024f3          	csrr	s1,sstatus
    80200548:	14102973          	csrr	s2,sepc
    8020054c:	143029f3          	csrr	s3,stval
    80200550:	14202a73          	csrr	s4,scause
    80200554:	e822                	sd	s0,16(sp)
    80200556:	e226                	sd	s1,256(sp)
    80200558:	e64a                	sd	s2,264(sp)
    8020055a:	ea4e                	sd	s3,272(sp)
    8020055c:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020055e:	850a                	mv	a0,sp
    jal trap
    80200560:	f8bff0ef          	jal	ra,802004ea <trap>

0000000080200564 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200564:	6492                	ld	s1,256(sp)
    80200566:	6932                	ld	s2,264(sp)
    80200568:	10049073          	csrw	sstatus,s1
    8020056c:	14191073          	csrw	sepc,s2
    80200570:	60a2                	ld	ra,8(sp)
    80200572:	61e2                	ld	gp,24(sp)
    80200574:	7202                	ld	tp,32(sp)
    80200576:	72a2                	ld	t0,40(sp)
    80200578:	7342                	ld	t1,48(sp)
    8020057a:	73e2                	ld	t2,56(sp)
    8020057c:	6406                	ld	s0,64(sp)
    8020057e:	64a6                	ld	s1,72(sp)
    80200580:	6546                	ld	a0,80(sp)
    80200582:	65e6                	ld	a1,88(sp)
    80200584:	7606                	ld	a2,96(sp)
    80200586:	76a6                	ld	a3,104(sp)
    80200588:	7746                	ld	a4,112(sp)
    8020058a:	77e6                	ld	a5,120(sp)
    8020058c:	680a                	ld	a6,128(sp)
    8020058e:	68aa                	ld	a7,136(sp)
    80200590:	694a                	ld	s2,144(sp)
    80200592:	69ea                	ld	s3,152(sp)
    80200594:	7a0a                	ld	s4,160(sp)
    80200596:	7aaa                	ld	s5,168(sp)
    80200598:	7b4a                	ld	s6,176(sp)
    8020059a:	7bea                	ld	s7,184(sp)
    8020059c:	6c0e                	ld	s8,192(sp)
    8020059e:	6cae                	ld	s9,200(sp)
    802005a0:	6d4e                	ld	s10,208(sp)
    802005a2:	6dee                	ld	s11,216(sp)
    802005a4:	7e0e                	ld	t3,224(sp)
    802005a6:	7eae                	ld	t4,232(sp)
    802005a8:	7f4e                	ld	t5,240(sp)
    802005aa:	7fee                	ld	t6,248(sp)
    802005ac:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ae:	10200073          	sret

00000000802005b2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005b2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005b8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005bc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005be:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005c2:	f022                	sd	s0,32(sp)
    802005c4:	ec26                	sd	s1,24(sp)
    802005c6:	e84a                	sd	s2,16(sp)
    802005c8:	f406                	sd	ra,40(sp)
    802005ca:	e44e                	sd	s3,8(sp)
    802005cc:	84aa                	mv	s1,a0
    802005ce:	892e                	mv	s2,a1
    802005d0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005d4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005d6:	03067e63          	bleu	a6,a2,80200612 <printnum+0x60>
    802005da:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005dc:	00805763          	blez	s0,802005ea <printnum+0x38>
    802005e0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005e2:	85ca                	mv	a1,s2
    802005e4:	854e                	mv	a0,s3
    802005e6:	9482                	jalr	s1
        while (-- width > 0)
    802005e8:	fc65                	bnez	s0,802005e0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005ea:	1a02                	slli	s4,s4,0x20
    802005ec:	020a5a13          	srli	s4,s4,0x20
    802005f0:	00001797          	auipc	a5,0x1
    802005f4:	ba078793          	addi	a5,a5,-1120 # 80201190 <error_string+0x38>
    802005f8:	9a3e                	add	s4,s4,a5
}
    802005fa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005fc:	000a4503          	lbu	a0,0(s4)
}
    80200600:	70a2                	ld	ra,40(sp)
    80200602:	69a2                	ld	s3,8(sp)
    80200604:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200606:	85ca                	mv	a1,s2
    80200608:	8326                	mv	t1,s1
}
    8020060a:	6942                	ld	s2,16(sp)
    8020060c:	64e2                	ld	s1,24(sp)
    8020060e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200610:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200612:	03065633          	divu	a2,a2,a6
    80200616:	8722                	mv	a4,s0
    80200618:	f9bff0ef          	jal	ra,802005b2 <printnum>
    8020061c:	b7f9                	j	802005ea <printnum+0x38>

000000008020061e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020061e:	7119                	addi	sp,sp,-128
    80200620:	f4a6                	sd	s1,104(sp)
    80200622:	f0ca                	sd	s2,96(sp)
    80200624:	e8d2                	sd	s4,80(sp)
    80200626:	e4d6                	sd	s5,72(sp)
    80200628:	e0da                	sd	s6,64(sp)
    8020062a:	fc5e                	sd	s7,56(sp)
    8020062c:	f862                	sd	s8,48(sp)
    8020062e:	f06a                	sd	s10,32(sp)
    80200630:	fc86                	sd	ra,120(sp)
    80200632:	f8a2                	sd	s0,112(sp)
    80200634:	ecce                	sd	s3,88(sp)
    80200636:	f466                	sd	s9,40(sp)
    80200638:	ec6e                	sd	s11,24(sp)
    8020063a:	892a                	mv	s2,a0
    8020063c:	84ae                	mv	s1,a1
    8020063e:	8d32                	mv	s10,a2
    80200640:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200642:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200644:	00001a17          	auipc	s4,0x1
    80200648:	9b8a0a13          	addi	s4,s4,-1608 # 80200ffc <etext+0x5c6>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    8020064c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200650:	00001c17          	auipc	s8,0x1
    80200654:	b08c0c13          	addi	s8,s8,-1272 # 80201158 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200658:	000d4503          	lbu	a0,0(s10)
    8020065c:	02500793          	li	a5,37
    80200660:	001d0413          	addi	s0,s10,1
    80200664:	00f50e63          	beq	a0,a5,80200680 <vprintfmt+0x62>
            if (ch == '\0') {
    80200668:	c521                	beqz	a0,802006b0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020066a:	02500993          	li	s3,37
    8020066e:	a011                	j	80200672 <vprintfmt+0x54>
            if (ch == '\0') {
    80200670:	c121                	beqz	a0,802006b0 <vprintfmt+0x92>
            putch(ch, putdat);
    80200672:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200674:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200676:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200678:	fff44503          	lbu	a0,-1(s0)
    8020067c:	ff351ae3          	bne	a0,s3,80200670 <vprintfmt+0x52>
    80200680:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200684:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200688:	4981                	li	s3,0
    8020068a:	4801                	li	a6,0
        width = precision = -1;
    8020068c:	5cfd                	li	s9,-1
    8020068e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200690:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200694:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200696:	fdd6069b          	addiw	a3,a2,-35
    8020069a:	0ff6f693          	andi	a3,a3,255
    8020069e:	00140d13          	addi	s10,s0,1
    802006a2:	20d5e563          	bltu	a1,a3,802008ac <vprintfmt+0x28e>
    802006a6:	068a                	slli	a3,a3,0x2
    802006a8:	96d2                	add	a3,a3,s4
    802006aa:	4294                	lw	a3,0(a3)
    802006ac:	96d2                	add	a3,a3,s4
    802006ae:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006b0:	70e6                	ld	ra,120(sp)
    802006b2:	7446                	ld	s0,112(sp)
    802006b4:	74a6                	ld	s1,104(sp)
    802006b6:	7906                	ld	s2,96(sp)
    802006b8:	69e6                	ld	s3,88(sp)
    802006ba:	6a46                	ld	s4,80(sp)
    802006bc:	6aa6                	ld	s5,72(sp)
    802006be:	6b06                	ld	s6,64(sp)
    802006c0:	7be2                	ld	s7,56(sp)
    802006c2:	7c42                	ld	s8,48(sp)
    802006c4:	7ca2                	ld	s9,40(sp)
    802006c6:	7d02                	ld	s10,32(sp)
    802006c8:	6de2                	ld	s11,24(sp)
    802006ca:	6109                	addi	sp,sp,128
    802006cc:	8082                	ret
    if (lflag >= 2) {
    802006ce:	4705                	li	a4,1
    802006d0:	008a8593          	addi	a1,s5,8
    802006d4:	01074463          	blt	a4,a6,802006dc <vprintfmt+0xbe>
    else if (lflag) {
    802006d8:	26080363          	beqz	a6,8020093e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    802006dc:	000ab603          	ld	a2,0(s5)
    802006e0:	46c1                	li	a3,16
    802006e2:	8aae                	mv	s5,a1
    802006e4:	a06d                	j	8020078e <vprintfmt+0x170>
            goto reswitch;
    802006e6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802006ea:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    802006ec:	846a                	mv	s0,s10
            goto reswitch;
    802006ee:	b765                	j	80200696 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    802006f0:	000aa503          	lw	a0,0(s5)
    802006f4:	85a6                	mv	a1,s1
    802006f6:	0aa1                	addi	s5,s5,8
    802006f8:	9902                	jalr	s2
            break;
    802006fa:	bfb9                	j	80200658 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802006fc:	4705                	li	a4,1
    802006fe:	008a8993          	addi	s3,s5,8
    80200702:	01074463          	blt	a4,a6,8020070a <vprintfmt+0xec>
    else if (lflag) {
    80200706:	22080463          	beqz	a6,8020092e <vprintfmt+0x310>
        return va_arg(*ap, long);
    8020070a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    8020070e:	24044463          	bltz	s0,80200956 <vprintfmt+0x338>
            num = getint(&ap, lflag);
    80200712:	8622                	mv	a2,s0
    80200714:	8ace                	mv	s5,s3
    80200716:	46a9                	li	a3,10
    80200718:	a89d                	j	8020078e <vprintfmt+0x170>
            err = va_arg(ap, int);
    8020071a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020071e:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200720:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200722:	41f7d69b          	sraiw	a3,a5,0x1f
    80200726:	8fb5                	xor	a5,a5,a3
    80200728:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020072c:	1ad74363          	blt	a4,a3,802008d2 <vprintfmt+0x2b4>
    80200730:	00369793          	slli	a5,a3,0x3
    80200734:	97e2                	add	a5,a5,s8
    80200736:	639c                	ld	a5,0(a5)
    80200738:	18078d63          	beqz	a5,802008d2 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    8020073c:	86be                	mv	a3,a5
    8020073e:	00001617          	auipc	a2,0x1
    80200742:	b0260613          	addi	a2,a2,-1278 # 80201240 <error_string+0xe8>
    80200746:	85a6                	mv	a1,s1
    80200748:	854a                	mv	a0,s2
    8020074a:	240000ef          	jal	ra,8020098a <printfmt>
    8020074e:	b729                	j	80200658 <vprintfmt+0x3a>
            lflag ++;
    80200750:	00144603          	lbu	a2,1(s0)
    80200754:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200756:	846a                	mv	s0,s10
            goto reswitch;
    80200758:	bf3d                	j	80200696 <vprintfmt+0x78>
    if (lflag >= 2) {
    8020075a:	4705                	li	a4,1
    8020075c:	008a8593          	addi	a1,s5,8
    80200760:	01074463          	blt	a4,a6,80200768 <vprintfmt+0x14a>
    else if (lflag) {
    80200764:	1e080263          	beqz	a6,80200948 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    80200768:	000ab603          	ld	a2,0(s5)
    8020076c:	46a1                	li	a3,8
    8020076e:	8aae                	mv	s5,a1
    80200770:	a839                	j	8020078e <vprintfmt+0x170>
            putch('0', putdat);
    80200772:	03000513          	li	a0,48
    80200776:	85a6                	mv	a1,s1
    80200778:	e03e                	sd	a5,0(sp)
    8020077a:	9902                	jalr	s2
            putch('x', putdat);
    8020077c:	85a6                	mv	a1,s1
    8020077e:	07800513          	li	a0,120
    80200782:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200784:	0aa1                	addi	s5,s5,8
    80200786:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    8020078a:	6782                	ld	a5,0(sp)
    8020078c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    8020078e:	876e                	mv	a4,s11
    80200790:	85a6                	mv	a1,s1
    80200792:	854a                	mv	a0,s2
    80200794:	e1fff0ef          	jal	ra,802005b2 <printnum>
            break;
    80200798:	b5c1                	j	80200658 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020079a:	000ab603          	ld	a2,0(s5)
    8020079e:	0aa1                	addi	s5,s5,8
    802007a0:	1c060663          	beqz	a2,8020096c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007a4:	00160413          	addi	s0,a2,1
    802007a8:	17b05c63          	blez	s11,80200920 <vprintfmt+0x302>
    802007ac:	02d00593          	li	a1,45
    802007b0:	14b79263          	bne	a5,a1,802008f4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007b4:	00064783          	lbu	a5,0(a2)
    802007b8:	0007851b          	sext.w	a0,a5
    802007bc:	c905                	beqz	a0,802007ec <vprintfmt+0x1ce>
    802007be:	000cc563          	bltz	s9,802007c8 <vprintfmt+0x1aa>
    802007c2:	3cfd                	addiw	s9,s9,-1
    802007c4:	036c8263          	beq	s9,s6,802007e8 <vprintfmt+0x1ca>
                    putch('?', putdat);
    802007c8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007ca:	18098463          	beqz	s3,80200952 <vprintfmt+0x334>
    802007ce:	3781                	addiw	a5,a5,-32
    802007d0:	18fbf163          	bleu	a5,s7,80200952 <vprintfmt+0x334>
                    putch('?', putdat);
    802007d4:	03f00513          	li	a0,63
    802007d8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007da:	0405                	addi	s0,s0,1
    802007dc:	fff44783          	lbu	a5,-1(s0)
    802007e0:	3dfd                	addiw	s11,s11,-1
    802007e2:	0007851b          	sext.w	a0,a5
    802007e6:	fd61                	bnez	a0,802007be <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    802007e8:	e7b058e3          	blez	s11,80200658 <vprintfmt+0x3a>
    802007ec:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007ee:	85a6                	mv	a1,s1
    802007f0:	02000513          	li	a0,32
    802007f4:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007f6:	e60d81e3          	beqz	s11,80200658 <vprintfmt+0x3a>
    802007fa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007fc:	85a6                	mv	a1,s1
    802007fe:	02000513          	li	a0,32
    80200802:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200804:	fe0d94e3          	bnez	s11,802007ec <vprintfmt+0x1ce>
    80200808:	bd81                	j	80200658 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020080a:	4705                	li	a4,1
    8020080c:	008a8593          	addi	a1,s5,8
    80200810:	01074463          	blt	a4,a6,80200818 <vprintfmt+0x1fa>
    else if (lflag) {
    80200814:	12080063          	beqz	a6,80200934 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200818:	000ab603          	ld	a2,0(s5)
    8020081c:	46a9                	li	a3,10
    8020081e:	8aae                	mv	s5,a1
    80200820:	b7bd                	j	8020078e <vprintfmt+0x170>
    80200822:	00144603          	lbu	a2,1(s0)
            padc = '-';
    80200826:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    8020082a:	846a                	mv	s0,s10
    8020082c:	b5ad                	j	80200696 <vprintfmt+0x78>
            putch(ch, putdat);
    8020082e:	85a6                	mv	a1,s1
    80200830:	02500513          	li	a0,37
    80200834:	9902                	jalr	s2
            break;
    80200836:	b50d                	j	80200658 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200838:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    8020083c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200840:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200842:	846a                	mv	s0,s10
            if (width < 0)
    80200844:	e40dd9e3          	bgez	s11,80200696 <vprintfmt+0x78>
                width = precision, precision = -1;
    80200848:	8de6                	mv	s11,s9
    8020084a:	5cfd                	li	s9,-1
    8020084c:	b5a9                	j	80200696 <vprintfmt+0x78>
            goto reswitch;
    8020084e:	00144603          	lbu	a2,1(s0)
            padc = '0';
    80200852:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    80200856:	846a                	mv	s0,s10
            goto reswitch;
    80200858:	bd3d                	j	80200696 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    8020085a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020085e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200862:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200864:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200868:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020086c:	fcd56ce3          	bltu	a0,a3,80200844 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    80200870:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200872:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200876:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    8020087a:	0196873b          	addw	a4,a3,s9
    8020087e:	0017171b          	slliw	a4,a4,0x1
    80200882:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200886:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    8020088a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020088e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200892:	fcd57fe3          	bleu	a3,a0,80200870 <vprintfmt+0x252>
    80200896:	b77d                	j	80200844 <vprintfmt+0x226>
            if (width < 0)
    80200898:	fffdc693          	not	a3,s11
    8020089c:	96fd                	srai	a3,a3,0x3f
    8020089e:	00ddfdb3          	and	s11,s11,a3
    802008a2:	00144603          	lbu	a2,1(s0)
    802008a6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008a8:	846a                	mv	s0,s10
    802008aa:	b3f5                	j	80200696 <vprintfmt+0x78>
            putch('%', putdat);
    802008ac:	85a6                	mv	a1,s1
    802008ae:	02500513          	li	a0,37
    802008b2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008b4:	fff44703          	lbu	a4,-1(s0)
    802008b8:	02500793          	li	a5,37
    802008bc:	8d22                	mv	s10,s0
    802008be:	d8f70de3          	beq	a4,a5,80200658 <vprintfmt+0x3a>
    802008c2:	02500713          	li	a4,37
    802008c6:	1d7d                	addi	s10,s10,-1
    802008c8:	fffd4783          	lbu	a5,-1(s10)
    802008cc:	fee79de3          	bne	a5,a4,802008c6 <vprintfmt+0x2a8>
    802008d0:	b361                	j	80200658 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008d2:	00001617          	auipc	a2,0x1
    802008d6:	95e60613          	addi	a2,a2,-1698 # 80201230 <error_string+0xd8>
    802008da:	85a6                	mv	a1,s1
    802008dc:	854a                	mv	a0,s2
    802008de:	0ac000ef          	jal	ra,8020098a <printfmt>
    802008e2:	bb9d                	j	80200658 <vprintfmt+0x3a>
                p = "(null)";
    802008e4:	00001617          	auipc	a2,0x1
    802008e8:	94460613          	addi	a2,a2,-1724 # 80201228 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008ec:	00001417          	auipc	s0,0x1
    802008f0:	93d40413          	addi	s0,s0,-1731 # 80201229 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f4:	8532                	mv	a0,a2
    802008f6:	85e6                	mv	a1,s9
    802008f8:	e032                	sd	a2,0(sp)
    802008fa:	e43e                	sd	a5,8(sp)
    802008fc:	102000ef          	jal	ra,802009fe <strnlen>
    80200900:	40ad8dbb          	subw	s11,s11,a0
    80200904:	6602                	ld	a2,0(sp)
    80200906:	01b05d63          	blez	s11,80200920 <vprintfmt+0x302>
    8020090a:	67a2                	ld	a5,8(sp)
    8020090c:	2781                	sext.w	a5,a5
    8020090e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200910:	6522                	ld	a0,8(sp)
    80200912:	85a6                	mv	a1,s1
    80200914:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200916:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200918:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020091a:	6602                	ld	a2,0(sp)
    8020091c:	fe0d9ae3          	bnez	s11,80200910 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200920:	00064783          	lbu	a5,0(a2)
    80200924:	0007851b          	sext.w	a0,a5
    80200928:	e8051be3          	bnez	a0,802007be <vprintfmt+0x1a0>
    8020092c:	b335                	j	80200658 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    8020092e:	000aa403          	lw	s0,0(s5)
    80200932:	bbf1                	j	8020070e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    80200934:	000ae603          	lwu	a2,0(s5)
    80200938:	46a9                	li	a3,10
    8020093a:	8aae                	mv	s5,a1
    8020093c:	bd89                	j	8020078e <vprintfmt+0x170>
    8020093e:	000ae603          	lwu	a2,0(s5)
    80200942:	46c1                	li	a3,16
    80200944:	8aae                	mv	s5,a1
    80200946:	b5a1                	j	8020078e <vprintfmt+0x170>
    80200948:	000ae603          	lwu	a2,0(s5)
    8020094c:	46a1                	li	a3,8
    8020094e:	8aae                	mv	s5,a1
    80200950:	bd3d                	j	8020078e <vprintfmt+0x170>
                    putch(ch, putdat);
    80200952:	9902                	jalr	s2
    80200954:	b559                	j	802007da <vprintfmt+0x1bc>
                putch('-', putdat);
    80200956:	85a6                	mv	a1,s1
    80200958:	02d00513          	li	a0,45
    8020095c:	e03e                	sd	a5,0(sp)
    8020095e:	9902                	jalr	s2
                num = -(long long)num;
    80200960:	8ace                	mv	s5,s3
    80200962:	40800633          	neg	a2,s0
    80200966:	46a9                	li	a3,10
    80200968:	6782                	ld	a5,0(sp)
    8020096a:	b515                	j	8020078e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    8020096c:	01b05663          	blez	s11,80200978 <vprintfmt+0x35a>
    80200970:	02d00693          	li	a3,45
    80200974:	f6d798e3          	bne	a5,a3,802008e4 <vprintfmt+0x2c6>
    80200978:	00001417          	auipc	s0,0x1
    8020097c:	8b140413          	addi	s0,s0,-1871 # 80201229 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200980:	02800513          	li	a0,40
    80200984:	02800793          	li	a5,40
    80200988:	bd1d                	j	802007be <vprintfmt+0x1a0>

000000008020098a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020098a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    8020098c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200990:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200992:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200994:	ec06                	sd	ra,24(sp)
    80200996:	f83a                	sd	a4,48(sp)
    80200998:	fc3e                	sd	a5,56(sp)
    8020099a:	e0c2                	sd	a6,64(sp)
    8020099c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020099e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a0:	c7fff0ef          	jal	ra,8020061e <vprintfmt>
}
    802009a4:	60e2                	ld	ra,24(sp)
    802009a6:	6161                	addi	sp,sp,80
    802009a8:	8082                	ret

00000000802009aa <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009aa:	00003797          	auipc	a5,0x3
    802009ae:	65678793          	addi	a5,a5,1622 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009b2:	6398                	ld	a4,0(a5)
    802009b4:	4781                	li	a5,0
    802009b6:	88ba                	mv	a7,a4
    802009b8:	852a                	mv	a0,a0
    802009ba:	85be                	mv	a1,a5
    802009bc:	863e                	mv	a2,a5
    802009be:	00000073          	ecall
    802009c2:	87aa                	mv	a5,a0
}
    802009c4:	8082                	ret

00000000802009c6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009c6:	00003797          	auipc	a5,0x3
    802009ca:	65278793          	addi	a5,a5,1618 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009ce:	6398                	ld	a4,0(a5)
    802009d0:	4781                	li	a5,0
    802009d2:	88ba                	mv	a7,a4
    802009d4:	852a                	mv	a0,a0
    802009d6:	85be                	mv	a1,a5
    802009d8:	863e                	mv	a2,a5
    802009da:	00000073          	ecall
    802009de:	87aa                	mv	a5,a0
}
    802009e0:	8082                	ret

00000000802009e2 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009e2:	00003797          	auipc	a5,0x3
    802009e6:	62678793          	addi	a5,a5,1574 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009ea:	6398                	ld	a4,0(a5)
    802009ec:	4781                	li	a5,0
    802009ee:	88ba                	mv	a7,a4
    802009f0:	853e                	mv	a0,a5
    802009f2:	85be                	mv	a1,a5
    802009f4:	863e                	mv	a2,a5
    802009f6:	00000073          	ecall
    802009fa:	87aa                	mv	a5,a0
    802009fc:	8082                	ret

00000000802009fe <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009fe:	c185                	beqz	a1,80200a1e <strnlen+0x20>
    80200a00:	00054783          	lbu	a5,0(a0)
    80200a04:	cf89                	beqz	a5,80200a1e <strnlen+0x20>
    size_t cnt = 0;
    80200a06:	4781                	li	a5,0
    80200a08:	a021                	j	80200a10 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a0a:	00074703          	lbu	a4,0(a4)
    80200a0e:	c711                	beqz	a4,80200a1a <strnlen+0x1c>
        cnt ++;
    80200a10:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a12:	00f50733          	add	a4,a0,a5
    80200a16:	fef59ae3          	bne	a1,a5,80200a0a <strnlen+0xc>
    }
    return cnt;
}
    80200a1a:	853e                	mv	a0,a5
    80200a1c:	8082                	ret
    size_t cnt = 0;
    80200a1e:	4781                	li	a5,0
}
    80200a20:	853e                	mv	a0,a5
    80200a22:	8082                	ret

0000000080200a24 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a24:	ca01                	beqz	a2,80200a34 <memset+0x10>
    80200a26:	962a                	add	a2,a2,a0
    char *p = s;
    80200a28:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a2a:	0785                	addi	a5,a5,1
    80200a2c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a30:	fec79de3          	bne	a5,a2,80200a2a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a34:	8082                	ret
