flow transactions send ./transactions/fusd/transfer_fusd.cdc 1.0 $PROFILE --signer cto # Dummy action to update flow

echo "---------- Testing Functions ----------"

getAddressName() {
    case $1 in

        $AGENCY)
        echo -n "Agency "
        ;;

        $ADMIN)
        echo -n "Admin "
        ;;
        
        $ADMIN2)
        echo -n "Admin2 "
        ;;
        
        $AGENT)
        echo -n "Agent "
        ;;
        
        $AGENT2)
        echo -n "Agent2 "
        ;;
        
        $CREATOR)
        echo -n "Creator "
        ;;
        
        $CREATOR2)
        echo -n "Creator2 "
        ;;
        
        $NOBODY)
        echo -n "Nobody "
        ;;
        
        $CTO)
        echo -n "CTO "
        ;;
        
        $CLIENT)
        echo -n "Client "
        ;;
        
        $CLIENT2)
        echo -n "Client2 "
        ;;
        
        *)
        echo -n "!!!!!!!!! RETURNED WRONG VALUE !!!!!!!!!!"
        ;;

    esac
}

# Get Accounts FUSD total
echo "---------- FUSD ----------"
for user in $AGENCY $CREATOR $CREATOR2 $AGENT $AGENT2 $CLIENT $CLIENT2
do
    getAddressName $user
    flow scripts execute ./scripts/get_fusd_balance.cdc $user
done

# Get all Auctions
echo "---------- Auction Wallet ----------"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow scripts execute ./scripts/auction/get_auctions.cdc $user
done

# Verify Collection
echo "---------- Verify Collections ----------"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow scripts execute ./scripts//wallet/get_tokenIDs.cdc $user
done

# Verify Metadata TODO
#echo "---------- Veriy Metadata ----------"
#echo "Creator " -n
#flow transactions send ./transactions/admin/get_metadata_list.cdc $CREATOR
#echo "Creator2 " -n
#flow transactions send ./transactions/admin/get_metadata_list.cdc $CREATOR2
