LipoToolchainInfo = provider(
    doc = "Lipo toolchain rule parameters",
    fields = {
        "path": "Path to the lipo executable (from host XCode)",
    },
)

def _lipo_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        lipo = LipoToolchainInfo(
            path = ctx.attr.path,
        ),
    )
    return [toolchain_info]

lipo_toolchain = rule(
    implementation = _lipo_toolchain_impl,
    attrs = {
        "path": attr.string(),
    },
)

# Expose the presence of a LIPO command in the resolved toolchain as a flag.
def _is_lipo_available_impl(ctx):
    toolchain = ctx.toolchains["//toolchains/lipo:toolchain_type"].lipo
    return [config_common.FeatureFlagInfo(
        value = ("1" if bool(toolchain.path) else "0"),
    )]

is_lipo_available = rule(
    implementation = _is_lipo_available_impl,
    attrs = {},
    toolchains = ["//toolchains/lipo:toolchain_type"],
)

def lipo_register_toolchains():
    native.register_toolchains("//toolchains/lipo:lipo_missing_toolchain")
