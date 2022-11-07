// daam_account_make_non_public.cdc
// Make DAAM_Mainnet Wallet Non-Public

import DAAM_Mainnet from 0xfd43f9148d4b725d

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&DAAMDAAM_Mainnet_Mainnet.Collection>(from: DAAM_Mainnet.collectionStoragePath) != nil {
            acct.unlink(DAAM_Mainnet.collectionPublicPath)
            log("DAAM_Mainnet Account Created, you now have a Non-Public DAAM_Mainnet .Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
