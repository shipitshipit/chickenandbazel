#
# MacOS Packaging logic
#
# This is intended as the first step in comprehensive package build on MacOS.  It replaces the
# following sytle of command:
#
#     pkgbuild \
#         --identifier (domain).$(PKG_NAME) \
#         --component-plist $(PLIST) \
#         --scripts $(SCRIPTS) \
#         --version $(VER_BAZELISK) \
#         --root $(STAGE)  \
#     $(DESTDIR)/$(PKG_UPPERNAME)-$(VER_BAZELISK).pkg:
#
# Identifiers refs:
#   - https://en.wikipedia.org/wiki/Uniform_Type_Identifier
#   - https://en.wikipedia.org/wiki/Reverse_domain_name_notation
#
# As with the command it replaces, this isintended to be installable in a simple CLI such as:
#
#     sudo installer -pkg bazel-out/darwin-fastbuild/bin/chickenandbazel.pkg -target /

def _pkgbuild_tars_impl(ctx):
    """Completes a "pkgbuild --root" but pre-deployed the "tars" to that given "root".
    Args:
        name: A unique name for this rule.
        component_plist: location of a plist file.
        identifier: an Apple UTI -- ie Reverse-DNS Notation name for the package: Defaults to
            com.example.{name} but watch for the expected namespace/name clash this default
            can cause.
        package_name: (optional) Target package name, defaulting to (name).pkg.
        tars: One or more tar archives representing deliverables that should be extracted in "root"
            before packaging.
        version: a version string for the package; recommending Semver for simplicity.  Comparing
            two versions of matching identifier can be used to determine whether one package
            upgrades or downgrades another.
    """

    component_plist_opt = ""
    if ctx.attr.component_plist:
        component_plist_opt = "--component-plist \"{}\"".format(ctx.file.component_plist)

    identifier = ctx.attr.identifier or "com.example.{}".format(ctx.attr.name)
    package_name = ctx.attr.package_name or "{}.pkg".format(ctx.attr.name)
    pkg = ctx.actions.declare_file(package_name)
    inputs = [] + ctx.files.tars  # TODO: plus pkgbuild, plus template, plus plist

    #pkgbuild_toolchain = ctx.toolchains["@rules_pkg//toolchains/macos:pkgbuild_toolchain_type"].pkgbuild.path

    # Generate a script from hdyrating a template so that we can review the script to diagnose/debug
    script_file = ctx.actions.declare_file("{}_pkgbuild".format(ctx.label.name))
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = script_file,
        is_executable = True,
        substitutions = {
            "{IDENTIFIER}": identifier,
            "{OPT_COMPONENT_PLIST}": component_plist_opt,
            "{OPT_SCRIPTS_DIR}": "",
            "{OUTPUT}": pkg.path,
            #"{PKGBUILD}": pkgbuild_toolchain,
            "{TARS}": " ".join([f.path for f in ctx.files.tars]),
            "{VERSION}": ctx.attr.version,
        },
    )

    ctx.actions.run(
        inputs = inputs,
        outputs = [pkg],
        arguments = [],
        executable = script_file,
        execution_requirements = {
            "local": "1",
            "no-remote": "1",
            "no-remote-exec": "1",
        },
    )

    return [
        DefaultInfo(
            files = depset([pkg]),
        ),
    ]

pkgbuild_tars = rule(
    implementation = _pkgbuild_tars_impl,
    attrs = {
        "component_plist": attr.label(allow_files = True, mandatory = False),
        "identifier": attr.string(
            mandatory = False,
            doc = "An Apple Uniform Type Identifier (similar to a Reverse-DNS Notation) as a unique identifier for this package",
        ),
        "package_name": attr.string(
            mandatory = False,
            doc = "resulting filename.pkg, defaults to (name).pkg, analogous to the 'package-output-path'",
        ),
        "tars": attr.label_list(
            #allow_files = True,
            mandatory = True,
            doc = "One or more tar archives that should be extracted in 'root' before packaging",
        ),
        "version": attr.string(
            mandatory = True,
            default = "0",
            doc = "A version for the package; used to compare against different versions of the 'identifier' to see whether this upgrades or downgrades an existing install",
        ),
        "_script_template": attr.label(
            allow_single_file = True,
            default = ":pkgbuild_tars.sh.tpl",
        ),
    },
    doc = "Package a complete destination root.  For example, the 'xcodebuild' tool with the 'install' action creates a destination root.  This rule is intended to package up a destination root that would be given as 'pkgbuild --root' except that it wants to lay out the given 'tars' into that 'root' before packaging",
)

# NOTES
#
# full paths?  https://github.com/bazelbuild/rules_python/blob/main/python/defs.bzl#L76
