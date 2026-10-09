# parseElfhdr.sh - Parses the ELF header
#
# Copyright (c) 2026 Luiz Antônio Rangel (takusuman)
#
# SPDX-License-Identifier: MIT

. ./ELFconsts.shi

# This clears a number output per od(1).
cleanUBase10() {
	n_imp="$1"
	n1="1$n_imp"
	n2="2$n_imp"
	unset n_imp
	# The idea was from Greg's Wiki, but
	# the principle is quite simple:
	# first, you make your 10^d + n and
	# 2(10^d) + n and, then, you take
	# the difference amid 2*(10^d + n) and
	# 2(10^d) + n, which will be the n
	# value. This method works solely with
	# unsigned integers.
	n=$(( 2*n1 - n2 ))
	echo $((n))
}

# This reads and parses some information from an ELF header.
# #define EI_NIDENT 16
# typedef struct {
# 	unsigned char e_ident[EI_NIDENT];
#  	Elf{32,64}_Half    e_type;
#  	Elf{32,64}_Half    e_machine;
#  	Elf{32,64}_Word    e_version;
#  	Elf{32,64}_Addr    e_entry;
#  	Elf{32,64}_Off     e_phoff;
#  	Elf{32,64}_Off     e_shoff;
#  	Elf{32,64}_Word    e_flags;
#  	Elf{32,64}_Half    e_ehsize;
#  	Elf{32,64}_Half    e_phentsize;
#  	Elf{32,64}_Half    e_phnum;
#  	Elf{32,64}_Half    e_shentsize;
#  	Elf{32,64}_Half    e_shnum;
#  	Elf{32,64}_Half    e_shstrndx;
# } Elf{32,64}_Ehdr;
# Elf32_Half: 2
# Elf64_Half: 2
# Elf32_Word: 4
# Elf32_Sword: 4
# Elf64_Word: 4
# Elf64_Sword: 4
# Elf32_Xword: 8
# Elf32_Sxword: 8
# Elf64_Xword: 8
# Elf64_Sxword: 8
# Elf32_Addr: 4
# Elf64_Addr: 8
# Elf32_Off: 4
# Elf64_Off: 8
# Elf32_Section: 2
# Elf64_Section: 2
# Elf32_Versym: 2
# Elf64_Versym: 2
parse_Elfhdr() {
	lib="$1"
	e_indent="$(od -An -t c -N16 "$lib")"
	e_type="$(cleanUBase10 $(od -An -t u2 -j16 -N2 "$lib"))"
	# We could just use file(1), but, since
	# the ELF header already has an entry
	# for the archicture, it'd be better to
	# parse it straight away.
	e_machine="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2)) -N 2 "$lib"))"
	e_version="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2)) -N 4 "$lib"))"
	case "$e_machine" in
		$EM_386|$EM_ARM)
		# 20 + 20 + 20 + 7
		e_entry="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4)) -N 4 "$lib"))"
		e_phoff="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 2*4)) -N 4 "$lib"))"
		e_shoff="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 3*4)) -N 4 "$lib"))"
		e_flags="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4*4)) -N 4 "$lib"))"
		e_ehsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4)) -N 2 "$lib"))"
		e_phentsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 2)) -N 2 "$lib"))"
		e_phnum="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 2*2)) -N 2 "$lib"))"
		e_shentsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 3*2)) -N 2 "$lib"))"
		e_shnum="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 4*2)) -N 2 "$lib"))"
		e_shstrndx="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 5*2)) -N 2 "$lib"))"
		;;
		$EM_X86_64|$EM_AARCH64)
		e_entry="$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4)) -N 8 "$lib"))"
		e_phoff="$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4 + 8)) -N 8 "$lib"))"
		e_shoff="$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4 + 2*8)) -N 8 "$lib"))"
		e_flags="$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4 + 3*8)) -N 4 "$lib"))"
		e_ehsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4)) -N 2 "$lib"))"
		e_phentsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 2)) -N 2 "$lib"))"
		e_phnum="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 2*2)) -N 2 "$lib"))"
		e_shentsize="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 3*2)) -N 2 "$lib"))"
		e_shnum="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 4*2)) -N 2 "$lib"))"
		e_shstrndx="$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 5*2)) -N 2 "$lib"))"
		;;
	esac
}

parse_Elfhdr "$@"
