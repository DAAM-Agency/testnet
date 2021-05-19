// purchase_nft.cdc

import NonFungibleToken from 0x120e725050340cab
import Marketplace      from 0x045a1763c93006ca
import DAAM         from 0xfd43f9148d4b725d
import FlowToken        from 0x0ae53cb6e3f42a79
import FungibleToken    from 0xee82856bf20e2aa6

// This transaction uses the signers Vault tokens to purchase an NFT
// from the Sale collection of account 0x01.
transaction(recipient: Address, tokenID: UInt64, amount: UFix64) {


    // reference to the buyer's NFT collection where they
    // will store the bought NFT
    let collectionRef: &AnyResource{NonFungibleToken.Receiver}

    // Vault that will hold the tokens that will be used to
    // but the NFT
    let temporaryVault: @FungibleToken.Vault

    prepare(acct: AuthAccount) {

        // get the references to the buyer's fungible token Vault and NFT Collection Receiver
        self.collectionRef = acct.borrow<&AnyResource{NonFungibleToken.Receiver}>(from: DAAM.collectionStoragePath)!
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: Marketplace.vaultStoragePath)
            ?? panic("Could not borrow owner's vault reference")

        // withdraw tokens from the buyers Vault
        self.temporaryVault <- vaultRef.withdraw(amount: amount) //as! @FlowToken.Vault
    }

    execute {
        // get the read-only account storage of the seller
        let seller = getAccount(recipient)

        // get the reference to the seller's sale
        let saleCap = seller.getCapability(Marketplace.publicPath)
        let saleRef = saleCap.borrow<&Marketplace.SaleCollection>()//! as &Marketplace.SaleCollection
                ?? panic("failed to borrow reference to recipient vault")

        // purchase the NFT the the seller is selling, giving them the reference
        // to your NFT collection and giving them the tokens to buy it
        saleRef.purchase(tokenID: tokenID, recipient: self.collectionRef, buyTokens: <-self.temporaryVault)

        log("Token 1 has been bought by account 2!")
    }
}
 
