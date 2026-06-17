#!/usr/bin/env bash
#
# Use .ninja_log from a build directory to produce a flamegraph
# of the durations. Any filenams in .ninja_log that start with the
# absolute path have it stripped.
set -eu

if [ $# != 1 ]; then
	echo "Usage $1: <path to .ninja_log>"
	exit 1;
fi

ninja_log=$(realpath $1)
build_dir="$(dirname $ninja_log)/"

# This is what the output from Zeek looks:
#
#     3250054 3256381 1781697878961461133     /home/awelzel/devel/zeek/xbuild/src/analyzer/protocol/quic/quic_QUIC.cc 6a6e68c89f6c0c00
#     3250054 3256381 1781697878961461133     /home/awelzel/devel/zeek/xbuild/src/analyzer/protocol/quic/quic_spicy_hooks_QUIC.cc     6a6e68c89f6c0c00
#     3256381 3258885 1781697881666496871     src/analyzer/protocol/quic/CMakeFiles/spicy_QUIC.dir/quic___linker__.cc.o       ad3cdf73da48a5ea
#     3258885 3265375 1781697888152582537     src/analyzer/protocol/quic/CMakeFiles/spicy_QUIC.dir/quic_spicy_init.cc.o       5648fd8637bd5326
#
# Mixes absolute and relative directories, adn some files are created with the same command (the hash column is identical).

exec awk -v build_dir=$build_dir '$1 !~ /^#/ {
	duration = $2 - $1
	file = $4
	hash = $5;
	# Make file relative if it starts
	# with the absolute build directory.
	sub("^" build_dir, "", file);

	# If the command/hash is already in files, use the basename
	# of the next file and add it with a "," separator. Hopefully
	# this ends-up nice. It works for Zeek/Spicy parser generators
	# fairly well (BinPAC, Spicy).
	if ( hash in files ) {
		n = split($4, parts, "/")
		basename = parts[n]
		files[hash] = files[hash] "," basename;
	} else {
		files[hash] = file;
	}

	durations[hash] += duration;
} END {
	for (hash in files) {
		duration = durations[hash];
		file_str=files[hash];
		gsub("/", ";", file_str)
		print file_str, duration;
	}
}' $ninja_log
