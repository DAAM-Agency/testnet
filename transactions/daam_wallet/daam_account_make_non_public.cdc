// daam_account_make_non_public.cdc
<<<<<<< HEAD
// Make DAAM_V10.Wallet Non-Public

import DAAM_V10 from 0xa4ad5ea5c0bd2fba
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM_V10.CollectionPublic}>(from: DAAM_V10.collectionStoragePath) != nil {
            acct.unlink(DAAM_V10.collectionPublicPath)
            log("DAAM_V10.Account Created, you now have a Non-Public DAAM_V10.Collection to store NFTs'")
=======
// Make DAAM_V14 Wallet Non-Public

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM_V14.CollectionPublic}>(from: DAAM_V14.collectionStoragePath) != nil {
            acct.unlink(DAAM_V14.collectionPublicPath)
            log("DAAM_V14 Account Created, you now have a Non-Public DAAM_V14 .Collection to store NFTs'")
>>>>>>> DAAM_V14
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
