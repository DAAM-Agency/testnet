import Marketplace from 0x045a1763c93006ca
import DAAM        from 0xfd43f9148d4b725d

// This transaction is for a user to stop a moment sale in their account

// Parameters
//
// tokenID: the ID of the moment whose sale is to be delisted

transaction(tokenID: UInt64) {

    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's sale collection
        let saleCollection = acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // cancel the moment from the sale, thereby de-listing it
        saleCollection.cancelSale(tokenID: tokenID)
    }
}