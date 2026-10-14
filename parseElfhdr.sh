# parseElfhdr.sh - Parses the ELF header
#
# Copyright (c) 2026 Luiz Antônio Rangel (takusuman)
#
# SPDX-License-Identifier: MIT

. ./ELFconsts.shi

# This clears a number output per od(1).
cleanUBase10() {
	n_imp=$1
	n=$(( n_imp ))
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
	e_indent=$(od -An -t c -N16 "$lib")
	e_type=$(cleanUBase10 $(od -An -t u2 -j16 -N2 "$lib"))
	# We could just use file(1), but, since
	# the ELF header already has an entry
	# for the archicture, it'd be better to
	# parse it straight away.
	e_machine=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2)) -N2 "$lib"))
	e_version=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2)) -N4 "$lib"))
	case $e_machine in
		$EM_386|$EM_ARM)
			# 20 + 20 + 20 + 7
			e_entry=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4)) -N4 "$lib"))
			e_phoff=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 2*4)) -N4 "$lib"))
			e_shoff=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 3*4)) -N4 "$lib"))
			e_flags=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4*4)) -N4 "$lib"))
			e_ehsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4)) -N2 "$lib"))
			e_phentsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 2)) -N2 "$lib"))
			e_phnum=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 2*2)) -N2 "$lib"))
			e_shentsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 3*2)) -N2 "$lib"))
			e_shnum=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 4*2)) -N2 "$lib"))
			e_shstrndx=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 5*4 + 5*2)) -N2 "$lib"))
		;;
		$EM_X86_64|$EM_AARCH64)
			e_entry=$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4)) -N8 "$lib"))
			e_phoff=$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4 + 8)) -N8 "$lib"))
			e_shoff=$(cleanUBase10 $(od -An -t u8 -j$((16 + 2*2 + 4 + 2*8)) -N8 "$lib"))
			e_flags=$(cleanUBase10 $(od -An -t u4 -j$((16 + 2*2 + 4 + 3*8)) -N4 "$lib"))
			e_ehsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4)) -N2 "$lib"))
			e_phentsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 2)) -N2 "$lib"))
			e_phnum=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 2*2)) -N2 "$lib"))
			e_shentsize=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 3*2)) -N2 "$lib"))
			e_shnum=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 4*2)) -N2 "$lib"))
			e_shstrndx=$(cleanUBase10 $(od -An -t u2 -j$((16 + 2*2 + 4 + 3*8 + 4 + 5*2)) -N2 "$lib"))
		;;
	esac
	export e_machine e_shoff e_shnum e_shentsize
}

