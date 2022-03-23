. ./debug/pre_nft/invite_all.sh
. ./debug/pre_nft/answer_invite_all.sh
. ./debug/pre_nft/remove_all.sh
echo "Added some test here to verify FAIL TEST"
. ./debug/pre_nft/invite_all.sh
. ./debug/pre_nft/answer_invite_all.sh
. ./debug/pre_nft/submit_nft.sh
. ./debug/pre_nft/remove_metadata.sh creator 3
# . ./debug/pre_nft/approve_nft.sh 4 # TODO TURN OFF FOR DEVELOPEMT
. ./debug/pre_nft/royality.sh
. ./debug/pre_nft/change_copyright.sh 5
. ./debug/view_basic_data.sh
