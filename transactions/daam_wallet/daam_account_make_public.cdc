// daam_account_make_public.cdc
// Make DAAM_V18 Wallet Public

import DAAM_V18 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V18.Collection{DAAM_V18.CollectionPublic}>(from: DAAM_V18.collectionStoragePath) != nil {
            acct.link<&DAAM_V18.Collection{DAAM_V18.CollectionPublic}>(DAAM_V18.collectionPublicPath, target: DAAM_V18.collectionStoragePath)
            log("DAAM_V18 Account Created, you now have a Public DAAM_V18 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
