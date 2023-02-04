// daam_account_make_public.cdc
// Make DAAM Wallet Public

import NonFungibleToken from 0x1d7e57aa55817448
import MetadataViews    from 0x1d7e57aa55817448
import DAAM             from 0x7db4d10c78bad30a
transaction()
{
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        self.acct = acct
    }

    execute {
        self.acct.link<&DAAM.Collection{DAAM.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
        log("DAAM Account Created, you now have a Public DAAM Collection to store NFTs'")
    }
}
