# Downloadable pre-built toolchains

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//toolchains/ibazel:name-version-sha.bzl", "preferred_release")

def deps():
    """
    Convenience array/list of `http_file` definitions suitable for import into a WORKSPACE file but
    allows changes to the list of arch binaries to be self-contained in the toolchain dir.  Basing
    on the name-version-sha file, we keep those versions DRY and somewhat consistent despite the
    competing intentions of release-managers for each project.

    Returns a list of http_file similar to ("bazel query //...:all" to check):

    http_file(
        name = "ibazel-darwin-amd64",

        executable = True,
        sha256 = "...",
        urls = [ "..." ],
    )

    http_file(
        name = "ibazel-darwin-arm64",
        ...
    )
    """

    p = preferred_release()
    for a in p:
        name = a.replace("-", "_")  # "_" is a bit more palatable than "-" to python-like languages
        http_file(name = name, urls = [p[a]["url"]], sha256 = p[a]["sha256"], executable = True)
