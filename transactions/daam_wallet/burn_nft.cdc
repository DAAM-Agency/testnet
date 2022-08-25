// transfer.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V23 from 0xa4ad5ea5c0bd2fba

/// This transaction is for transferring and NFT from
/// one account to another
transaction(burn: UInt64) {

    // Reference to the withdrawer's collection
    let withdrawRef: &DAAM_V23.Collection
    let tokenID    : UInt64

    prepare(signer: AuthAccount) {
        // borrow a reference to the signer's NFT collection
        self.withdrawRef = signer
            .borrow<&DAAM_V23.Collection>(from: DAAM_V23.collectionStoragePath)
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
