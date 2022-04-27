// delete_admin.cdc
// Debugging Tool
import DAAM_V8      from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x1837e15023c9249

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@AnyResource>(from: DAAM_V8.adminStoragePath)
        let requestRes <- signer.load<@AnyResource>(from: DAAM_V8.requestStoragePath)
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM_V8.adminPrivatePath)
        signer.unlink(DAAM_V8.requestPrivatePath)
        log("Admin Removed")

        let creatorRes  <- signer.load<@AnyResource>(from: DAAM_V8.creatorStoragePath)
        let metadataRes <- signer.load<@AnyResource>(from: DAAM_V8.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM_V8.creatorPrivatePath)
        signer.unlink(DAAM_V8.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AnyResource>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse.cleared.")

        let collection = signer.borrow<&AnyResource> (from: DAAM_V8.collectionStoragePath)
        let nfts = collection?.getIDs()
        if nfts != nil {
            for token in nfts! {
                let nft <- collection?.withdraw(withdrawID: token)
                destroy nft
            }
            log("NFTs' cleared.")
        }        
        destroy collection
        signer.unlink(DAAM_V8.collectionPublicPath)
        log("Wallet cleared.")
    } 
}