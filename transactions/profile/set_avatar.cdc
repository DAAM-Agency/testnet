// set_avatar.cdc

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_Profile  from 0x0bb80b2a4cb38cdf
import DAAM_Mainnet          from 0xa4ad5ea5c0bd2fba

// Returns correct MetadataViews.File deping on type of data. Pic, Http, ipfs
pub fun setFile(type: String, data: String, path: String?): AnyStruct{MetadataViews.File} {
    pre { (type == "ipfs" && path != nil) || type != "ipfs" }
    switch type {
        case "http"  : return MetadataViews.HTTPFile(url: data)
        case "https" : return MetadataViews.HTTPFile(url: data)
        case "ipfs"  : return MetadataViews.IPFSFile(cid: data, path: path!)
        default: return DAAM_Mainnet.OnChain(file: data)
    }
}

transaction(avatarType: String, avatar: String, avatar_ipfsPath: String?) {
    let avatar : AnyStruct{MetadataViews.File}?
    let user   : &DAAM_Profile.User

    prepare(signer: AuthAccount) {
        self.user   = signer.borrow<&DAAM_Profile.User>(from: DAAM_Profile.storagePath)!
        self.avatar = setFile(type: avatarType, data: avatar, path: nil) //path: avatar_ipfsPath)
    }

    execute {
        self.user.setAvatar(self.avatar)
    }
}