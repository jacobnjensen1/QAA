#!/usr/bin/env python

import argparse

def get_args():
  parser = argparse.ArgumentParser(description="A program to summarize read alignment")
  parser.add_argument("-s", "--samfile", help="samfile from aligner", required=True)
  return parser.parse_args()

args = get_args()

mappedPrimary = 0
unmappedPrimary = 0
mappedSecondary = 0
unmappedSecondary = 0

with open(args.samfile, 'r') as inFile:
  for line in inFile:
    if not line.startswith("@"):
      line = line.strip().split("\t")
      flag = int(line[1])
      unmappedBool = True #True if unmapped
      secondaryBool = True #True if it is not the primary alignment
      if (flag & 256) != 256: #if entry IS a primary alignment
        secondaryBool = False
      if (flag & 4) != 4: #if entry IS mapped
        unmappedBool = False
      
      if not secondaryBool and unmappedBool:
        unmappedPrimary += 1
      elif secondaryBool and unmappedBool:
        unmappedSecondary += 1
      elif not secondaryBool and not unmappedBool:
        mappedPrimary += 1
      else:
        mappedSecondary += 1
      
print(f"Primary alignment: mapped: {mappedPrimary}, unmapped: {unmappedPrimary}")
