// daam_account_make_public.cdc
// Make DAAM_Mainnet Wallet Public

import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM_Mainnet             from 0xfd43f9148d4b725d
transaction()
{
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        self.acct = acct
    }

    execute {
        self.acct.link<&DAAMDAAM_Mainnet_Mainnet.Collection{DAAM_Mainnet.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_Mainnet.collectionPublicPath, target: DAAM_Mainnet.collectionStoragePath)
        log("DAAM_Mainnet Account Created, you now have a Public DAAM_Mainnet Collection to store NFTs'")
    }
}
