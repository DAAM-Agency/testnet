// clear_old_collection.cdc
// Debugging Tool
import DAAM_V12 from 0xa4ad5ea5c0bd2fba


transaction() {
    prepare(signer: AuthAccount) {
        let collection = signer.borrow<&DAAM_V12> (from: DAAM_V12.collectionStoragePath)
        let nfts = collection?.getIDs()
        if nfts != nil {
            for token in nfts! {
                let nft <- collection?.withdraw(withdrawID: token)
                destroy nft
            }
            log("NFTs' cleared.")
        }        
        destroy collection
        signer.unlink(DAAM_V12.collectionPublicPath)
        log("Wallet cleared.")
    } 
}