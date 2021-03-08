# the rule seems to have problems taking part the toolchain.  Use this for now.
#
# When you can't dance with whom you want to, dance with the girl that's there and enjoy yourself
#
# Example:
#
# lipo_create (
#     srcs = [ "@baselisk_darwin_amd64//file", "@baselisk_darwin_arm64//file" ],
#     out = "bazelisk",
# )

# simple two-level flatten to allow dumping in arrays as elements of the array
def flatten(a):
    r = []
    for i in a:
        r.extend(i)  # append() appends single-elements; extend() appends each element of a list
    return r

# bazel_12614_compatible_helper is https://github.com/bazelbuild/bazel/issues/12614#issuecomment-739105799
# which discusses a somewhat reverse selector as a helper: if the desired condition is present in
# the current config, then the empty-set is returned, suggesting the depenency is compatible with
# all targets; conversely, if that desired setting is not true, then the `select` falls-through to
# the default, which returns a value for which nothing is compatible.
#
# Used with a `target_compatible_with` would cause the rule to be effective only when the desired
# setting is active.
def bazel_12614_compatible_helper(config_target):
    return select({
        config_target: [],
        "//conditions:default": ["@platforms//:incompatible"],
    })

# This would be more awesome if we had a toolchain for the lipo, even if initially that's "detect
# from environment like a savage"
def lipo_create(srcs, out, name = None, visibility = ["//visibility:public"]):
    native.genrule(
        name = name or "{}.lipo".format(out),
        srcs = srcs,
        outs = [out],
        cmd = "lipo -create {} -output $@".format(" ".join(
            ["$(locations {})".format(s) for s in srcs],
        )),
        target_compatible_with = bazel_12614_compatible_helper("//toolchains/lipo:have_lipo"),
        visibility = visibility,
    )

# Check that the generated binary detects as including the desired architectures.  More useful
# during development but offers peace-of-mind as well to detect human error during maintenance.
#
# yep, a rule "lipo_check" and a default name "lipo_test".

def lipo_check(binary, archs = ["x86_64", "arm64"], name = "lipo_test", visibility = ["//visibility:public"]):
    native.sh_test(
        args = flatten([["-a", a] for a in archs] + [["-b", "$(location {})".format(binary)]]),
        data = [binary],
        name = name,
        size = "small",
        srcs = ["//lib:lipo_verify_arch_wrapper.sh"],
        visibility = visibility,
    )
