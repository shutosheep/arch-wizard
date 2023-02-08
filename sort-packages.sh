#!/bin/sh

title="$(head -n 1 packages.csv)"
echo -e "$title\n$(grep -v $title packages.csv | sort)" > packages.csv
