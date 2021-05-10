// setup_account.cdc

import NonFungibleToken from 0x120e725050340cab
import DAAM from 0x045a1763c93006ca
// This transaction is what an account would run
// to set itself up to receive NFTs

transaction {

    prepare(acct: AuthAccount) {

        // Return early if the account already has a collection
        if acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- DAAM.createEmptyCollection()

        // save it to the account
        acct.save(<-collection, to: DAAM.collectionStoragePath)

        // create a public capability for the collection
        acct.link<&{NonFungibleToken.CollectionPublic}>(
            DAAM.collectionPublicPath,
            target: DAAM.collectionStoragePath
        )
    }
}
