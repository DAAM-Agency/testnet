// daam_account_make_public.cdc
// Make DAAM_V11 Wallet Public

import DAAM_V11 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V11.Collection{DAAM_V11.CollectionPublic}>(from: DAAM_V11.collectionStoragePath) != nil {
            acct.link<&DAAM_V11.Collection{DAAM_V11.CollectionPublic}>(DAAM_V11.collectionPublicPath, target: DAAM_V11.collectionStoragePath)
            log("DAAM_V11 Account Created, you now have a Public DAAM_V11 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
