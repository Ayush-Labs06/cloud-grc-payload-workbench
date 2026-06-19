#!/bin/bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
printf 'usage: %s <evidence_dir> <artifact_dir> <environments>\n' "$0" >&2
exit 1
fi

EVIDENCE_DIR="$1"
ARTIFACT_DIR="$2"
ENVIRONMENT="$3"
 
# Verifying Sample Evidence Files
for file in checkov-findings.txt identity.txt metadata.env opa-findings.txt secrets-scan.txt terraform-plan.txt; do
[[ -s "$EVIDENCE_DIR/$file" ]] || {
   echo "$file missing"
   exit 1
}
done
echo "All evidence files exist"

# ----------------------      ----------------------

# output folder
if [[ ! -d "output" ]]; then
mkdir output
cd output/
touch summary.txt failed-controls.txt pipeline.log metadata-normalizaton.txt
cd ..
else
echo "output folder exist" > output/pipeline.log
fi

# scanning logic
scan=$(cat $EVIDENCE_DIR/secrets-scan.txt)

if [[ "$scan" == "PASSED" ]]
then
echo "scan was succesfull" >> output/pipeline.log
else
echo "scan was failed" >> output/pipeline.log
exit 1
fi

# environment validation
ENVIRONMENT=$(grep "^env=" metadata.env | cut -d'=' -f2)

if [[ "$ENVIRONMENT" == "prod" || "$ENVIRONMENT" == "dev" || "$ENVIRONMENT" == "staging" ]]; then
echo "valid env - $ENVIRONMENT" >> output/pipeline.log
else
echo "invalid environment" >> output/pipeline.log
exit 1
fi

# 5 : For HIGH severity, pipeline fails
#ARTIFACT_DIR=$(cat sample-evidence/opa-findings.txt)

#if grep -q 'HIGH' "$ARTIFACT_DIR"
#then
#echo "HIGH severity finding" >> output/pipeline.log
#else
#echo "No HIGH severity detected" >> output/pipeline.log
#exit 1
#fi

# Medium severity
#if ! grep -q 'HIGH' "$ARTIFACT_DIR" && grep -q 'MEDIUM' "$ARTIFACT_DIR"
#then
#echo "No HIGH severity finding" >> output/pipeline.log && "Medium severity finding" >> output/pipeline.log
#elif grep -q 'LOW' "$ARTIFACT_DIR"
#then
#echo "Low severity detected" >> output/pipeline.log
#exit 1
#fi
