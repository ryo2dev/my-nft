# NFT開発練習

## プロジェクト作成

下記コマンドを実行した。
```shell
$ forge init my-nft
$ cd my-nft
```

## 環境設定

下記コマンドを実行した。
```shell
$ forge install Openzeppelin/openzeppelin-contracts
$ forge remappings > remappings.txt
$ mkdir -p .vscode
$ cat << EOF > .vscode/settings.json
{
  "solidity.packageDefaultDependenciesContractsDirectory": "src",
  "solidity.packageDefaultDependenciesDirectory": "lib"
}
EOF
```

不要ファイルは削除した。
```shell
$ git rm script/Counter.s.sol src/Counter.sol test/Counter.t.sol
```

## コントラクト実装

[OpenZeppelin Contracts Wizard](https://wizard.openzeppelin.com/) にアクセス。
ポチポチ。
今回は `ERC1155`。

表示されているコードをコピーして、src/MyNFT.sol に貼り付け。

src/MyNFT.sol を実装していく。

## ビルド

```shell
$ forge build
```

## テスト

test/MyNFT.t.sol に気になる動作を書く。

下記コマンドでテスト。
```shell
$ forge test -vv
```

## デプロイ

ローカルノード起動。
```shell
$ anvil
```

anvil用の環境変数設定。
```shell
$ cat << EOF > .env
RPC_URL=http://localhost:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
RECIPIENT_ADDRESS=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
EOF
$ source .env
```

デプロイ。
```shell
$ forge create ./src/MyNFT.sol:MyNFT \
  --broadcast \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY"
```

## 実行

スマートコントラクト実行。
```shell
$ cast send "$CONTRACT_ADDRESS" \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  "mint(address,uint256,uint256,bytes)" \
  "$RECIPIENT_ADDRESS" 123 1 0x

$ cast call "$CONTRACT_ADDRESS" \
  --rpc-url "$RPC_URL" \
  "balanceOf(address,uint256)" \
  "$RECIPIENT_ADDRESS" 123
```

## 参考

- [foundry - Ethereum Development Framework](https://getfoundry.sh/introduction/getting-started)
- [ERC-1155 | OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/5.x/erc1155)
- [ERC1155 API | OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/5.x/api/token/erc1155)
