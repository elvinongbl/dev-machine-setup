#!/bin/bash
#
# This script is run to either setup the GOLD version or to rollback to the GOLD
# version and delete the test-version that does not boot-up

# Tally with network-script/setup-global.sh
GOLDVER_FILE="/home/root/.goldversion"
TESTVER_FILE="/home/root/.testversion"

if [ -a $GOLDVER_FILE ]; then
	GOLDVER=$(cat $GOLDVER_FILE)
else
	GOLDVER="UNKNOWN"
fi

if [ -a $TESTVER_FILE ]; then
	TESTVER=$(cat $TESTVER_FILE)
else
	TESTVER="UNKNOWN"
fi

function remove_nonboot_kernel() {
	local RM_VER=$1
	rm /boot/bzImage-kernel

	if [ x"${RM_VER}" != x"UNKNOWN" ]; then
		rm /boot/config-${RM_VER}
		rm /boot/System.map-${RM_VER}
		# rm /boot/Module.symvers-${RM_VER}
		rm -rf /lib/modules/${RM_VER}
	fi
}

# If test Linux fail to boot, we edit at GRUB to use GOLD-bzImage-kernel to
# rescue the plaform.
IS_RESCUE=$(dmesg | grep GOLD-bzImage-kernel -c)

if [ x"$IS_RESCUE" != x"0" ]; then
	# if GOLDVER is already in place, we continue to revert the
	# previous non-boot kernel ingredient
	if [ x"$TESTVER" != x"UNKNOWN" ]; then
		remove_nonboot_kernel $TESTVER
	fi

	# Restore to use Gold version of bzImage-kernel
	cp /boot/GOLD-bzImage-kernel /boot/bzImage-kernel
	# cp /boot/GOLD-Module.symvers-$GOLDVER /boot/Module.symvers-$GOLDVER
	cp /boot/GOLD-System.map-$GOLDVER /boot/System.map-$GOLDVER
	cp /boot/GOLD-config-$GOLDVER /boot/config-$GOLDVER

	# Restore to use Gold version of kmod
	GOLDKMOD=$(ls /lib/modules/ -1 | grep GOLD-)
	RESCKMOD=$(echo $GOLDKMOD | sed -e "s#GOLD-##g")
	echo -e "RESCURE image (Gold version) loaded. KMOD Gold=$GOLDKMOD --> Rescue=$RESCKMOD"
	cp -rf /lib/modules/$GOLDKMOD /lib/modules/$RESCKMOD

	# Trigger reboot now
	echo -e "Reboot with GOLD's version bzImage-kernel and KMOD"
	reboot
else
	# If not booting using GOLD-bzImage-kernel, we check if we already
	# has GOLD version

	# Get the currently booting version which has potential to be GOLD.
	BOOTVER=$(uname -r)
	if [ x"$GOLDVER" != x"UNKNOWN" ]; then
		# GOLDVER is already before, we should use it as BOOTVER
		# instead of keeping using the latest and greatest for GOLD
		BOOTVER=$GOLDVER
	fi

	# Check if GOLD-bzImage-kernel is available at /boot
	if [ -a /boot/GOLD-bzImage-kernel ]; then
		echo "Found: /boot/GOLD-bzImage-kernel. Skip making GOLD version"
	else
		echo "Create: /boot/GOLD-bzImage-kernel ($BOOTVER)"
		cp /boot/bzImage-kernel /boot/GOLD-bzImage-kernel
	fi

	# Check if GOLD-Module.symvers-$GOLDVER is available at /boot
	#if [ -a /boot/GOLD-Module.symvers-$GOLDVER ]; then
	#	echo "Found: /boot/GOLD-Module.symvers-$GOLDVER"
	#else
	#	echo "Make: /boot/GOLD-Module.symvers-$BOOTVER"
	#	cp /boot/Module.symvers-$BOOTVER /boot/GOLD-Module.symvers-$BOOTVER
	#fi

	if [ -a /boot/GOLD-System.map-$GOLDVER ]; then
		echo "Found: /boot/GOLD-System.map-$GOLDVER"
	else
		echo "Make: /boot/GOLD-System.map-$BOOTVER"
		cp /boot/System.map-$BOOTVER /boot/GOLD-System.map-$BOOTVER
	fi

	if [ -a /boot/GOLD-config-$GOLDVER ]; then
		echo "Found: /boot/GOLD-config-$GOLDVER"
	else
		echo "Make: /boot/GOLD-config-$BOOTVER"
		cp /boot/config-$BOOTVER /boot/GOLD-config-$BOOTVER
	fi

	if [ -d /lib/modules/GOLD-$GOLDVER ]; then
		echo "Found: /lib/modules/GOLD-$GOLDVER"
	else
		echo "Make: /lib/modules/GOLD-$BOOTVER"
		cp -rf /lib/modules/$BOOTVER /lib/modules/GOLD-$BOOTVER
		# Also back-up one version under ~/
		cp -rf /lib/modules/$BOOTVER ~/GOLD-$BOOTVER
		echo "$BOOTVER" > ${GOLDVER_FILE}
	fi
fi
