// Transaction1.cdc

import ExampleNFT from 0xf8d6e0586b0a20c7

// This transaction checks if an NFT exists in the storage of the given account
// by trying to borrow from it
transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&ExampleNFT.NFT>(from: ExampleNFT.collectionStoragePath) != nil {
            log("The token exists!")
        } else {
            log("No token found!")
        }
    }
}
 
