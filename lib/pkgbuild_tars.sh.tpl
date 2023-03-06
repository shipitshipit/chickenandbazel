#!/bin/bash

# pkgbuild_tars.sh is intended to cerate a flat-package -style pkg by extracting a number of
# tarchives to a "root" area, then packaging that up with a "pkgbuild --root ..." command.  This
# isn't overyl complex, but can be convenient.
#
# This process does not build nor merge code into multi-arch binaries; you'll need to do that
# before putting them into the listed tars.  Additionally, I haven't addressed code-signing, but
# IIUC the individual binaries should be signed before adding into tarchives.  While at Snap (2020),
# I found that this sort of unsigned flat-pack caused additional confirmation steps during install.
# I expect that experience will olny get worse.
#
# It is anticipated that non "-root" packaging will be done, so I've named this one
# "pkgbuild_tars.sh" to allow the non-tars-based packaging to be easily identified as well.

TMPDIR=`mktemp -d -t pkgbuild` || { echo "$0: Cannot create working (root) directory; aborting"; exit 1; }

eval $(cat /dev/null {STATUS_FILE_STABLE} {STATUS_FILE_VOLATILE} | grep ^VERSION | sed -e 's/ v/=/g')

# extract all tarchives to the designated root
for t in {TARS} ; do
       tar -C "${TMPDIR}" -xf ${t}
done

# really should have pkgbuild coming in as a toolchain from the installed Xcode

/usr/bin/pkgbuild \
    --identifier "{IDENTIFIER}" \
    {OPT_COMPONENT_PLIST} \
    {OPT_SCRIPTS_DIR} \
    --version "${VERSION:-{ATTR_VERSION}}" \
    --root "${TMPDIR}" \
    "{OUTPUT}"
