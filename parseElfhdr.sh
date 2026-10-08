# parseElfhdr.sh - Parses the ELF header
#
# Copyright (c) 2026 Luiz Antônio Rangel (takusuman)
#
# SPDX-License-Identifier: MIT

. ./EMconsts.shi

# This clears a number output per od(1).
cleanUBase10() {
	n_ent="$1"
	# Trim every space before the number.
	n_imp="${n_ent## }"
	n1="1$n_imp"
	n2="2$n_imp"
	unset n_ent n-imp
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
parse_Elfhdr() {
	lib="$1"
	e_indent="$(od -An -t c -N16 "$lib")"
	# We could just use file(1), but, since
	# the ELF header already has an entry
	# for the archicture, it'd be better to
	# parse it straight away.
	e_machine="$(od -An -t u2 -j$((16 + 2)) -N 2 "$lib")"
	case "$(cleanUBase10 $e_machine)" in
		$EM_386) echo 'i386' ;;
		$EM_X86_64) echo 'x86_64' ;;
	esac

}

parse_Elfhdr "$@"
