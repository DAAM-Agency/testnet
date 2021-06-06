import FungibleToken from 0xee82856bf20e2aa6
import DAAM          from 0xfd43f9148d4b725d
import Marketplace   from 0xe2f72218abeec2b9

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

transaction(/*tokenReceiverPath: PublicPath,*/) {
    prepare(acct: AuthAccount) {
        let tokenReceiverPath = /public/flowTokenReceiver // TODO DEBUG REMOVE        
        
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)
        let ownerCollection = acct.getCapability<&DAAM.Collection>(DAAM.collectionPublicPath)
        let saleCollection <- Marketplace.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability)

        acct.save(<-saleCollection, to: Marketplace.marketStoragePath)        
        acct.link<&Marketplace.SaleCollection{Marketplace.SalePublic}>(Marketplace.marketPublicPath, target: Marketplace.marketStoragePath)
        
        log("Created Sale Collection")
    }
}
