# fdwのテスト環境をdockerで作成する
## 概要
postgresqlから以下のDBへのFDWを設定した環境を作成する。
FDWの動作確認、テスト用の環境として使える。
* mysql_fdw
* tds_fdw(SQL Server)
* Oracle_fdw
* odbc_fdw(SQL Server)

## 環境をビルド
docker-composeが利用できる環境で以下を実行

`make build`

## fdwを設定
`make up`
`make init`

## 各DBへの接続確認
`localhost:81`

へアクセスし、

`ユーザ名：root`
`パスワード:root`

でログイン。各DBごとにスキーマが作成されているので

`select * from mysql_schema.test;`

で確認。