# typedef struct {
#  Elf{32,64}_Word	sh_name;
#  Elf{32,64}_Word	sh_type;
#  Elf32_Word|Elf64_Xword	sh_flags;
#  Elf{32,64}_Addr	sh_addr;
#  Elf{32,64}_Off	sh_offset;
#  Elf32_Word|Elf64_Xword	sh_size;
#  Elf{32,64}_Word	sh_link;
#  Elf{32,64}_Word	sh_info;
#  Elf32_Word|Elf64_Xword	sh_addralign;
#  Elf32_Word|Elf64_Xword	sh_entsize;
# } Elf{32,64}_Shdr;
getSONAME() {
	n=0
	pos=$e_shoff
	while [ $n -lt $e_shnum ]; do
		n=$(( n + 1 ))
		# Get the entire Shdr struct anyway.
		# Sure, it's slow since there's no buffering.
		# And, of course, we won't use all of these on practice.
		sh_name=$(cleanUBase10 $(od -An -t u4 -j$pos -N4 "$lib"))
		sh_type=$(cleanUBase10 $(od -An -t u4 -j$((pos + 4)) -N4 "$lib"))
		case $e_machine in
			$EM_386|$EM_ARM)
				sh_flags=$(cleanUBase10 $(od -An -t u4 -j$((pos + 2*4)) -N4 "$lib"))
				sh_addr=$(cleanUBase10 $(od -An -t u4 -j$((pos + 3*4)) -N4 "$lib"))
				sh_offset=$(cleanUBase10 $(od -An -t u4 -j$((pos + 4*4)) -N4 "$lib"))
				sh_size=$(cleanUBase10 $(od -An -t u4 -j$((pos + 5*4)) -N4 "$lib"))
				sh_link=$(cleanUBase10 $(od -An -t u4 -j$((pos + 6*4)) -N4 "$lib"))
				sh_info=$(cleanUBase10 $(od -An -t u4 -j$((pos + 7*4)) -N4 "$lib"))
				sh_addralign=$(cleanUBase10 $(od -An -t u4 -j$((pos + 8*4)) -N4 "$lib"))
				sh_entsize=$(cleanUBase10 $(od -An -t u4 -j$((pos + 9*4)) -N4 "$lib"))
			;;
			$EM_X86_64|$EM_AARCH64)
				sh_flags=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4)) -N8 "$lib"))
				sh_addr=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4 + 8)) -N8 "$lib"))
				sh_offset=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4 + 2*8)) -N8 "$lib"))
				sh_size=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4 + 3*8)) -N8 "$lib"))
				sh_link=$(cleanUBase10 $(od -An -t u4 -j$((pos + 2*4 + 4*8)) -N4 "$lib"))
				sh_info=$(cleanUBase10 $(od -An -t u4 -j$((pos + 2*4 + 4*8 + 4)) -N4 "$lib"))
				sh_addralign=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4 + 4*8 + 2*4)) -N8 "$lib"))
				sh_entsize=$(cleanUBase10 $(od -An -t u8 -j$((pos + 2*4 + 4*8 + 2*4 + 8)) -N8 "$lib"))
			;;
		esac
		case $sh_type in
			$SHT_DYNAMIC) echo BINGO!
			# typedef struct {
			# Elf32_Sword|Elf64_Sxword d_tag;
			#  union {
			#      Elf32_Word|Elf64_Xword d_val;
			#      Elf{32,64}_Addr d_ptr;
			#  } d_un;
			# } Elf{32,64}_Dyn;
			m=0
			pos2=$sh_offset
			while [ $m -lt $((sh_size/sh_entsize)) ]; do
				# Again, parse the entire struct.
				case $e_machine in
					$EM_386|$EM_ARM)
						dt_tag=$(cleanUBase10 $(od -An -t u4 -j$pos2 -N4 "$lib"))
						dt_val=$(cleanUBase10 $(od -An -t u4 -j$((pos2 + 4)) -N4 "$lib"))
						;;
					$EM_X86_64|$EM_AARCH64)
						dt_tag=$(cleanUBase10 $(od -An -t u8 -j$pos2 -N8 "$lib"))
						dt_val=$(cleanUBase10 $(od -An -t u8 -j$((pos2 + 8)) -N8 "$lib"))
						;;
				esac
				case $dt_tag in
					$DT_SONAME)
						break ;;
				esac
				pos2=$((pos2 + sh_entsize))
				m=$((m + 1))
			done
			# taks note: sh_link, in the context of SHT_DYNAMIC, means
			# that the header remits to a n-th section header table,
			# and that's why we have it times the sh_entsize plus
			# the e_shoff.
			dynstr_sh_pos=$((e_shoff + (sh_link * e_shentsize)))
			case $e_machine in
				$EM_386|$EM_ARM)
					dynstr_sh_offset=$(cleanUBase10 $(od -An -t u4 -j$((dynstr_sh_pos + 4*4)) -N4 "$lib"))
					;;
				$EM_X86_64|$EM_AARCH64)
					dynstr_sh_offset=$(cleanUBase10 $(od -An -t u8 -j$((dynstr_sh_pos + + 2*4 + 2*8)) -N8 "$lib"))
					;;
			esac
			SONAME_pos=$((dynstr_sh_offset + dt_val))
			SONAME="$(od -An -tc -j$SONAME_pos -N256 "$lib" | sed 's/ //g')"
			echo ${SONAME%%'\0'*}
			break ;;
			*) ;;
		esac
		pos=$((pos + e_shentsize))
	done
	echo $e_shoff $e_shnum $e_shentsize

}

parse_Elfhdr "$@"
getSONAME
