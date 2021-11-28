. ./debug/pre_nft/invite_all.sh
. ./debug/pre_nft/answer_invite_all.sh
. ./debug/pre_nft/remove_all.sh
echo "Added some test here to verify FAIL TEST"
. ./debug/pre_nft/invite_all.sh
. ./debug/pre_nft/answer_invite_all.sh
. ./debug/pre_nft/submit_nft.sh
. ./debug/pre_nft/remove_metadata.sh $CREATOR 3 # Creator
. ./debug/pre_nft/approve_nft.sh 4
. ./debug/pre_nft/change_copyright.sh
. ./debug/pre_nft/view_basic_data.sh
