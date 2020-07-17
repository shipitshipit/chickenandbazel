# chickenandbazel

A Quick packaging of the Bazel-related build resources


## Why?

This is intended to do the simplest packaging of some tools so that users don't need to worry about
where to get things.  Yeah, I want to have the number of steps to be as close to zero as possible.


## No, no.  Why "Chicken and Bazel"?

Because Basil Chicken sounds delicious?  Maybe a bit of lemon.

Includes the unique spelling of "bazel"?

Subtle vanity?  "Chicken And ..." seems to be my go-to.

That's all I got.


## What steps?

1. install ChickenAndBazel.pkg by:
    1. double-clicking on a Mac, or
    2. sudo installer -pkg ChickenAndBazel.pkg -verbose -target /
2. "bazel" and "ibazel" are now on your PATH (if /usr/local/bin is on your PATH)
3. be aware that "ibazel" is not graceful if there's no WORKSPACE file in your work dir


## Software License

This repository is under Apache-2.0 license because:
 - bazelisk is an Apache-2.0 -licensed repository
 - ibazel is an Apache-2.0 -licensed repository

All this stuff is someone else's work.  I'm effectively making a tarball, and nothing more.
