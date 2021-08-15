import DAAM_V1             from 0xa4ad5ea5c0bd2fba

transaction()
{
    let signer: AuthAccount
    let metadataRef: &DAAM_V1.MetadataGenerator

    prepare(signer: AuthAccount) {
        self.signer = signer
        self.metadataRef = self.signer.borrow<&DAAM_V1.MetadataGenerator>(from: DAAM_V1.metadataStoragePath)
        ?? panic("Could not borrow capability from Metadata")
    }

    execute {
        let metadataList = self.metadataRef.getMetadata()
        for metadata in metadataList.keys {
            log("MID: ".concat(metadata.toString()) )
            log("creator: ".concat(metadataList[metadata]!.creator.toString()) )
            log("series: ".concat(metadataList[metadata]!.series.toString()) )
            log("counter: ".concat(metadataList[metadata]!.counter.toString()) )
            log("data: ".concat(metadataList[metadata]!.data) )
            log("thumbnail: ".concat(metadataList[metadata]!.thumbnail) )
            log("file: ".concat(metadataList[metadata]!.file) )
        }
    }
}
