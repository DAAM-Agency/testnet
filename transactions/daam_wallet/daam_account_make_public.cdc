// daam account_make_public.cdc
// Make DAAM Wallet Public

import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V23         from 0xa4ad5ea5c0bd2fba
transaction()
{
    let acct: AuthAccount

    prepare(acct: AuthAccount) {
        self.acct = acct
    }

    execute {
        self.acct.link<&DAAM_V23.Collection{DAAM_V23.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM_V23.collectionPublicPath, target: DAAM_V23.collectionStoragePath)
        log("DAAM Account Created, you now have a Public DAAM Collection to store NFTs'")
    }
}
