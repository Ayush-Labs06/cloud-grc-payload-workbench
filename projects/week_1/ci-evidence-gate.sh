#!/bin/bash

# 1 : output folder
if [[ ! -d "output" ]]; then
mkdir output
cd output/
touch summary.txt failed-controls.txt pipeline.log metadata-normalizaton.txt
cd ..
else
echo "output folder exist" > output/pipeline.log
fi

scan=$(cat secrets-scan.txt)

# 2 : Ensuring evidence file is not empty
evidence=("sample-evidence/opa-findings.txt" "sample-evidence/terraform-plan.txt")
for file in "${evidence[@]}"; do
if [ ! -s "$file" ]; then
echo "ERROR: $file is missing or empty" >> output/pipeline.log
exit 1
fi
done

# 3 : scanning logic

if [[ "$scan" == "PASSED" ]]
then
echo "scan was succesfull" >> output/pipeline.log
else
echo "scan was failed" >> output/pipeline.log
exit 1
fi

# 4 : environment validation
environment=$(grep "^env=" metadata.env | cut -d'=' -f2)

if [[ "$environment" == "prod" || "$environment" == "dev" || "$environment" == "staging" ]]; then
echo "valid env - $environment" >> output/pipeline.log
else
echo "invalid environment" >> output/pipeline.log
exit 1
fi

# 5 : For HIGH severity, pipeline fails
