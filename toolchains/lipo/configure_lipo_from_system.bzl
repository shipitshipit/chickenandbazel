# A function to find the `lipo` executable in the local system, and when found, write a BUILD file representing it as a toolchain

def _write_build(ctx, path):
    if not path:
        path = ""
    ctx.template(
        "BUILD",
        Label("//toolchains/lipo:BUILD.tpl"),
        substitutions = {
            "{GENERATOR}": "//toolchains/lipo/configure_lipo_from_system.bzl%find_system_lipo",
            "{LIPO_PATH}": str(path),
        },
        executable = False,
    )

# use the system "where" to find the local `lipo`, writing whatever results (path or "") to the
# hydrated template
def _find_system_lipo_impl(ctx):
    lipo_path = ctx.which("lipo")
    if ctx.attr.verbose:
        if lipo_path:
            print("Found lipo at '%s'" % lipo_path)
        else:
            print("No system lipo found.")
    _write_build(ctx = ctx, path = lipo_path)

# This _find_system_lipo, as a repository_rule, will run during collection of dependencies
_find_system_lipo = repository_rule(
    implementation = _find_system_lipo_impl,
    doc = "Create a virtual external repository that contains a single BUILD file that defines the toolchain providing lipo executable based on system discovery",
    local = True,
    environ = ["PATH"],  # WARNING, cached result will flex with PATH changes
    attrs = {
        "verbose": attr.bool(
            doc = "Provide additional verbose output if set",
        ),
    },
)

# actually find the system lipo, and register the "not found" toolchain as a fallback.  The
# `reponame` here becomes the name of the external virtual repo (default: "system_lipo")
def find_system_lipo(reponame = "system_lipo", verbose = True):
    _find_system_lipo(name = reponame, verbose = verbose)
    native.register_toolchains("@%s//:lipo_auto_toolchain" % reponame, "//toolchains/lipo:lipo_missing_toolchain")
