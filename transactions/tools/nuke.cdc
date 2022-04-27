// delete_admin.cdc
// Debugging Tool
import DAAM         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x1837e15023c9249

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@AnyResource>(from: DAAM.adminStoragePath)
        let requestRes <- signer.load<@AnyResource>(from: DAAM.requestStoragePath)
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM.adminPrivatePath)
        signer.unlink(DAAM.requestPrivatePath)
        log("Admin Removed")

        let creatorRes  <- signer.load<@AnyResource>(from: DAAM.creatorStoragePath)
        let metadataRes <- signer.load<@AnyResource>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM.creatorPrivatePath)
        signer.unlink(DAAM.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AnyResource>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse.cleared.")

        let collection = signer.borrow<&AnyResource> (from: DAAM.collectionStoragePath)
        let nfts = collection?.getIDs()
        if nfts != nil {
            for token in nfts! {
                let nft <- collection?.withdraw(withdrawID: token)
                destroy nft
            }
            log("NFTs' cleared.")
        }        
        destroy collection
        signer.unlink(DAAM.collectionPublicPath)
        log("Wallet cleared.")
    } 
}