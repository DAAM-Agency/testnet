// change_creator_status.cdc

import DAAM             from 0xfd43f9148d4b725d
import NonFungibleToken from 0x120e725050340cab

transaction(creator: Address) {

    prepare(acct: AuthAccount) {

        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        let collection = getAccount(acct.address)
            .getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath)
            .borrow()!
            
        let metadataGenerator = getAccount(creator).borrow<&DAAM.MetadataGenerator>(from: DAAM.metadataStoragePath)
  
        admin.mintNFT(recipient: collection, metadata: metadata)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Change Creator Status")
    }
}// transaction
