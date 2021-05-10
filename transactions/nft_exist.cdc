// nft_exist.cdc

import DAAM from 0x045a1763c93006ca

// This transaction checks if an NFT exists in the storage of the given account
// by trying to borrow from it
transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.NFT>(from: DAAM.collectionStoragePath) != nil {
            log("The token exists!")
        } else {
            log("No token found!")
        }
    }
}
 
