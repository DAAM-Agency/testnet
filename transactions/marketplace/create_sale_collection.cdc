// create_sale_collection.cdc

import FungibleToken    from 0xee82856bf20e2aa6
import NonFungibleToken from 0x120e725050340cab
import Marketplace      from 0x045a1763c93006ca
import DAAM_NFT         from 0xfd43f9148d4b725d

// This transaction creates a new Sale Collection object,
// lists an NFT for sale, puts it in account storage,
// and creates a public capability to the sale so that others can buy the token.
transaction(withdrawID: UInt64, price: UFix64) {

    prepare(acct: AuthAccount) {

        // Borrow a reference to the stored Vault
        let receiver = acct.getCapability<&{FungibleToken.Receiver}>(/public/MainReceiver)

        // Create a new Sale object, 
        // initializing it with the reference to the owner's vault
        let sale <- Marketplace.createSaleCollection(ownerVault: receiver)

        // borrow a reference to the NFTCollection in storage
        let collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: DAAM_NFT.collectionStoragePath)
            ?? panic("Could not borrow owner's nft collection reference")
    
        // Withdraw the NFT from the collection that you want to sell
        // and move it into the transaction's context
        let token <- collectionRef.withdraw(withdrawID: withdrawID)

        // List the token for sale by moving it into the sale object
        sale.listForSale(token: <-token, price: price)

        // Store the sale object in the account storage 
        acct.save(<-sale, to: Marketplace.storagePath)

        // Create a public capability to the sale so that others can call its methods
        acct.link<&Marketplace.SaleCollection>(Marketplace.publicPath, target: Marketplace.storagePath)

        var logmsg = "For Sale: NFT ".concat(withdrawID.toString().concat(" price: ").concat(price.toString()) )
        log(logmsg)
    }
}
 

