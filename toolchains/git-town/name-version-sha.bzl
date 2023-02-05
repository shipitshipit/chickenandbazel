# Written this way so that the most recent release used is at the top, but allows for a history to
# be retained, parsed, etc in case reverting to a previous release is necessary
NAME_SHA_BY_VERSION = {
    # yup, a multi-arch at https://github.com/bazelbuild/bazelisk/releases/download/v1.11.0/bazelisk-darwin.
    # I started by using this for testing, so it's no big deal to leave this in here now as a pair
    # of binaries to lipo together.
    "7.9.0": {
        "git-town-darwin-amd64": {
            "sha256": "02a2991081d685fa669ae509987ec40c9d350bd637a39d850e04b9d42fd46fba",
            "url": "https://github.com/git-town/git-town/releases/download/v7.9.0/git-town_7.9.0_macos_intel_64.tar.gz",
        },
        "git-town-darwin-arm64": {
            "sha256": "cc0c1e0c62d00582f130f52a02899e27cba8213257bbd8760272476004c0254d",
            "url": "https://github.com/git-town/git-town/releases/download/v7.9.0/git-town_7.9.0_macos_arm_64.tar.gz",
        },
    },
}

def preferred_release():
    """
    Returns a dict similar to:

    { git-town-darwin-amd64": { "url": "...", "sha256": "..." },
      git-town-darwin-arm64": { "url": "...", "sha256": "..." },
    }
    """

    # first set revision set listed - I could use NAME_SHA_BY_VERSION["7.9.0"] as well
    return NAME_SHA_BY_VERSION[NAME_SHA_BY_VERSION.keys()[0]]

def preferred_release_version():
    return NAME_SHA_BY_VERSION.keys()[0]

def binaries():
    """
    Convenience array/list to allow changes to the list of releases to be fairly DRY and self-contained.
    Returns a list/array to simply send to a lipo() call similar to

    [ "@git_town_darwin_amd64@//git-town", "@git_town_darwin_arm64//git-town" ]
    """

    # NOTE: ":git-town" corresponds with http_archive, not with http_file
    return ["@{}//:git-town".format(a.replace("-", "_")) for a in preferred_release()]
