import Marketplace from 0x045a1763c93006ca
import DAAM        from 0xfd43f9148d4b725d

// This transaction changes the price of a moment that a user has for sale

// Parameters:
//
// tokenID: the ID of the moment whose price is being changed
// newPrice: the new price of the moment

transaction(tokenID: UInt64, newPrice: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's sale collection
        let saleCollection = acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // Change the price of the moment
        saleCollection.listForSale(tokenID: tokenID, price: newPrice)
    }
}