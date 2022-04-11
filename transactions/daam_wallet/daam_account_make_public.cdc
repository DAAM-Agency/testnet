// daam_account_make_public.cdc
// Make DAAM_V8.Wallet Public

import DAAM_V8 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V8.Collection{DAAM_V8.CollectionPublic}>(from: DAAM_V8.collectionStoragePath) != nil {
            acct.link<&DAAM_V8.Collection{DAAM_V8.CollectionPublic}>(DAAM_V8.collectionPublicPath, target: DAAM_V8.collectionStoragePath)
            log("DAAM_V8.Account Created, you now have a Public DAAM_V8.Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
