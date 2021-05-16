// answer_artist_invite.cdc

import DAAM_NFT from 0xfd43f9148d4b725d

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&DAAM_NFT.Admin{DAAM_NFT.InvitedArtist}>
    let adminRef: &DAAM_NFT.Admin{DAAM_NFT.InvitedArtist}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {        
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0xfd43f9148d4b725d)
        self.adminCap = self.daam.getCapability<&DAAM_NFT.Admin{DAAM_NFT.InvitedArtist}>(DAAM_NFT.adminPublicPath)
        self.adminRef = self.adminCap.borrow()!
        self.signer = signer        
    }
    
    execute {
        if self.signer.borrow<&DAAM_NFT.Collection>
        (from: DAAM_NFT.collectionStoragePath) == nil {
            log("You D.A.A.M artist, you need a Collection to store NFTs. Go to Setup Account first!!")
            return
        }
        
        let artist <- self.adminRef.answerArtistInvite(artist: self.signer.address, answer: submit)

        if artist != nil {
            self.signer.save(<- artist, to: DAAM_NFT.artistStoragePath)
            self.signer.link<&DAAM_NFT.Artist>(DAAM_NFT.artistPrivatePath, target: DAAM_NFT.artistStoragePath)
            log("You are now a D.A.A.M Artist")
        } else {
            destroy artist
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
