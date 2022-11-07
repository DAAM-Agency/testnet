// delete_creator.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

transaction() {
    prepare(creator: AuthAccount) {
        let creatorRes  <- creator.load<@DAAM_Mainnet.Creator>(from: DAAM_Mainnet.creatorStoragePath)
        let requestRes  <- creator.load<@DAAM_Mainnet.RequestGenerator>(from: DAAM_Mainnet.requestStoragePath)
        let metadataRes <- creator.load<@DAAM_Mainnet.MetadataGenerator>(from: DAAM_Mainnet.metadataStoragePath)
        destroy creatorRes
        destroy requestRes
        destroy metadataRes
        creator.unlink(DAAM_Mainnet.creatorPrivatePath)
        creator.unlink(DAAM_Mainnet.requestPrivatePath)
        creator.unlink(DAAM_Mainnet.metadataPublicPath)
        log("Creator Removed")
    } 
}