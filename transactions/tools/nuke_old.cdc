// delete_admin.cdc
// Debugging Tool
import DAAM         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@DAAM_V7.Admin>(from: DAAM_V7.adminStoragePath)!
        let requestRes <- signer.load<@DAAM_V7.RequestGenerator>(from: DAAM_V7.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM_V7.adminPrivatePath)
        signer.unlink(DAAM_V7.requestPrivatePath)
        log("Admin Removed")

        let agentRes  <- signer.load<@DAAM_V7.Admin{DAAM_V7.Agent}>(from: DAAM_V7.adminStoragePath)
        destroy agentRes
        log("Agent Removed")

        let creatorRes  <- signer.load<@DAAM_V7.Creator>(from: DAAM_V7.creatorStoragePath)
        let metadataRes <- signer.load<@DAAM_V7.MetadataGenerator>(from: DAAM_V7.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM_V7.creatorPrivatePath)
        signer.unlink(DAAM_V7.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse cleared.")

        let collection = signer.borrow<&DAAM_V7.Collection> (from: DAAM_V7.collectionStoragePath)
        let nfts = collection?.getIDs()!
        for token in nfts {
            let nft <- collection?.withdraw(withdrawID: token)
            destroy nft
        }
        log("NFTs' cleared.")

        let wallet <- signer.load<@DAAM_V7.Collection> (from: DAAM_V7.collectionStoragePath)
        destroy wallet
        signer.unlick(DAAM_V7.collectionPublicPath)
        log("Wallet cleared.")
    } 
}