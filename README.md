## cloneした後にやること

1. `docker compose build`

2. `docker compose up -d`

3. webコンテナ内で `bundle exec rake db:create`

4. webコンテナ内で `bin/rails db:migrate`


2回目以降は `docker compose up -d`

gemを追加するときはGemfileに追記してから `docker compose build` `docker compose up -d` をすればよいはず


- webコンテナへの入り方

docker compose exec web bash

(root権限の場合)

docker compose exec -u root web bash


- dbコンテナへの入り方

docker compose exec db psql -U postgres -d postgres  (管理用DB)

docker compose exec db psql -U postgres -d myapp_development  (アプリDB)

この違いはよくわからないが，基本はアプリDBで行う


## やったこと
Gemfile.lockへの書き込み権限エラーをroot権限でどうにかした

https://qiita.com/nakad119/items/11b44320e2c2e3049a01


Ruby同梱のrakeとGemfile.lockのrakeのバージョンが異なっていたため，bundle execを付けた

https://note.com/kei2kei/n/n64d4a7fe5123#7c28a9f9-0468-45fe-b2dd-8246a8b9a8e8