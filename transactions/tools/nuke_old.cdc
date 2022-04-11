// delete_admin.cdc
// Debugging Tool
import DAAM         from 0xfd43f9148d4b725d
import AuctionHouse from 0x045a1763c93006ca

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@DAAM.Admin>(from: DAAM.adminStoragePath)!
        let requestRes <- signer.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)!
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM.adminPrivatePath)
        signer.unlink(DAAM.requestPrivatePath)
        log("Admin Removed")

        let agentRes  <- signer.load<@DAAM.Admin{DAAM.Agent}>(from: DAAM.adminStoragePath)
        destroy agentRes
        log("Agent Removed")

        let creatorRes  <- signer.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)
        let metadataRes <- signer.load<@DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM.creatorPrivatePath)
        signer.unlink(DAAM.metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse cleared.")

        let collection = signer.borrow<&DAAM.Collection> (from: DAAM.collectionStoragePath)
        let nfts = collection?.getIDs()!
        for token in nfts {
            let nft <- collection?.withdraw(withdrawID: token)
            destroy nft
        }
        log("NFTs' cleared.")

        let wallet <- signer.load<@DAAM.Collection> (from: DAAM.collectionStoragePath)
        destroy wallet
        signer.unlink(DAAM.collectionPublicPath)
        log("Wallet cleared.")
    } 
}