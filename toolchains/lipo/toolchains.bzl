# Downloadable pre-built toolchains

load(":toolchain.bzl", "lipo_toolchain")

#load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//toolchains/lipo:http_files.bzl", bnt = "NAME_TOOL")

def toolchains():
    # bnt[0] -- ie latest -- works out to:
    # { platformcode: { url, sha256 } } such that NAME_TOOLE[0].keys() == [ "lipo-darwin-amd64", "lipo-darwin-arm64" ]
    for a in bnt[0]:
        #TODO: clean #print(a)
        #TODO: clean #print(bnt[0][a])

        name = a.replace("-", "_")

        lipo_toolchain(name = name, path = "@{}//file".format(name), visibility = ["//visibility:public"])
