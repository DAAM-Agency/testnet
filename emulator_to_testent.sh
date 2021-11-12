grep -rl 0x9a0766d93b6608b7 | xargs sed -i 's/0x9a0766d93b6608b7/0x9a0766d93b6608b7/g'
echo "Updated FungibleToken"

grep -rl 0x631e88ae7f1d7c20 | xargs sed -i 's/0x631e88ae7f1d7c20/0x631e88ae7f1d7c20/g'
echo "Updated NonFungibleToken"

grep -rl 0x192440c99cb17282 | xargs sed -i 's/0x192440c99cb17282/0xba1132bc08f82fe2/g'
echo "Updated Profile"

grep -rl 0x7e60df042a9c0868 | xargs sed -i 's/0x7e60df042a9c0868/0x7e60df042a9c0868/g'
echo "Updated FlowToken"

grep -rl 0xe223d8a629e49c68 | xargs sed -i 's/0xe223d8a629e49c68/0xe223d8a629e49c68/g'
echo "Updated FUSD"

grep -rl 0x01837e15023c9249 | xargs sed -i 's/0x01837e15023c9249/0x045a1763c93006ca/g'
echo "Updated AuctionHouse"

grep -rl 0xa4ad5ea5c0bd2fba | xargs sed -i 's/0xa4ad5ea5c0bd2fba/0xa4ad5ea5c0bd2fba/g'
echo "Updated DAAM_V5"

grep -rl DAAM_V5 | xargs sed -i 's/DAAM_V5/DAAM_V5_V5/g'
echo "Updated DAAM_V5"
