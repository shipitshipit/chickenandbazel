#!/bin/bash

# Wrapper only so that the bazel `sh_test()` can run using this script.  I'd rather use a genrule()
# but bazel doesn't recommend use of genrule() for unittests.

usage() { echo "Usage: $0 [-a <arm64|ppc|x86_64>] [-b <string>]" 1>&2; exit 1; }

binaries=""
archs=""

while getopts ":a:b:" o; do
    case "${o}" in
        a)
            a=${OPTARG}
            ((a == arm64 || a == ppc || a == x86_64 )) || usage
            archs="${archs} ${a}"
            ;;
        b)
            binaries="${binaries} ${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${archs}" ] || [ -z "${binaries}" ]; then
    usage
fi

echo "archs = ${archs}"
echo "binaries = ${binaries}"

exec lipo ${binaries} -verify_arch ${archs}
