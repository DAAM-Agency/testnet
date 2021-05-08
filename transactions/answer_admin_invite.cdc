import DAAM from 0x045a1763c93006ca

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(submit: Bool) {
    let adminRef: &DAAM.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.adminRef = signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath) ?? panic("Could not borrow a reference to the Admin")
        // Missing Capability TODO
        let admin <- self.adminRef.answerAdminInvite(signer.address, submit)
        if admin != nil {
            signer.save(<- admin, to: DAAM.adminStoragePath)
            log("You are now a D.A.A.M Admin")
        } else {
            destroy admin
        }
        if !submit { log("Well,... fuck you too !!!") }
    }
}
