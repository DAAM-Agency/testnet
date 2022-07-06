// daam_account_make_public.cdc
// Make DAAM_V18 Wallet Public

import NonFungibleToken from 0x631e88ae7f1d7c20 
import MetadataViews    from 0x631e88ae7f1d7c20
import DAAM_V18         from 0xa4ad5ea5c0bd2fba

transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM_V18.CollectionPublic}>(from: DAAM_V18.collectionStoragePath) != nil {
            acct.link<&{DAAM_V18.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>
            (DAAM_V18.collectionPublicPath, target: DAAM_V18.collectionStoragePath)
            log("DAAM_V18 Account Created, you now have a Public DAAM_V18 Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
