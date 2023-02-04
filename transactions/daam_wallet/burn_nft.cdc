// transfer.cdc

import NonFungibleToken from 0x1d7e57aa55817448
import DAAM from 0x7db4d10c78bad30a

/// This transaction is for transferring and NFT from
/// one account to another
transaction(burn: UInt64) {

    // Reference to the withdrawer's collection
    let withdrawRef: &DAAM.Collection
    let tokenID    : UInt64

    prepare(signer: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer
            .borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)
            ?? panic("Account does not store an object at the specified path")

        self.tokenID = burn
    }

    execute {
        // withdraw the NFT from the owner's collection
        let nft <- self.withdrawRef.withdraw(withdrawID: self.tokenID)
        destroy nft
        log("TokenID: ".concat(self.tokenID.toString()).concat(" is been destroyed.") )
    }

    post {
        !self.withdrawRef.getIDs().contains(self.tokenID): "Original owner should not have the NFT anymore"
    }
}
