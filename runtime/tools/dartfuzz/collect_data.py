#!/usr/bin/env python3
# Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#
"""Webscraper for make_a_fuzz nightly cluster run results.

Given the uri of a make_a_fuzz run, this script will first
extract the links pointing to each of the individual shards
and then parse the output generated by each shard to
find divergences reported by the dartfuzz_test.dart program,
concatenate all output, or summarize all test results.

Example:
  collect_data.py --type sum
      https://ci.chromium.org/p/dart/builders/ci.sandbox/fuzz-linux/303
"""

# This script may require a one time install of BeautifulSoup:
# sudo apt-get install python3-bs4

import argparse
import re
import sys

from bs4 import BeautifulSoup

import requests


# Matches shard raw stdout to extract divergence reports.
P_DIV = re.compile("(Isolate.+? !DIVERGENCE! (\n|.)+?)Isolate ", re.MULTILINE)

# Matches shard raw stdout to extract report summaries.
P_SUM = re.compile(r"^Tests: (\d+) Success: (\d+) Not-Run: (\d+): "
                   r"Time-Out: (\d+) Divergences: (\d+)$", re.MULTILINE)

# Matches uri to extract shard number.
P_SHARD = re.compile(r".*make_a_fuzz_shard_(\d+)")


def get_shard_links(uri):
  links = []
  resp = requests.get(uri)
  soup = BeautifulSoup(resp.text, "html.parser")
  for a in soup.findAll("a"):
    if a.text == "raw":
      href = a["href"]
      if ("make_a_fuzz_shard" in href and
          "__trigger__" not in href):
        links.append(href)
  return links


def print_reencoded(text):
  # Re-encoding avoids breaking some terminals.
  print(text.encode("ascii", errors="ignore").decode("unicode-escape"))


def print_output_all(text):
  print_reencoded(text)


def print_output_div(shard, text):
  sys.stderr.write("Shard: " + shard + "  \r")
  m = P_DIV.findall(text)
  if m:
    print("Shard: " + shard)
    for x in m:
      print_reencoded(x[0])


def print_output_sum(shard, text, s=[0, 0, 0, 0, 0], divs=[]):
  m = P_SUM.findall(text)
  if not m:
    sys.stderr.write("Failed to parse shard %s stdout for summary" % shard)
    return
  for test in m:
    if int(test[-1]) == 1:
      divs.append(shard)
    for i in range(len(s)):
      s[i] += int(test[i])
  print("Tests: %d Success: %d Not-Run: %d Time-Out: %d Divergences: %d "
        "(failing shards: %s)    \r"
        % tuple(s + [", ".join(divs) if divs else "none"]), end="")


def get_stats(uri, output_type):
  resp = requests.get(uri)

  if output_type == "all":
    print_output_all(resp.text)
  elif output_type == "div":
    shard = P_SHARD.findall(uri)[0]
    print_output_div(shard, resp.text)
  elif output_type == "sum":
    shard = P_SHARD.findall(uri)[0]
    print_output_sum(shard, resp.text)


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument(
      "--type",
      choices=("div", "sum", "all"),
      required=True,
      help="Select output type (div: divergence report, sum: summary, all: complete stdout)"
  )
  parser.add_argument(
      "uri",
      type=str,
      help="Uri of one make_a_fuzz run from https://ci.chromium.org/p/dart/builders/ci.sandbox/fuzz-linux."
  )
  args = parser.parse_args()
  shard_links = get_shard_links(args.uri)
  for link in shard_links:
    get_stats(link, args.type)
  print("")


if __name__ == "__main__":
  main()