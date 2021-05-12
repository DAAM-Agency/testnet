// mint_nft.cdc

import DAAM from 0x045a1763c93006ca

transaction(/*metadata: DAAM.Metadata*/) {

    prepare(acct: AuthAccount) {

    let metadata = DAAM.Metadata(
            title:"Title",
            creator: acct.address,
            series: [],
            physical: false,
            agency: "agency",
            about: {"text": "about"},
            thumbnail: {"text":"thumbnail"},
            file: {"text":"file"}
    )    
    log("Metadata completed")


    let artist <- acct.load<@DAAM.Artist>(from: DAAM.artistStoragePath)!
    artist.mintNFT(metadata: metadata)
    acct.save<@DAAM.Artist>(<- artist, to: DAAM.artistStoragePath) 
    log("NFT Minted")
    }
}
