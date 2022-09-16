// daam_account_make_non_public.cdc
// Make DAAM_V23 Wallet Non-Public

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM.CollectionPublic}>(from: DAAM_V23.collectionStoragePath) != nil {
            acct.unlink(DAAM.collectionPublicPath)
            log("DAAM Account Created, you now have a Non-Public DAAM_V23 .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
