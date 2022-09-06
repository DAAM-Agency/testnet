// add_creator_collection.cdc
// Admin / Agent can create a collection on behalf of their Creators

import MetadataViews from 0xf8d6e0586b0a20c7
import DAAM          from 0xfd43f9148d4b725d

pub fun setFile(string: String, type: String): {MetadataViews.File} {
    switch type! {
        case "http": return MetadataViews.HTTPFile(url: string)
        default: return DAAM.OnChain(file: string)
    }
}

transaction(creator: Address, name: String, description: String, externalURL: String, squareImage: String, squareImageType: String, bannerImage: String,
    bannerImageType: String, socials: {String: MetadataViews.ExternalURL} )
{
    let admin   : &DAAM{DAAM.Agent}
    let collectionRef: &DAAM.Collection
    let name: String
    let description : String
    let externalURL : MetadataViews.ExternalURL
    let squareImage : MetadataViews.Media
    let bannerImage : MetadataViews.Media
    let socials     : {String: MetadataViews.ExternalURL}

    prepare(agent: AuthAccount)
     {
        self.admin           = agent.borrow<&{DAAM.Agent}>(from: DAAM.adminStoragePath)!
        self.collectionRef   = getAccount(creator).getCapability<&DAAM.Collection>(DAAM.collectionPublicPath).borrow()!
            //?? panic("Could not borrow a reference to the owner's collection")
        self.name = name // Get name of collection
        self.description     = description
        self.externalURL     = MetadataViews.ExternalURL(externalURL)
        let sqi = setFile(string: squareImage, type: squareImageType)
        self.squareImage     = MetadataViews.Media(file: sqi, mediaType: squareImageType)
        let bi  = setFile(string: bannerImage, type: bannerImageType)
        self.bannerImage     = MetadataViews.Media(file: bi, mediaType: bannerImageType)
        self.socials         = socials
    }

    execute {
        self.admin.addCreatorCollection(collectionRef: self.collectionRef, name: self.name, description: self.description, externalURL: self.externalURL,
            squareImage: self.squareImage, bannerImage: self.bannerImage, socials: self.socials)

        log("Collection Added: ".concat(name))   
    }
}
