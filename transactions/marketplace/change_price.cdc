import Marketplace from 0x045a1763c93006ca
import DAAM        from x51e2c02e69b53477

transaction(tokenID: UInt64, newPrice: UFix64) {

    prepare(acct: AuthAccount) {
        // borrow a reference to the owner's sale collection
        let saleCollection = acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")
        // Change the price of the moment
        saleCollection.listForSale(tokenID: tokenID, price: newPrice)
    }
}