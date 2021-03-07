# Downloadable pre-built toolchains

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//toolchains/lipo:http_files.bzl", bnt = "NAME_TOOL")

def deps():
    # bnt[0] -- ie latest -- works out to:
    # { platformcode: { url, sha256 } } such that NAME_TOOLE[0].keys() == [ "lipo-darwin-amd64", "lipo-darwin-arm64" ]
    for a in bnt[0]:
        #TODO: clean #print(a)
        #TODO: clean #print(bnt[0][a])
        name = a.replace("-", "_")

        http_file(name = name, urls = [bnt[0][a]["url"]], sha256 = bnt[0][a]["sha256"], executable = True)
