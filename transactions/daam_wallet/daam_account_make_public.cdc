// daam_account_make_public.cdc
// Make DAAM_V14 Wallet Public

import DAAM_V14 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM_V14.Collection{DAAM_V14.CollectionPublic}>(from: DAAM_V14.collectionStoragePath) != nil {
            acct.link<&DAAM_V14.Collection{DAAM_V14.CollectionPublic}>(DAAM_V14.collectionPublicPath, target: DAAM_V14.collectionStoragePath)
            log("DAAM_V14 Account Created, you now have a Public DAAM_V14 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
