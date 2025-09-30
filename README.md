## cloneした後にやること

1. `touch config/master.key`

2. config/master.keyにkeyを書き込み

3. `touch log/development.log`

4. `sudo chmod -R 777 log tmp`

3. `docker compose up --build`

4. `docker compose run -it -u root web bundle exec rake db:create`

2回目以降は `docker compose up -d`

gemを追加するときはGemfileに追記してから `docker compose build` `docker compose up -d` をすればよいはず


- webコンテナへの入り方

docker compose exec web bash


- dbコンテナへの入り方

docker compose exec db psql -U postgres -d postgres  (管理用DB)

docker compose exec db psql -U postgres -d myapp_development  (アプリDB)

この違いはよくわからないが，基本はアプリDBで行う


## やったこと
Gemfile.lockへの書き込み権限エラーをroot権限でどうにかした

https://qiita.com/nakad119/items/11b44320e2c2e3049a01


Ruby同梱のrakeとGemfile.lockのrakeのバージョンが異なっていたため，bundle execを付けた

https://note.com/kei2kei/n/n64d4a7fe5123#7c28a9f9-0468-45fe-b2dd-8246a8b9a8e8