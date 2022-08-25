// daam_account_make_non_public.cdc
// Make DAAM_V22.V22 Wallet Non-Public

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM_V22.CollectionPublic}>(from: DAAM_V22.V22.collectionStoragePath) != nil {
            acct.unlink(DAAM_V22.collectionPublicPath)
            log("DAAM_V22.Account Created, you now have a Non-Public DAAM_V22.V22 .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
