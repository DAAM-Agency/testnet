// add_to_collection.cdc

import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

pub fun setFile(string: String, type: String): {MetadataViews.File} {
    switch type! {
        case "http": return MetadataViews.HTTPFile(url: string)
        default: return DAAM.OnChain(file: string)
    }
}

transaction(name: String, description: String, externalURL: String, squareImage: String, squareImageType: String,
    bannerImage: String, bannerImageType: String, social: String?, web: String? )
{
    let collectionRef : &DAAM.Collection
    let name          : String
    let description   : String
    let externalURL   : MetadataViews.ExternalURL
    let squareImage   : MetadataViews.Media
    let bannerImage   : MetadataViews.Media
    let socials       : {String: MetadataViews.ExternalURL}

    prepare(acct: AuthAccount) {
        // Borrow a reference from the stored collection`
        self.collectionRef = acct.borrow<&DAAM.Collection>(from: DAAM.collectionStoragePath)!
            //?? panic("Could not borrow a reference to the owner's collection")
        self.name              = name // Get name of collection
        self.description       = description
        self.externalURL       = MetadataViews.ExternalURL(externalURL)
        let sqi = setFile(string: squareImage, type: squareImageType)
        self.squareImage       = MetadataViews.Media(file: sqi, mediaType: squareImageType)
        let bi  = setFile(string: bannerImage, type: bannerImageType)
        self.bannerImage       = MetadataViews.Media(file: bi, mediaType: bannerImageType)
        self.socials           =  social==nil ? {} : {social! : MetadataViews.ExternalURL(web!)}
    }
    
    pre { social == nil && web == nil || social != nil && web != nil : "" }

    execute {
        self.collectionRef.addCollection(name: self.name, description: self.description, externalURL: self.externalURL,
            squareImage: self.squareImage, bannerImage: self.bannerImage, socials: self.socials) 
        log("Collection ".concat(name).concat(" Created"))
    }
}
 