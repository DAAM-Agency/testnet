// setup_daam_account.cdc
// Create A DAAM Wallet to store DAAM NFTs

//import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

transaction(public: Bool)
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.Collection> (from: DAAM.collectionStoragePath) != nil { return }        
        let collection <- DAAM.createDAAMCollection()    // Create a new empty collection        
        //acct.save<@NonFungibleToken.Collection> (<-collection, to: DAAM.collectionStoragePath) // save the new account
        acct.save<@DAAM.Collection> (<-collection, to: DAAM.collectionStoragePath) // save the new account
        if public {
            acct.link<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
            log("DAAM Account Created, you now have a DAAM Collection to store NFTs'")
        } else {
            log("DAAM Account Created, you now have a non-public DAAM Collection to store NFTs'")
        }
    }
}
