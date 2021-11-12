grep -rl 0xee82856bf20e2aa6 | sed -i 's/0xee82856bf20e2aa6/0x9a0766d93b6608b7/g'
echo "Updated FungibleToken"

grep -rl 0xf8d6e0586b0a20c7 | sed -i 's/0xf8d6e0586b0a20c7/0x631e88ae7f1d7c20/g'
echo "Updated NonFungibleToken"

grep -rl 0x192440c99cb17282 | sed -i 's/0x192440c99cb17282/0x192440c99cb17282/g'
echo "Updated Profile"

grep -rl 0x0ae53cb6e3f42a79 | sed -i 's/0x0ae53cb6e3f42a79/0x7e60df042a9c0868/g'
echo "Updated FlowToken"

grep -rl 0x192440c99cb17282 | sed -i 's/0x192440c99cb17282/0xe223d8a629e49c68/g'
echo "Updated FUSD"

grep -rl 0x045a1763c93006ca | sed -i 's/0x045a1763c93006ca/0x01837e15023c9249/g'
echo "Updated AuctionHouse"

grep -rl 0xfd43f9148d4b725d | sed -i 's/0xfd43f9148d4b725d/0xa4ad5ea5c0bd2fba/g'
echo "Updated DAAM"

grep -rl DAAM | sed -i 's/DAAM/DAAM_V5/g'
echo "Updated DAAM"
