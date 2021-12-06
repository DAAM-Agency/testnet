// clear_signer.cdc

import DAAM    from 0xa4ad5ea5c0bd2fba
import DAAM_V1 from 0xa4ad5ea5c0bd2fba
import DAAM_V2 from 0xa4ad5ea5c0bd2fba
import DAAM_V3 from 0xa4ad5ea5c0bd2fba
import DAAM_V4 from 0xa4ad5ea5c0bd2fba
import DAAM_V5 from 0xa4ad5ea5c0bd2fba
import DAAM_V6 from 0xa4ad5ea5c0bd2fba
import AuctionHouse from 0x01837e15023c9249

transaction() {
    prepare(signer: AuthAccount) {
        let adminRes <- signer.load<@DAAM.Admin>(from: DAAM.adminStoragePath)
        let requestRes <- signer.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        destroy adminRes
        destroy requestRes
        signer.unlink(DAAM.adminPrivatePath)
        signer.unlink(DAAM.requestPrivatePath)
        log("Admin Removed")

        let adminRes1 <- signer.load<@DAAM_V1.Admin>(from: DAAM_V1.adminStoragePath)
        let requestRes1 <- signer.load<@DAAM_V1.RequestGenerator>(from: DAAM_V1.requestStoragePath)
        destroy adminRes1
        destroy requestRes1
        signer.unlink(DAAM_V1.adminPrivatePath)
        signer.unlink(DAAM_V1.requestPrivatePath)
        log("Admin Removed 1")

        let adminRes2 <- signer.load<@DAAM_V2.Admin>(from: DAAM_V2.adminStoragePath)
        let requestRes2 <- signer.load<@DAAM_V2.RequestGenerator>(from: DAAM_V2.requestStoragePath)
        destroy adminRes2
        destroy requestRes2
        signer.unlink(DAAM_V2.adminPrivatePath)
        signer.unlink(DAAM_V2.requestPrivatePath)
        log("Admin Removed 2")

        let adminRes3 <- signer.load<@DAAM_V3.Admin>(from: DAAM_V3.adminStoragePath)
        let requestRes3 <- signer.load<@DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)
        destroy adminRes3
        destroy requestRes3
        signer.unlink(DAAM_V3.adminPrivatePath)
        signer.unlink(DAAM_V3.requestPrivatePath)
        log("Admin Removed 3")

        let adminRes4 <- signer.load<@DAAM_V4.Admin>(from: DAAM_V4.adminStoragePath)
        let requestRes4 <- signer.load<@DAAM_V4.RequestGenerator>(from: DAAM_V4.requestStoragePath)
        destroy adminRes4
        destroy requestRes4
        signer.unlink(DAAM_V4.adminPrivatePath)
        signer.unlink(DAAM_V4.requestPrivatePath)
        log("Admin Removed 4")

        let adminRes5 <- signer.load<@DAAM_V5.Admin>(from: DAAM_V5.adminStoragePath)
        let requestRes5 <- signer.load<@DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)
        destroy adminRes5
        destroy requestRes5
        signer.unlink(DAAM_V5.adminPrivatePath)
        signer.unlink(DAAM_V5.requestPrivatePath)
        log("Admin Removed 5")

        let adminRes6 <- signer.load<@DAAM_V6.Admin>(from: DAAM_V6.adminStoragePath)
        let requestRes6 <- signer.load<@DAAM_V6.RequestGenerator>(from: DAAM_V6.requestStoragePath)
        destroy adminRes6
        destroy requestRes6
        signer.unlink(DAAM_V6.adminPrivatePath)
        signer.unlink(DAAM_V6.requestPrivatePath)
        log("Admin Removed 6")

        let creatorRes  <- signer.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)
        let metadataRes <- signer.load<@DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy metadataRes
        signer.unlink(DAAM.creatorPrivatePath)
        signer.unlink(DAAM.metadataPrivatePath)
        log("Creator Removed")

        let creatorRes1  <- signer.load<@DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath)
        let metadataRes1 <- signer.load<@DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)
        destroy creatorRes1
        destroy metadataRes1
        signer.unlink(DAAM_V1.creatorPrivatePath)
        signer.unlink(DAAM_V1.metadataPrivatePath)
        log("Creator Removed 1")

        let creatorRes2  <- signer.load<@DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)
        let metadataRes2 <- signer.load<@DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath)
        destroy creatorRes2
        destroy metadataRes2
        signer.unlink(DAAM_V2.creatorPrivatePath)
        signer.unlink(DAAM_V2.metadataPrivatePath)
        log("Creator Removed 2")

        let creatorRes3  <- signer.load<@DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)
        let metadataRes3 <- signer.load<@DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)
        destroy creatorRes3
        destroy metadataRes3
        signer.unlink(DAAM_V3.creatorPrivatePath)
        signer.unlink(DAAM_V3.metadataPublicPath)
        log("Creator Removed 3")

        let creatorRes4  <- signer.load<@DAAM_V4.Creator>(from: DAAM_V4.creatorStoragePath)
        let metadataRes4 <- signer.load<@DAAM_V4.MetadataGenerator>(from: DAAM_V4.metadataStoragePath)
        destroy creatorRes4
        destroy metadataRes4
        signer.unlink(DAAM_V4.creatorPrivatePath)
        signer.unlink(DAAM_V4.metadataPublicPath)
        log("Creator Removed 4")

        let creatorRes5  <- signer.load<@DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)
        let metadataRes5 <- signer.load<@DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)
        destroy creatorRes5
        destroy metadataRes5
        signer.unlink(DAAM_V5.creatorPrivatePath)
        signer.unlink(DAAM_V5.metadataPublicPath)
        log("Creator Removed 5")

        let creatorRes6  <- signer.load<@DAAM_V6.Creator>(from: DAAM_V6.creatorStoragePath)
        let metadataRes6 <- signer.load<@DAAM_V6.MetadataGenerator>(from: DAAM_V6.metadataStoragePath)
        destroy creatorRes6
        destroy metadataRes6
        signer.unlink(DAAM_V6.creatorPrivatePath)
        signer.unlink(DAAM_V6.metadataPublicPath)
        log("Creator Removed 6")

        let collection = signer.borrow<&DAAM_V6.Collection> (from: DAAM_V6.collectionStoragePath)
        let nfts = collection?.getIDs()!
        for token in nfts {
            let nft <- collection?.withdraw(withdrawID: token)
            destroy nft
        }
        log("NFTs' cleared.")

        let auctionRes  <- signer.load<@AuctionHouse.AuctionWallet>(from: AuctionHouse.auctionStoragePath)
        destroy auctionRes
        signer.unlink(AuctionHouse.auctionPublicPath)
        log("AuctionHouse cleared.")

        let wallet <- signer.load<@DAAM_V6.Collection> (from: DAAM.collectionStoragePath)
        destroy wallet
        signer.unlink(DAAM.collectionPublicPath)
        log("Wallet cleared.")
    } 
}