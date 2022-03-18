flow transactions send ./transactions/fusd/transfer_fusd.cdc 1.0 $PROFILE --signer cto # Dummy action to update flow

echo "---------- Testing Functions ----------"

getAddressName() {
    case $1 in

        $AGENCY)
        echo -n " Agency  : "
        ;;

        $ADMIN)
        echo -n " Admin   : "
        ;;
        
        $ADMIN2)
        echo -n " Admin2  : "
        ;;
        
        $AGENT)
        echo -n " Agent   : "
        ;;
        
        $AGENT2)
        echo -n " Agent2  : "
        ;;
        
        $CREATOR)
        echo -n " Creator : "
        ;;
        
        $CREATOR2)
        echo -n " Creator2: "
        ;;
        
        $NOBODY)
        echo -n " Nobody  : "
        ;;
        
        $CTO)
        echo -n " CTO     : "
        ;;
        
        $CLIENT)
        echo -n " Client  : "
        ;;
        
        $CLIENT2)
        echo -n " Client2 : "
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
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $user | jq ' .value | .value'
done

# Get all Auctions
echo "---------- Auction Wallet ----------\n"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/auction/get_auctions.cdc $user | jq ' .value'
done

# Verify Collection
echo "---------- Verify Collections ----------\n"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/daam_wallet/get_collections.cdc $user | jq ' .value | .value'
done

# Verify Metadata
echo "---------- Veriy Metadata ----------\n"
./scripts/get_mids.sh | jq -c

# Verify TokenIDs
echo "---------- Veriy TokenIDs ----------\n"
for user in $CREATOR $CREATOR2 $AGENT $AGENT2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $user | jq ' .value | .value'
done
