import FungibleToken from 0xee82856bf20e2aa6
import DAAM          from 0xfd43f9148d4b725d
import Marketplace   from 0x045a1763c93006ca

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

// Parameters
// 
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale

transaction(/*tokenReceiverPath: PublicPath,*/) {
    prepare(acct: AuthAccount) {
        let tokenReceiverPath = /public/flowTokenReceiver // TODO DEBUG REMOVE        
        
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)
        
        let ownerCollection = acct.link<&DAAM.Collection>(DAAM.collectionPrivatePath, target: DAAM.collectionStoragePath)!
        let collection <- Marketplace.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability)        
        acct.save(<-collection, to: Marketplace.marketStoragePath)        
        acct.link<&Marketplace.SaleCollection{Marketplace.SalePublic}>(Marketplace.marketPublicPath, target: Marketplace.marketStoragePath)
        log("Created Sale Collection")
    }
}
