# Written this way os that the most recent release used is at the top, but allows for a history to
# be retained, parsed, etc in case reverting to a pervious release is necessary.  I've only rarely
# needed to revert like this but it does happen on occiason.
NAME_SHA_BY_VERSION = {
    # yup, a multi-arch at https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-darwin
    "0.16.2": {
        "ibazel-darwin-amd64": {
            "sha256": "be81d0a19804bfbe571d562ef5ad53dc28b6ab1c920d150e5b8d48042cf919a8",
            "url": "https://github.com/bazelbuild/bazel-watcher/releases/download/v0.16.2/ibazel_darwin_amd64",
        },
        "ibazel-darwin-arm64": {
            "sha256": "030977738556032866a3f840dbb7bb4e4fd00a42b2761ebde038b7b56989ed48",
            "url": "https://github.com/bazelbuild/bazel-watcher/releases/download/v0.16.2/ibazel_darwin_arm64",
        },
    },
}

def preferred_release():
    """
    Returns a dict similar to:

    { ibazel-darwin-amd64": { "url": "...", "sha256": "..." },
      ibazel-darwin-arm64": { "url": "...", "sha256": "..." },
    }
    """

    # first set revision set listed - I could use NAME_SHA_BY_VERSION["0.16.2"] as well
    return NAME_SHA_BY_VERSION[NAME_SHA_BY_VERSION.keys()[0]]

def preferred_release_version():
    return NAME_SHA_BY_VERSION.keys()[0]

def binaries():
    """
    Convenience array/list to allow changes to the list of releases to be fairly DRY and self-contained.
    Returns a list/array to simply send to a lipo() call similar to

    [ "@ibazel_darwin_amd64@//file", "@ibazel_darwin_arm64//file" ]
    """

    return ["@{}//file".format(a.replace("-", "_")) for a in preferred_release()]
