


transaction(publicKey: String) {
    let signer : AuthAccount
    //let account: AuthAccount
    //let key    : PublicKey

    prepare(signer: AuthAccount) {
        self.signer  = signer
        //self.account = AuthAccount(payer: signer)
        /*self.key     = PublicKey(
            publicKey: publicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
        )*/
    }

    execute {
        /*self.signer.keys.add(
            publicKey: self.key,
            hashAlgorithm: HashAlgorithm.SHA3_256,
            weight: 10.0
        )*/

        generate

        //log("account: ".concat(self.account.address.toString()) )
        var counter = 3 //self.signer.keys.length
        log("counter: ".concat(counter.toString()))
        while counter != 0 {
            log("signer : ")
            log(self.signer.keys.get(keyIndex: counter))
            counter = counter - 1
        }
    }
}