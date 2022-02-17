// daam_account_make_public.cdc
// Make DAAM Wallet Public

import DAAM from 0xfd43f9148d4b725d
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.Collection{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath) != nil {
            acct.link<&DAAM.Collection{DAAM.CollectionPublic}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
            log("DAAM Account Created, you now have a Public DAAM Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
