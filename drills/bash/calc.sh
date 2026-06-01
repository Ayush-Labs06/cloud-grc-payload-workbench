#!/bin/bash

severity="high"

case "$severity" in

low)
echo "upload artifacts to s3" ;;
medium)
echo "manualy approval gate + documentation" ;;
high)
echo "OPA gate will stop the pipeline, boto will auto remediate the chaanges with pager to concerned teams" ;;
*)
echo "unknown severity, treated as critical, kill the pipelline immedietyly"
esac