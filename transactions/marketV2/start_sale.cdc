import Market        from 0x045a1763c93006ca
import DAAM_NFT      from 0xfd43f9148d4b725d

// This transaction is for a user to put a new moment up for sale
// They must have DAAM_NFT Collection and a Market Sale Collection already
// stored in their account

// Parameters
//
// momentId: the ID of the moment to be listed for sale
// price: the sell price of the moment

transaction(tokenID: UInt64, price: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the topshot Sale Collection
        let saleCollection = acct.borrow<&Market.SaleCollection>(from: Market.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // List the specified moment for sale
        saleCollection.listForSale(tokenID: tokenID, price: price)
    }
}