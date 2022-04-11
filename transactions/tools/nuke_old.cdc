// delete_admin.cdc
// Debugging Tool
import DAAM_V8.V8.V8_V8..         from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x045a1763c93006ca

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@DAAM_V8.V8..Admin>(from: DAAM_V8.V8..adminStoragePath)!
        let requestRes <- signer.load<@DAAM_V8.V8..RequestGenerator>(from: DAAM_V8.V8..requestStoragePath)!
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM_V8.V8..adminPrivatePath)
        signer.unlink(DAAM_V8.V8..requestPrivatePath)
        log("Admin Removed")

        let agentRes  <- signer.load<@DAAM_V8.V8..Admin{DAAM_V8.V8..Agent}>(from: DAAM_V8.V8..adminStoragePath)
        destroy agentRes
        log("Agent Removed")

        let creatorRes  <- signer.load<@DAAM_V8.V8..Creator>(from: DAAM_V8.V8..creatorStoragePath)
        let metadataRes <- signer.load<@DAAM_V8.V8..MetadataGenerator>(from: DAAM_V8.V8..metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM_V8.V8..creatorPrivatePath)
        signer.unlink(DAAM_V8.V8..metadataPublicPath)
        log("Creator Removed")

        let auctionRes  <- signer.load<@AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse cleared.")

        let collection = signer.borrow<&DAAM_V8.V8..Collection> (from: DAAM_V8.V8..collectionStoragePath)
        let nfts = collection?.getIDs()!
        for token in nfts {
            let nft <- collection?.withdraw(withdrawID: token)
            destroy nft
        }
        log("NFTs' cleared.")

        let wallet <- signer.load<@DAAM_V8.V8..Collection> (from: DAAM_V8.V8..collectionStoragePath)
        destroy wallet
        signer.unlink(DAAM_V8.V8..collectionPublicPath)
        log("Wallet cleared.")
    } 
}