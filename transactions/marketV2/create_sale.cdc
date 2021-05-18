import FungibleToken from 0xee82856bf20e2aa6
import DAAM_NFT      from 0xfd43f9148d4b725d
import Market        from 0x045a1763c93006ca

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

// Parameters
// 
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale

transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let ownerCollection = acct.link<&DAAM_NFT.Collection>(DAAM_NFT.collectionPrivatePath, target: DAAM_NFT.collectionStoragePath)!

        let collection <- Market.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
        
        acct.save(<-collection, to: Market.marketStoragePath)
        
        acct.link<&Market.SaleCollection{Market.SalePublic}>(Market.marketPublicPath, target: Market.marketStoragePath)
    }
}
