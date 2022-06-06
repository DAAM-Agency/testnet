// daam_account_make_public.cdc
// Make DAAM_V12 Wallet Public

import DAAM_V12 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V12.Collection{DAAM_V12.CollectionPublic}>(from: DAAM_V12.collectionStoragePath) != nil {
            acct.link<&DAAM_V12.Collection{DAAM_V12.CollectionPublic}>(DAAM_V12.collectionPublicPath, target: DAAM_V12.collectionStoragePath)
            log("DAAM_V12 Account Created, you now have a Public DAAM_V12 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
