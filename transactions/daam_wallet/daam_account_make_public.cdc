// daam_account_make_public.cdc
// Make DAAM_V13 Wallet Public

import DAAM_V13 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V13.Collection{DAAM_V13.CollectionPublic}>(from: DAAM_V13.collectionStoragePath) != nil {
            acct.link<&DAAM_V13.Collection{DAAM_V13.CollectionPublic}>(DAAM_V13.collectionPublicPath, target: DAAM_V13.collectionStoragePath)
            log("DAAM_V13 Account Created, you now have a Public DAAM_V13 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
