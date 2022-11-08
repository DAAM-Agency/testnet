// daam_account_make_public.cdc
// Make DAAM_Mainnet Wallet Public

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_Mainnet             from 0xa4ad5ea5c0bd2fba
transaction()
{
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        self.acct = acct
    }

    execute {
        self.acct.link<&DAAM_Mainnet.Collection{DAAM_Mainnet.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_Mainnet.collectionPublicPath, target: DAAM_Mainnet.collectionStoragePath)
        log("DAAM_Mainnet Account Created, you now have a Public DAAM_Mainnet Collection to store NFTs'")
    }
}
