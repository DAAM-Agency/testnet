alias flow='$HOME/.local/bin/flow'

flow transactions send ./transactions/fusd/transfer_fusd.cdc 1.0 $PROFILE --signer cto # Dummy action to update flow

echo "---------- Update Blockchain Transaction ----------"

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

        $CLIENT)
        echo -n " Client  : "
        ;;

        $CLIENT2)
        echo -n " Client2 : "
        ;;
        
        $CTO)
        echo -n " CTO     : "
        ;;
        
        $FOUNDER1)
        echo -n " Founder1: "
        ;;
        
        $FOUNDER2)
        echo -n " Founder2: "
        ;;
        
        $FOUNDER3)
        echo -n " Founder3: "
        ;;
        
        $FOUNDER4)
        echo -n " Founder4: "
        ;;
        
        $FOUNDER5)
        echo -n " Founder5: "
        ;;

        *)
        echo -n "!!!!!!!!! RETURNED WRONG VALUE !!!!!!!!!!"
        ;;

    esac
}

# Get Accounts FUSD total
echo "---------- FUSD ----------"
for user in $AGENCY $CREATOR $CREATOR2 $AGENT $AGENT2 $CLIENT $CLIENT2 $NOBODY $CTO $FOUNDER1 $FOUNDER2 $FOUNDER3 $FOUNDER4 $FOUNDER5
do
    getAddressName $user
    flow -o json scripts execute ./scripts/get_fusd_balance.cdc $user | jq ' .value | .value'
done

# Get all Auctions
echo "---------- Auction Wallet ----------"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/auction/get_auctions.cdc $user | jq ' .value'
done

# Verify Collection

echo "---------- Verify Collections ----------"
for user in $CREATOR $CREATOR2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/daam_wallet/get_collections.cdc $user | jq ' .value | .value'
done

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    flow -o json scripts execute ./scripts/auction/get_creator_history.cdc $user
done

# Verify TokenIDs
echo "---------- Veriy TokenIDs ----------"
for user in $CREATOR $CREATOR2 $AGENT $AGENT2 $CLIENT $CLIENT2 $NOBODY
do
    getAddressName $user
    flow -o json scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $user | jq ' .value | .value'
done
