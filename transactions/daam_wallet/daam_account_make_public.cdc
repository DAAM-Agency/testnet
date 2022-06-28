// daam_account_make_public.cdc
// Make DAAM_V17 Wallet Public

import DAAM_V17 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V17.Collection{DAAM_V17.CollectionPublic}>(from: DAAM_V17.collectionStoragePath) != nil {
            acct.link<&DAAM_V17.Collection{DAAM_V17.CollectionPublic}>(DAAM_V17.collectionPublicPath, target: DAAM_V17.collectionStoragePath)
            log("DAAM_V17 Account Created, you now have a Public DAAM_V17 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
