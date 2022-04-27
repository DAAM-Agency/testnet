// daam_account_make_public.cdc
// Make DAAM_V9.Wallet Public

import DAAM_V9 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V9.Collection{DAAM_V9.CollectionPublic}>(from: DAAM_V9.collectionStoragePath) != nil {
            acct.link<&DAAM_V9.Collection{DAAM_V9.CollectionPublic}>(DAAM_V9.collectionPublicPath, target: DAAM_V9.collectionStoragePath)
            log("DAAM_V9.Account Created, you now have a Public DAAM_V9.Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
