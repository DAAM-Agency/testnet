// createProfile.cdc

import DAAM_Profle from 0x192440c99cb17282

// argument have two modes:
// when ipfs = true; first arument is cid, second argument is path 
// when ipfs = false; first arument thumbnail String, second argument is thumbnailType and can not be nil
pub fun setFile(ipfs: Bool, string_cid: String, type_path: String?): {MetadataViews.File} {
    pre { ipfs || !ipfs && type_path != nil }
    if ipfs { return MetadataViews.IPFSFile(cid: string_cid, path: type_path) }
    switch type_path! {
        case "http"  : return MetadataViews.HTTPFile(url: string_cid)
        case "https" : return MetadataViews.HTTPFile(url: string_cid)
        default: return DAAM.OnChain(file: string_cid)
    }
}

transaction(name: String, email: String?, about: String?, description: String?, web: String?, social: {String:String}?,
    avatar: String?, heroImageType: String?, heroImage: String?, notes: {String:String}?)
{
    let signer: AuthAccount
    let name  : String
    let email : String?
    let about : String?

    let description: String?

    let web      : String?
    let social   : {String:String}?
    let avatar   : AnyStruct{MetadataViews.File}?
    let heroImage: AnyStruct{MetadataViews.File}?
    let notes    : {String:String}?

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.name   = name
        self.email  = email
        self.about  = about

        self.description = description

        self.web       = web
        self.social    = social
        self.avatar    = (avatar == nil) ? nil : DAAM.OnChain(file: avatar), setFile(ipfs: ipfs_thumbnail, string_cid: thumbnail_cid, type_path: thumbnailType_path)}
        self.heroImage = heroImage
        self.notes     = notes        
    }

    pre {
        (avatarType != nil && avatar != nil)    || (avatarType == nil && avatar == nil)    : ""
        (heroImageType != nil && heroImage != nil) || (heroImageType == nil && heroImage == nil) : ""
    }

    execute {
        let profile <- DAAM_Profile.createProfile()
        self.signer.save<@DAAM_Profile.User>(<-profile, to: DAAM_Profile.storagePath)
        self.signer.link<&DAAM_Profile.User{DAAM_Profile.Public}>(from: DAAM_Profile.publicPath)
    }
}