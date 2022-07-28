// daam_account_make_non_public.cdc
// Make DAAM_V19 Wallet Non-Public

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM_V19.CollectionPublic}>(from: DAAM_V19.collectionStoragePath) != nil {
            acct.unlink(DAAM_V19.collectionPublicPath)
            log("DAAM_V19 Account Created, you now have a Non-Public DAAM_V19 .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
