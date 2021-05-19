import Market from 0x045a1763c93006ca

transaction(newPercentage: UFix64) {
    prepare(acct: AuthAccount) {

        let topshotSaleCollection = acct.borrow<&Market.SaleCollection>(from: Market.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        topshotSaleCollection.changePercentage(newPercentage)
    }
}