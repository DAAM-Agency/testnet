// answer_artist_invite.cdc

import MarketPalace from 0x045a1763c93006ca

transaction(submit: Bool) {
    let daam: PublicAccount
    let adminCap: Capability<&MarketPalace.Admin{MarketPalace.InvitedArtist}>
    let adminRef: &MarketPalace.Admin{MarketPalace.InvitedArtist}
    let signer: AuthAccount
    
    prepare(signer: AuthAccount) {        
        // borrow a reference to the NFTMinter resource in storage
        self.daam = getAccount(0x045a1763c93006ca)
        self.adminCap = self.daam.getCapability<&MarketPalace.Admin{MarketPalace.InvitedArtist}>(MarketPalace.adminPublicPath)
        self.adminRef = self.adminCap.borrow()!
        self.signer = signer        
    }
    
    execute {
        if self.signer.borrow<&MarketPalace.Collection>
        (from: MarketPalace.collectionStoragePath) == nil {
            log("You D.A.A.M artist, you need a Collection to store NFTs. Go to Setup Account first!!")
            return
        }
        
        let artist <- self.adminRef.answerArtistInvite(self.signer.address, submit)

        if artist != nil {
            self.signer.save(<- artist, to: MarketPalace.artistStoragePath)
            self.signer.link<&MarketPalace.Artist>(MarketPalace.artistPrivatePath, target: MarketPalace.artistStoragePath)
            log("You are now a D.A.A.M Artist")
        } else {
            destroy artist
        }

        if !submit { log("Well,... fuck you too !!!") }
    }
}
