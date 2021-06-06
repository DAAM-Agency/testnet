import FungibleToken    from 0xee82856bf20e2aa6
import NonFungibleToken from 0x120e725050340cab
import FlowToken        from 0x0ae53cb6e3f42a79
import DAAM             from 0xfd43f9148d4b725d
import Marketplace      from 0xe2f72218abeec2b9

// This transaction is for a user to purchase a moment that another user
// has for sale in their sale collection

// Parameters
//
// sellerAddress: the Flow address of the account issuing the sale of a moment
// tokenID: the ID of the moment being purchased
// purchaseAmount: the amount for which the user is paying for the moment; must not be less than the moment's price

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