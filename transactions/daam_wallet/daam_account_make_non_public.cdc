// daam_account_make_non_public.cdc
// Make DAAM Wallet Non-Public

import DAAM from 0xfd43f9148d4b725d

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath) != nil {
            acct.unlink(DAAM.collectionPublicPath)
            log("DAAM Account Created, you now have a Non-Public DAAM .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
