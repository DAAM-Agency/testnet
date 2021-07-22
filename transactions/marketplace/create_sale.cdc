import FungibleToken from 0x9a0766d93b6608b7
import DAAM          from 0x51e2c02e69b53477
import Marketplace   from 0x045a1763c93006ca

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

transaction() {
    prepare(acct: AuthAccount) {
        let tokenReceiverPath = /public/flowTokenReceiver // Exclusive to FlowTokens  
        
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)
        let ownerCollection = acct.getCapability<&DAAM.Collection>(DAAM.collectionPublicPath)
        let saleCollection <- Marketplace.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability)

        acct.save(<-saleCollection, to: Marketplace.marketStoragePath)        
        acct.link<&Marketplace.SaleCollection{Marketplace.SalePublic}>(Marketplace.marketPublicPath, target: Marketplace.marketStoragePath)
        
        log("Created Sale Collection")
    }
}
