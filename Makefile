export CROSS_COMPILE=/home/gaju/workspace/day1/arm-gnu-toolchain-13.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

ARCH=arm64

lnx:
	$(MAKE) -C linux defconfig
	$(MAKE) -C linux -j 12
	cp config-buildroot/.config buildroot
	$(MAKE) -C buildroot imx8mqevk_defconfig

build:	uuu

uuu:	packaging
	cd /home/gaju/workspace/day1/imx-mkimage/iMX8M
	sudo uuu -b spl flash.bin



mkimage: uboot
	$(MAKE) -C imx-mkimage SOC=iMX8M dtbs=imx8mq-pico-pi.dtb flash_evk

%/:
	@mkdir -p $@

atf: | out/
	$(MAKE) -C imx-atf-lf_v2.6 PLAT=imx8mq SPD=none
	cp /home/gaju/workspace/day1/imx-atf-lf_v2.6/build/imx8mq/release/bl31.bin  out

uboot:	atf
	cp -f config-uboot/.config u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable/
	$(MAKE) -C u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable

uboot-clear: atf-clear
	$(MAKE) -C u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable clean

clear:	uboot-clear
	@echo "cleared"

atf-clear:	package-clear
	$(MAKE) -C imx-atf-lf_v2.6 PLAT=imx8mq distclean

package: mkimage
	echo "making a package"

packaging: mkimage
	cp -f /home/gaju/workspace/day1/u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable/tools/mkimage package
	cp -f /home/gaju/workspace/day1/firmware-imx-8.22/firmware/ddr/synopsys/lpddr4_pmu_train_1d_dmem.bin package
	cp -f /home/gaju/workspace/day1/firmware-imx-8.22/firmware/ddr/synopsys/lpddr4_pmu_train_1d_imem.bin package
	cp -f /home/gaju/workspace/day1/firmware-imx-8.22/firmware/ddr/synopsys/lpddr4_pmu_train_2d_dmem.bin package
	cp -f /home/gaju/workspace/day1/firmware-imx-8.22/firmware/ddr/synopsys/lpddr4_pmu_train_2d_imem.bin package
	cp -f /home/gaju/workspace/day1/firmware-imx-8.22/firmware/hdmi/cadence/signed_hdmi_imx8m.bin package
	cp -f /home/gaju/workspace/day1/u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable/spl/u-boot-spl.bin package
	cp -f /home/gaju/workspace/day1/u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable/u-boot-nodtb.bin  package
	cp -f /home/gaju/workspace/day1/u-boot-tn-imx-tn-imx_v2023.04_6.1.55_2.2.0-stable/arch/arm/dts/imx8mq-pico-pi.dtb package
	cp -f /home/gaju/workspace/day1/out/bl31.bin package
	mv package/mkimage package/mkimage_uboot
	cp -f /home/gaju/workspace/day1/package/* /home/gaju/workspace/day1/imx-mkimage/iMX8M

package-clear:
	rm -rf package/*
	rm -f imx-mkimage/iMX8M/flash.bin
	@echo "aici"
