## INTEGRATION
## ==========

set :bundle_without, %w{integration production test}.join(" ")

set :branch, "release-2.1.5.2"

server "dl-stageapp-01.do.lark-it.com",
  user: fetch(:application),
  port: 1022,
  roles: %w{web app db},
  primary: true
