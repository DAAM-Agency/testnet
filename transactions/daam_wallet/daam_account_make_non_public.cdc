// daam_account_make_non_public.cdc
<<<<<<< HEAD
// Make DAAM_V14 Wallet Non-Public

import DAAM_V14 from 0xa4ad5ea5c0bd2fba
=======
// Make DAAM_V15 Wallet Non-Public

import DAAM_V15 from 0xa4ad5ea5c0bd2fba
>>>>>>> DAAM_V15

transaction()
{
    prepare(acct: AuthAccount) {
<<<<<<< HEAD
        if acct.borrow<&{DAAM_V14.CollectionPublic}>(from: DAAM_V14.collectionStoragePath) != nil {
            acct.unlink(DAAM_V14.collectionPublicPath)
            log("DAAM_V14 Account Created, you now have a Non-Public DAAM_V14 .Collection to store NFTs'")
=======
        if acct.borrow<&{DAAM_V15.CollectionPublic}>(from: DAAM_V15.collectionStoragePath) != nil {
            acct.unlink(DAAM_V15.collectionPublicPath)
            log("DAAM_V15 Account Created, you now have a Non-Public DAAM_V15 .Collection to store NFTs'")
>>>>>>> DAAM_V15
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
