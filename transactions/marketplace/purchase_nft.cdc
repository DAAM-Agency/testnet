import FungibleToken    from 0x9a0766d93b6608b7
import NonFungibleToken from 0x631e88ae7f1d7c20
import FlowToken        from 0x7e60df042a9c0868
import DAAM             from 0x51e2c02e69b53477
import Marketplace      from 0x045a1763c93006ca

transaction(sellerAddress: Address, tokenID: UInt64, purchaseAmount: UFix64) {
    prepare(acct: AuthAccount) {
        // get the seller's public account object
        let seller = getAccount(sellerAddress)

        // borrow a public reference to the seller's sale collection
        let saleCollection = seller.getCapability(Marketplace.marketPublicPath)
            .borrow<&{Marketplace.SalePublic}>()
            ?? panic("Could not borrow public sale reference")

        // borrow a reference to the signer's collection
        let collection = acct.borrow<&DAAM.Collection{NonFungibleToken.Receiver}>(from: DAAM.collectionStoragePath)
            ?? panic("Could not borrow reference to the DAAM Collection")

        // borrow a reference to the signer's fungible token Vault
        let provider = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(from: Marketplace.flowStoragePath)!
        
        // withdraw tokens from the signer's vault
        let tokens <- provider.withdraw(amount: purchaseAmount) as! @FlowToken.Vault        
    
        saleCollection.purchase(tokenID: tokenID, recipient: collection, buyTokens: <-tokens)
        
        let logmsg = sellerAddress.toString().concat(" sold NFT: ".concat(tokenID.toString()
            .concat(" To: ").concat(acct.address.toString().concat(" amount:" ).concat(purchaseAmount.toString()))) )
        log(logmsg)
    }
}