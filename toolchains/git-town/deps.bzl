# Downloadable pre-built toolchains

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":name-version-sha.bzl", "preferred_release")

def deps():
    """
    Convenience array/list of `http_archive` definitions suitable for a WORKSPACE but allows
    changes to the list of arch binaries to be self-contained in the toolchain dir.

    Returns a list of http_archive similar to:

    http_archive(
        name = "git_town_darwin_amd64",

        sha256 = "...",
        urls = [ "..." ],
    )

    http_archive(
        name = "git_town_darwin_arm64",
        ...
    )
    """

    p = preferred_release()
    for a in p:
        name = a.replace("-", "_")
        http_archive(name = name, build_file_content = "exports_files(['git-town'])", urls = [p[a]["url"]], sha256 = p[a]["sha256"])
