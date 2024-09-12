```zsh
docker run --name maegang-db -p 5432:5432 -d \
-e POSTGRES_USER=postgres \
-e POSTGRES=postgres \
-e POSTGRES_DB=maegang \
postgres
```