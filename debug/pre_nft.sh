. ./debug/pre_nft/invite_all.sh
. ./debug/pre_nft/answer_invite_all.sh
. ./debug/pre_nft/remove_all.sh
echo "Added some test here to verify FAIL TEST"

. ./debug/pre_nft/invite_admin.sh $ADMIN
. ./debug/pre_nft/invite_agent.sh $AGENT $AGENT2

. ./debug/pre_nft/answer_invite_admin.sh admin true $ADMIN
. ./debug/pre_nft/answer_invite_agent.sh agent true $AGENT
. ./debug/pre_nft/answer_invite_agent.sh agent2 true $AGENT2
. ./debug/pre_nft/invite_creator.sh $CREATOR $CREATOR2

. ./debug/pre_nft/answer_invite_creator.sh creator true $CREATOR
. ./debug/pre_nft/answer_invite_creator.sh creator2 true $CREATOR2

. ./debug/pre_nft/submit_nft.sh
. ./debug/pre_nft/remove_metadata.sh creator 3
. ./debug/pre_nft/approve_nft.sh 4 
. ./debug/pre_nft/royalty.sh
. ./debug/pre_nft/change_copyright.sh 5
. ./debug/view_basic_data.sh
