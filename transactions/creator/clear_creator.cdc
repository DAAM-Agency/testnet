// delete_creator.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba
import DAAM_V4 from 0xa4ad5ea5c0bd2fba
import DAAM_V3 from 0xa4ad5ea5c0bd2fba
import DAAM_V2 from 0xa4ad5ea5c0bd2fba
import DAAM_V1 from 0xa4ad5ea5c0bd2fba
import DAAM    from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM.Creator>(from: DAAM.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM.RequestGenerator>(from: DAAM.requestStoragePath)
        let metadataRes <- creator.load<@DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM.creatorPrivatePath)
        creator.unlink(DAAM.requestPrivatePath)
        creator.unlink(DAAM.metadataPublicPath)
        log("Creator Removed")

        let creatorRes1  <- creator.load<@DAAM_V1.Creator>(from: DAAM_V1.creatorStoragePath)
        let requestRes1  <- creator.load<@DAAM_V1.RequestGenerator>(from: DAAM_V1.requestStoragePath)
        let metadataRes1 <- creator.load<@DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)
        destroy creatorRes1
        destroy requestRes1
        destroy metadataRes1
        creator.unlink(DAAM_V1.creatorPrivatePath)
        creator.unlink(DAAM_V1.requestPrivatePath)
        creator.unlink(DAAM_V1.metadataPublicPath)
        log("Creator Removed 1")

        let creatorRes2  <- creator.load<@DAAM_V2.Creator>(from: DAAM_V2.creatorStoragePath)
        let requestRes2  <- creator.load<@DAAM_V2.RequestGenerator>(from: DAAM_V2.requestStoragePath)
        let metadataRes2 <- creator.load<@DAAM_V2.MetadataGenerator>(from: DAAM_V2.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V2.creatorPrivatePath)
        creator.unlink(DAAM_V2.requestPrivatePath)
        creator.unlink(DAAM_V2.metadataPublicPath)
        log("Creator Removed 2")

        let creatorRes3  <- creator.load<@DAAM_V3.Creator>(from: DAAM_V3.creatorStoragePath)
        let requestRes3  <- creator.load<@DAAM_V3.RequestGenerator>(from: DAAM_V3.requestStoragePath)
        let metadataRes3 <- creator.load<@DAAM_V3.MetadataGenerator>(from: DAAM_V3.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V3.creatorPrivatePath)
        creator.unlink(DAAM_V3.requestPrivatePath)
        creator.unlink(DAAM_V3.metadataPublicPath)
        log("Creator Removed 3")

        let creatorRes4  <- creator.load<@DAAM_V4.Creator>(from: DAAM_V4.creatorStoragePath)
        let requestRes4  <- creator.load<@DAAM_V4.RequestGenerator>(from: DAAM_V4.requestStoragePath)
        let metadataRes4 <- creator.load<@DAAM_V4.MetadataGenerator>(from: DAAM_V4.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V4.creatorPrivatePath)
        creator.unlink(DAAM_V4.requestPrivatePath)
        creator.unlink(DAAM_V4.metadataPublicPath)
        log("Creator Removed 4")

        let creatorRes5  <- creator.load<@DAAM_V5.Creator>(from: DAAM_V5.creatorStoragePath)
        let requestRes5  <- creator.load<@DAAM_V5.RequestGenerator>(from: DAAM_V5.requestStoragePath)
        let metadataRes5 <- creator.load<@DAAM_V5.MetadataGenerator>(from: DAAM_V5.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_V5.creatorPrivatePath)
        creator.unlink(DAAM_V5.requestPrivatePath)
        creator.unlink(DAAM_V5.metadataPublicPath)
        log("Creator Removed 5")
    } 
}