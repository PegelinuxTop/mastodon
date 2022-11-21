# Setting up a dev environment

## Assumptions

You have a package manager, and your system is systemd-based.

## Prerequisites

## Nodejs

Install nodejs via your package manager. We used v19.1.0 for this setup.

## Ruby

Install ruby via your package manager of choice.

## Ruby Extras

Your distro may package `bundle` and `irb` in separate packages (Arch does). If they are, install them too.
On Arch these are `ruby-bundler` and `ruby-irb`.

## PostGreSQL

Install postgres via your package manager.

## Redis

Install redis via your package manager.

Enable and start the default `redis.service`

## Setting up the Environment

In the following instructions, replace USER with your *nix user name.

1. Add yourself to the postgres group with `sudo usermod -a -G postgres USER`. You'll need to log out and back in to
update your groups.
2. Run `sudo mkdir /run/postgresql` to create said folder if it doesn't exist.
3. Run `sudo chown postgres:postgres /run/postgresql` to change the owner to postgres.
4. Run `sudo chmod g+w /run/postgresql` to allow `postgres` group members to write to the folder.
1. Navigate to the root of this repo.
2. Set up a local DB cluster with `pg_ctl -D data/postgres15 initdb -o '-U mastodon --auth-host=trust'`.
3. Run it with `pg_ctl -D data/postgres15 start`.
4. Run `bundle config set --local path 'vendor/bundle`. This will store the all the ruby gems locally so that we can
avoid interfering with system config.
5. Run `bundle install`.
6. Run `yarn install`.
1. Run `export $(grep -v '^#' .env.dev | xargs)` to source in our dev vars. You may want to alias this.
7. Run `bundle exec rake db:setup`. If this fails, you can use `bundle exec rake db:reset` to forcibly regenerate it.

## Running Mastodon

To make our lives easier, we'll use `foreman` to run the site, so use `gem install foreman` to get that going.

Then:
1. Run `export RAILS_ENV=development` and `export NODE_ENV=development`.
  a. Put these in your shell's .rc, or a script you can source if you want to skip this step in the future.
2. Run `bundle exec rake assets:precompile`.
  a. If this explodes, complaining about `Hash`, you'll need to `export NODE_OPTIONS=--openssl-legacy-provider`. Same
     deal as the above.
  b. After doing this, you will need to `bundle exec rake assets:clobber` and then re-run
  `bundle exec rake assets:precompile`.
3. Run `foreman start`


# Updates/Troubleshooting

## RubyVM/DebugInspector Issues

Still unable to fix. Circumvent by removing `better_errors` and `binding_of_caller` from Gemfile.
Happy to troubleshoot with someone better with Ruby than us >_<'/.

## Webpack Issues
If Webpack compalins about being unable to find some assets or locales:

1. yarn add webpack
2. git restore package.json yarn.lock
3. yarn install

Then re-run `foreman`. No. We have no idea why this worked.

If the above instructions don't work, please contact @Rin here, or @tammy@social.treehouse.systems.
