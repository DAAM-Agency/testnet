// Transaction1.cdc

import DAAM from 0x01

// This transaction checks if an NFT exists in the storage of the given account
// by trying to borrow from it
transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAM.NFT>(from: /storage/DAAM) != nil {
            log("The token exists!")
        } else {
            log("No token found!")
        }
    }
}
 
