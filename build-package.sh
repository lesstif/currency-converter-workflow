#!/usr/bin/env bash

OUTFILE="CurrencyConverter.alfredworkflow"

if [ -f "${OUTFILE}" ]; then
    rm "${OUTFILE}"
fi

cd Workflow && zip -r "../${OUTFILE}" . --exclude "*/.DS_Store"