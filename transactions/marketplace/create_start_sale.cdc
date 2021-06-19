// create_start_sale.cdc

import FungibleToken from 0xee82856bf20e2aa6
import Marketplace   from 0x045a1763c93006ca
import DAAM          from x51e2c02e69b53477

transaction(/*tokenReceiverPath: PublicPath,*/ tokenID: UInt64, price: UFix64) {
    prepare(acct: AuthAccount) {
        let tokenReceiverPath = /public/flowTokenReceiver // TODO DEBUG REMOVE
        // check to see if a sale collection already exists
        if acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath) == nil {
            // get the fungible token capabilities for the owner and beneficiary
            let ownerCapability = acct.getCapability<&{FungibleToken.Receiver}>(tokenReceiverPath)
            let ownerCollection = acct.getCapability<&DAAM.Collection>(DAAM.collectionPublicPath)   // create a new sale collection            
            let saleCollection <- Marketplace.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability)

            acct.save(<-saleCollection, to: Marketplace.marketStoragePath)  // save it to storage
            // create a public link to the sale collection
            acct.link<&Marketplace.SaleCollection{Marketplace.SalePublic}>(Marketplace.marketPublicPath, target: Marketplace.marketStoragePath)
        }
        // borrow a reference to the sale
        let saleCollection = acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")
        
        // put the moment up for sale
        saleCollection.listForSale(tokenID: tokenID, price: price)
        log("Created and Started Sale Collection")
    }
}