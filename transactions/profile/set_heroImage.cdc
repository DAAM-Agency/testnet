// set_heroImage.cdc

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM_Mainnet_Profile  from 0x192440c99cb17282
import DAAM_Mainnet          from 0xfd43f9148d4b725d

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

transaction(heroImageType: String, heroImage: String, heroImage_ipfsPath: String?) {
    let heroImage : AnyStruct{MetadataViews.File}?
    let user   : &DAAMDAAM_Mainnet_Mainnet_Profile.User

    prepare(signer: AuthAccount) {
        self.user   = signer.borrow<&DAAMDAAM_Mainnet_Mainnet_Profile.User>(from: DAAM_Mainnet_Profile.storagePath)!
        self.heroImage = setFile(type: heroImageType, data: heroImage, path: nil) //path: heroImage_ipfsPath)
    }

    execute {
        self.user.setHeroImage(self.heroImage)
    }
}