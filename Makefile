
# default values for testing, you likely wanna set this.
CHALLENGE ?= TEMPLATE-EXPLOIT
KERNEL ?= linux/arch/x86/boot/bzImage
RELEASE ?= el6

all: boot $(CHALLENGE)/reproducer

$(CHALLENGE)/reproducer:
	$(MAKE) -C $(CHALLENGE)

.PHONY: initramfs-busybox-x64.cpio.gz

initramfs-busybox-x64.cpio.gz: $(CHALLENGE)/reproducer
	cp $(CHALLENGE)/reproducer initramfs/tmp/reproducer
	cd initramfs ; find . -print0 |\
		cpio --null -ov --format=newc |\
		gzip --fast > ../initramfs-busybox-x64.cpio.gz

boot: initramfs-busybox-x64.cpio.gz $(CHALLENGE)
	qemu-system-x86_64 \
		-smp 4 \
		-kernel $(KERNEL) \
		-initrd initramfs-busybox-x64.cpio.gz \
		-nographic \
	 	-append console=ttyS0
		
clean:
	$(MAKE) -C $(CHALLENGE) clean
	$(RM) initramfs-busybox-x64.cpio.gz
	$(RM) initramfs/tmp/*



