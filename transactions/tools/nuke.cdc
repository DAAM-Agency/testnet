// delete_admin.cdc
// Debugging Tool
import DAAM_V15         from 0xa4ad5ea5c0bd2fba
import AuctionHouse_V5 from 0x1837e15023c9249

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@AnyResource>(from: DAAM_V15.adminStoragePath)
        let requestRes <- signer.load<@AnyResource>(from: DAAM_V15.requestStoragePath)
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM_V15.adminPrivatePath)
        signer.unlink(DAAM_V15.requestPrivatePath)
        log("Admin Removed")

        let creatorRes  <- signer.load<@AnyResource>(from: DAAM_V15.creatorStoragePath)
        let metadataRes <- signer.load<@AnyResource>(from: DAAM_V15.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM_V15.creatorPrivatePath)
        signer.unlink(DAAM_V15.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AnyResource>(from: AuctionHouse_V5.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse_V5.auctionPublicPath)
        log("AuctionHouse_V5.cleared.")

        let collection = signer.borrow<&AnyResource> (from: DAAM_V15.collectionStoragePath)
        let nfts = collection?.getIDs()
        if nfts != nil {
            for token in nfts! {
                let nft <- collection?.withdraw(withdrawID: token)
                destroy nft
            }
            log("NFTs' cleared.")
        }        
        destroy collection
        signer.unlink(DAAM_V15.collectionPublicPath)
        log("Wallet cleared.")
    } 
}