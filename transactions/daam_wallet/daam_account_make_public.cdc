// daam_account_make_public.cdc
// Make DAAM_V10.Wallet Public

import DAAM_V10 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V10.Collection{DAAM_V10.CollectionPublic}>(from: DAAM_V10.collectionStoragePath) != nil {
            acct.link<&DAAM_V10.Collection{DAAM_V10.CollectionPublic}>(DAAM_V10.collectionPublicPath, target: DAAM_V10.collectionStoragePath)
            log("DAAM_V10.Account Created, you now have a Public DAAM_V10.Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
