# Basic script; in future, I intend to use a github action script itself as the single place for
# config info, so let's set defaults from a sample config.  This helps show what an intended
# functional example should look like as well as confirm that the intended config works.  I know I
# have some issue trying to assume where some brief snippet of config sits in the exosystem -- "Oh
# just use a parrot section" (now where's a 'Parrot Section'?) -- so I hope to at least give one
# explicit complete example.

# import json
#
# default = json.loads(
#    """
# name: Generate SemVer Tag
# on:
#  push:
#    branches: [$default-branch]
#  # Allows you to run this workflow manually from the Actions tab
#  workflow_dispatch:
## Allow one concurrent deployment
# concurrency:
#  group: "semver"
#  cancel-in-progress: true
# jobs:
#  generate-semver:
#    runs-on: ubuntu-latest
#    steps:
#    - uses: actions/checkout@v3
#      with:
#        fetch-depth: 0
#    - name: Python-3.8
#      uses: actions/setup-python@v2
#      with:
#        python-version: 3.8
#    - run: python -c .github/auto-semver.py
#      with:
#        ACCESS_TOKEN: ${{secrets.GITHUB_TOKEN}}
#        COST: 'feat:MINOR,fix:POINT,docs:POINT,doc:POINT,refactor:MAJOR,perf:MINOR,chore:POINT'
# """
# )

from collections import OrderedDict
from git import Repo
import argparse
import logging
import os

weights = {"MAJOR": 1000 * 1000, "MINOR": 1000, "PATCH": 1, "POINT": 1}
weights_c = {k.lower(): v for k, v in weights.items()}


def commit_cost(lines: list) -> int:
    total = 0
    prefixes = {
        "chore": "POINT",
        "doc": "POINT",
        "docs": "POINT",
        "feat": "MINOR",
        "fix": "POINT",
        "perf": "MINOR",
        "refactor": "MAJOR",
    }

    print(f"total of {len(lines)} lines read")
    for l in lines:
        term = l.split(":")
        if term:
            found = term[0]
            logging.debug(f"1 {l} gave me {term} which offers {found}")
            term = found.split("(")
            found = term[0]
            logging.debug(f"2 {l} gave me {term} which offers {found}")
            if found in prefixes:
                pre = prefixes[found]
                logging.debug("gave a cost of {}".format(pre))
                if pre in weights:
                    logging.debug("gave a real cost of {}".format(weights[pre]))
                    total += weights[pre]
    return total


class ParseThresholds(argparse.Action):
    def __call__(
        self,
        parser: argparse.ArgumentParser,
        namespace: argparse.Namespace,
        values: list,
        option_string=None,
    ):
        setattr(namespace, self.dest, [])
        thresh = getattr(namespace, self.dest)

        if type(values) == str:
            values = [values]
        for value in values:
            k, v = value.split("=")
            thresh.append((k, v))

        thresh = getattr(namespace, self.dest)


def semver_to_int(version: str) -> int:
    values = version.replace("v", "").split(".")
    return (
        weights_c["major"] * int(values[0])
        + weights_c["minor"] * int(values[1])
        + weights_c["patch"] * int(values[2])
    )


def int_to_semver(value: int) -> str:
    version = []
    for w, v in weights.items():
        version.append(str(int(value / v)))
        value = value - (int(value / v) * v)

    version.append("0")
    version.append("0")
    version.append("0")

    return "v" + ".".join(version[:3])


def threshold_weights(thresholds: list) -> OrderedDict:
    retdict = OrderedDict()
    for n in thresholds:  # [ (weight, major/minor/patch), ...]
        retdict[semver_to_int(n[1])] = n[0]

    logging.debug(f"thresholds are {retdict}")
    return retdict


def conditional_release(weights: OrderedDict, current_carry: int, release_stdout: bool):
    for t, v in weights.items():
        logging.debug(f"checking {current_carry} against {t}")
        if current_carry > t:
            logging.warning(
                f"would release as '{v}' because carry of {current_carry} greater than {t}"
            )
            if release_stdout:
                return v
    return None


def main():
    parser = argparse.ArgumentParser(description="Filter git commit messages")
    parser.add_argument(
        "--debug",
        type=bool,
        required=False,
        default=False,
        action=argparse.BooleanOptionalAction,
        help="display additional debug chatter",
    )
    parser.add_argument(
        "--dryrun",
        type=bool,
        required=False,
        default=False,
        action=argparse.BooleanOptionalAction,
        help="avoid making any changes"
    )

    parser.add_argument(
        "-P",
        "--repo_path",
        metavar="REPO_PATH",
        type=str,
        required=False,
        default=os.environ.get('RUNNER_WORKSPACE'),
        help="the path to the local git repository",
    )

    parser.add_argument(
        "--autotag_threshold",
        nargs="*",
        default=[("major", "1.0.0"), ("minor", "0.0.1")],
        action=ParseThresholds,
    )
    parser.add_argument(
        "--autotag_release",
        type=bool,
        required=False,
        default=False,
        action=argparse.BooleanOptionalAction,
        help="auto-tag new release if exceeding threshold",
    )

    args = parser.parse_args()
    print(f"running arguments are {args}")

    logging.basicConfig(
        datefmt="%Y-%m-%d %H:%M:%S",
        encoding="utf-8",
        format="%(asctime)s - %(levelname)-09s - %(message)s",
        level=logging.ERROR
        if args.autotag_release
        else logging.DEBUG
        if args.debug
        else logging.WARNING,
    )

    repo = Repo(args.repo_path)
    max_tag = 0
    max_tagname = "845f7f2a06ee0df32eaf2f9efbbeb3d747c28e68"
    print(f"starting with max_tag = {max_tag}, max_tagname = {max_tagname}, and {repo.tags} tags ({len(repo.tags)}) to dig through")
    for t in repo.tags:
        print(f"tag: {t}")
        newmax = semver_to_int(str(t))
        print(f"compare current max tag {max_tag} ({max_tagname}) to new {t} ({newmax})")
        if newmax > max_tag:
            max_tag = newmax
            max_tagname = str(t)

    print(f"max tagname is {max_tagname}")
    current_carry = commit_cost(
        [
            commit.message.lower()
            for commit in repo.iter_commits(max_tagname+"..HEAD")
        ]
    )
    logging.debug(f"total cost: {current_carry}")

    release = conditional_release(
        threshold_weights(args.autotag_threshold), current_carry, args.autotag_release
    )
    if release:
        # print(f"Updating {max_tag} per {release}")
        new_tag = (
            max_tag
            - (max_tag % weights_c[release.lower()])
            + weights_c[release.lower()]
        )
        ## print(f"Updating {max_tag} to {new_tag} per {release}")
        new_version = int_to_semver(new_tag)
        if not args.dryrun:
            repo.create_tag(
                new_version,  # new version as v-prefixed dotted-semver
                ref="HEAD",
                message="Backlog sufficient to post automatic release",
            )
            print(f"Tagged {new_version} per {release}")
            repo.remote().push(new_version)
            print(f"Pushed {new_version} to {repo.remote.origin}")
        else:
            print(f"Skipped (dryrun) tagging {new_version} per {release}")
            print(f"Skipped (dryrun) pushing {new_version} to {[x for x in repo.remote().urls][0]}")
    elif args.autotag_release:
        print("found insufficient commit charge worth releasing")


if __name__ == "__main__":
    main()
