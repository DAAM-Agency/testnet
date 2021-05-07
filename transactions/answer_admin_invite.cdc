import DAAM from 0x045a1763c93006ca

// This script uses the NFTMinter resource to mint a new NFT
// It must be run with the account that has the minter resource
// stored in /storage/NFTMinter

transaction(submit: Bool) {
    let admin: &DAAM.Admin

    prepare(signer: AuthAccount) {
        // borrow a reference to the NFTMinter resource in storage
        self.admin = signer.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)
            ?? panic("Could not borrow a reference to the Admin")
    } 

    execute {
        self.admin.answerAdminInvite(signer, self.submit)
        (submit) ? log("You are now a D.A.A.M Admin") : log("Well fuck you too !!!")
    }
}
