# get_mids.sh

CURRENT_BLOCK=$(flow blocks get latest -o json | jq -c ' .height')
echo $(flow events get A.fd43f9148d4b725d.DAAM.AddMetadata --start 1 --end $CURRENT_BLOCK -o json | jq -c ' .[] | .values | .value | .fields | .[] | .value')