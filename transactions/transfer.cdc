// transfer.cdc

import NonFungibleToken from 0x120e725050340cab
import MarketPalace from 0x045a1763c93006ca

// This transaction is for transferring and NFT from
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {

    prepare(acct: AuthAccount) {

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        let collectionRef = acct.borrow<&MarketPalace.Collection{NonFungibleToken.Provider}>
        (from: MarketPalace.collectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
        
        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(MarketPalace.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}