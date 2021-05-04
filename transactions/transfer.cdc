import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xf8d6e0586b0a20c7

// This transaction is for transferring and NFT from
// one account to another

transaction(recipient: Address, withdrawID: UInt64) {

    prepare(acct: AuthAccount) {

        // get the recipients public account object
        let recipient = getAccount(recipient)

        // borrow a reference to the signer's NFT collection
        //let collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            //?? panic("Could not borrow a reference to the owner's collection")
        
        //let collectionRef = &DAAM.collection

        // borrow a public reference to the receivers collection
        let depositRef = recipient.getCapability(DAAM.collectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        // withdraw the NFT from the owner's collection
        let nft <- collectionRef.withdraw(withdrawID: withdrawID)

        // Deposit the NFT in the recipient's collection
        depositRef.deposit(token: <-nft)
    }
}