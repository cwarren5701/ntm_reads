#!/usr/bin/env python3
# PROGRAM: Mash_contamination_checker is a Python3 program that ranks protein sequences in a genome
# faa file generated from annotation programs based on the number of observed
# exact protein matches in a public or private database.

# Copyright (C) 2019 Ahmed M. Moustafa

#########################################################################################
# LICENSE
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################

# DATE CREATED: April 13, 2020

# AUTHOR: Ahmed M Moustafa

# CONTACT1: moustafaam@email.chop.edu
# CONTACT2: ahmedmagdy2009@hotmail.com

# AFFILIATION: Pediatric Infectious Disease Division, Children’s Hospital of Philadelphia,
# Abramson Pediatric Research Center, University of Pennsylvania, Philadelphia,
# Pennsylvania, 19104, USA

import os
import sys
import time
import argparse

PARSER = argparse.ArgumentParser(
    prog="Mash_contamination_checker.py",
    description="Mash_contamination_checker v1.0 will process Mash reports and report pass or\
    or fail value for contamination for each Mash report. I prefer to use\
    the winning all option of mash if you just want to look at contamination.",
)
PARSER.add_argument(
    "-i",
    "--identity",
    type=float,
    nargs="?",
    help="select a mash identity cutoff value [0.85], range(0,1)",
)
PARSER.add_argument(
    "-s",
    "--shared_hash",
    type=int,
    nargs="?",
    help="select a shared hash cutoff value [100], range(1,1000)",
)
PARSER.add_argument(
    "--exclude_names_file", type=str, help="text file where each line is a sketch name to be excluded from 'fails'"
)
PARSER.add_argument(
    "-p",
    "--prefix",
    type=str,
    help="prefix name for output file",
)
PARSER.add_argument(
    "genus_species",
    type=str,
    nargs='+',
    help="Genus or Species of interest",
)
PARSER.add_argument(
    "mash_reports", type=str, help="mash report/s to analyze, you can also provide a folder"
)


if len(sys.argv) == 1:
    PARSER.print_help()
    sys.exit(0)
ARGS = PARSER.parse_args()
OS_SEPARATOR = os.sep
############################
if ARGS.identity:
    IDENTITY_CUTOFF = ARGS.identity
else:
    IDENTITY_CUTOFF = 0.85
if ARGS.shared_hash:
    SHARED_HASH_CUTOFF = ARGS.shared_hash
else:
    SHARED_HASH_CUTOFF = 100
if ARGS.exclude_names_file:
    excludednamesfile=(open(ARGS.exclude_names_file, "r")).readlines()
    ExcludedNamesList = list(map(str.strip, excludednamesfile))
Genus_species = ' '.join(ARGS.genus_species)
#####Mash files to be processed######
MASH_REPORTS = ARGS.mash_reports
MASH_LIST = []
try:
    for file in os.listdir(MASH_REPORTS):
        if file.endswith(".tab"):
            MASH_LIST.append(MASH_REPORTS + file)
    print(
        "You provided folder of {} mash reports".format(len(MASH_LIST))
    )
    if len(MASH_LIST) == 0:
        PARSER.exit(
            status=0,
            message="The directory did not have any Mash reports\n",
        )
except:
    MASH_LIST.append(MASH_REPORTS)
    print("You provided one Mash report")
#############################
cwd = os.getcwd()
TIMESTR = time.strftime("%m%d%Y_%H%M")
if ARGS.prefix:
    file_report = ARGS.prefix + '.txt'
else:
    Name_Time = 'Mash_contamination_report_{}.txt'.format(TIMESTR)
    file_report = os.path.join(cwd, Name_Time)
output_file = open(file_report, "w")
output_file.write("File\tConclusion\tHits Failing cutoffs\tPassed hits\tPhage hits\tContaminants hits\tContamination\n")
#############################
for MASH_REPORT in MASH_LIST:
    MASH_REPORT_OBJECT = open(MASH_REPORT, "r")
    FILE_NAME = MASH_REPORT.rsplit(OS_SEPARATOR, 1)[-1]
    #line_check = MASH_REPORT_OBJECT.readline()
    #if '/1000' not in line_check:
    #    PARSER.exit(status=0, message="Does not look like a Mash report\n")
    #MASH_REPORT_OBJECT.seek(0)
    Phage_counter = 0
    Failed_counter = 0
    Pass_counter = 0
    ExcludedNames_counter=0
    cutoffs_counter = 0
    PASS_LIST = []
    Failed_list = []
    for line in MASH_REPORT_OBJECT:
        line = line.rstrip()
        line_info = line.split("\t")
        if (float(line_info[0]) >= IDENTITY_CUTOFF) and (int(line_info[1].split('/')[0]) >= SHARED_HASH_CUTOFF):
            if Genus_species in line:
                Pass_counter += 1
                PASS_Value = "Pass"
            elif ("phage" in line) or ("prophage" in line):
                Phage_counter += 1
            elif  (str(line_info[4]) in ExcludedNamesList):
                ExcludedNames_counter +=1
            else:
                Failed_counter += 1
                Failed_list.append(line.replace('\t',' '))
        else:
            cutoffs_counter += 1
    PASS_LIST.append(Pass_counter)
    PASS_LIST.append(Phage_counter)
    PASS_LIST.append(Failed_counter)
    if PASS_LIST[2] == 0:
        output_file.write('{}\tPassed\t{}\t{}\t{}\t{}\tNA\n'.format(
            FILE_NAME,cutoffs_counter,PASS_LIST[0],PASS_LIST[1],PASS_LIST[2]))
    else:
        output_file.write('{}\tFailed\t{}\t{}\t{}\t{}\t{}\n'.format(
            FILE_NAME,cutoffs_counter,PASS_LIST[0],PASS_LIST[1],PASS_LIST[2],'._/'.join(Failed_list)))
    MASH_REPORT_OBJECT.close()
output_file.close()
