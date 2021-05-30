// change_creator_status.cdc

import DAAM             from 0xfd43f9148d4b725d
import NonFungibleToken from 0x120e725050340cab

transaction(creator: Address, elm: UInt /* , copyrightStatus: DAAM.CopyrightStatus*/ ) {

    prepare(acct: AuthAccount) {
        let copyright = DAAM.CopyrightStatus.VERIFIED

        let admin <- acct.load<@DAAM.Admin{DAAM.Founder}>(from: DAAM.adminStoragePath)!
        let creatorAccout = getAccount(creator)
        let collection = creatorAccout.getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath).borrow()!
  
        admin.mintNFT(recipient: collection, creator:creator, elm:elm, copyrightStatus:copyright)
        acct.save<@DAAM.Admin{DAAM.Founder}>(<- admin, to: DAAM.adminStoragePath)
        log("Change Creator Status")
    }
}// transaction
