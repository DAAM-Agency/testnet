// daam_account_make_public.cdc
// Make DAAM_V16 Wallet Public

import DAAM_V16 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V16.Collection{DAAM_V16.CollectionPublic}>(from: DAAM_V16.collectionStoragePath) != nil {
            acct.link<&DAAM_V16.Collection{DAAM_V16.CollectionPublic}>(DAAM_V16.collectionPublicPath, target: DAAM_V16.collectionStoragePath)
            log("DAAM_V16 Account Created, you now have a Public DAAM_V16 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
