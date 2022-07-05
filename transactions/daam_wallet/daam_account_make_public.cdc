// daam_account_make_public.cdc
// Make DAAM Wallet Public

import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews    from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d
transaction()
{
    prepare(acct: AuthAccount) {
        if acct.borrow<&{DAAM.CollectionPublic}>(from: DAAM.collectionStoragePath) != nil {
            acct.link<&{DAAM.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, MetadataViews.Resolver}>(DAAM.collectionPublicPath, target: DAAM.collectionStoragePath)
            log("DAAM Account Created, you now have a Public DAAM Collection to store NFTs'")
        } else {
            log("You do not have an Account. Make one first.")
        }
    }
}
