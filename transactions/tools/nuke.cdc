// delete_admin.cdc
// Debugging Tool
import DAAM_Mainnet         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x1837e15023c9249

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@AnyResource>(from: DAAM_Mainnet.adminStoragePath)
        let requestRes <- signer.load<@AnyResource>(from: DAAM_Mainnet.requestStoragePath)
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM_Mainnet.adminPrivatePath)
        signer.unlink(DAAM_Mainnet.requestPrivatePath)
        log("Admin Removed")

        let creatorRes  <- signer.load<@AnyResource>(from: DAAM_Mainnet.creatorStoragePath)
        let metadataRes <- signer.load<@AnyResource>(from: DAAM_Mainnet.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM_Mainnet.creatorPrivatePath)
        signer.unlink(DAAM_Mainnet.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AnyResource>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse.cleared.")

        let collection = signer.borrow<&AnyResource> (from: DAAM_Mainnet.collectionStoragePath)
        let nfts = collection?.getIDs()
        if nfts != nil {
            for token in nfts! {
                let nft <- collection?.withdraw(withdrawID: token)
                destroy nft
            }
            log("NFTs' cleared.")
        }        
        destroy collection
        signer.unlink(DAAM_Mainnet.collectionPublicPath)
        log("Wallet cleared.")
    } 
}