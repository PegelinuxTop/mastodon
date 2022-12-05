# frozen_string_literal: true

require 'pathname'

DATA_DIR = Pathname.new('data')
POSTGRES_DIR = DATA_DIR / 'postgres'
POSTGRES_CONF_FILE = POSTGRES_DIR / 'postgresql.conf'
POSTGRES_SOCKET_FILE = POSTGRES_DIR / '.s.PGSQL.5432'
POSTGRES_PID_FILE = POSTGRES_DIR / 'postmaster.pid'
REDIS_DIR = DATA_DIR / 'redis'
REDIS_PID_FILE = REDIS_DIR / 'redis-dev.pid'

def get_pid(pid_file)
  return false unless File.file?(pid_file)
  pid = File.read(pid_file).to_i

  Process.kill(0, pid)
  pid
rescue Errno::ESRCH
  nil
end

def postgres_running?
  get_pid POSTGRES_PID_FILE
end

directory REDIS_DIR.to_s

namespace :deps do
  task start: ['postgres:start', 'redis:start']
  task stop: ['postgres:stop', 'redis:stop']

  namespace :postgres do
    namespace :setup do
      task all: [POSTGRES_DIR.to_s]

      file POSTGRES_DIR.to_s do
        if POSTGRES_CONF_FILE.exist?
          puts 'Postgres conf exists, skipping initdb'
          next
        end
        sh %(printf '%s\\n' pg_ctl -D data/postgres initdb -o '-U mastodon --auth-host=trust')
      end

      task configure: [POSTGRES_DIR.to_s] do
        next if File.foreach(POSTGRES_CONF_FILE).detect? { |line| line == /^unix_socket_directories = \.\s*$/ }

        POSTGRES_CONF_FILE.open('at') do |f|
          f.write("\n", PG_SOCKET_DIRECTORIES_LINE, "\n")
        end
      end
    end

    task start: ['setup:all'] do
      if (pid = get_pid POSTGRES_PID_FILE)
        puts "Postgres is running (pid #{pid})!"
        next
      end

      puts 'Starting postgres...'
      puts '=========='
      sh %(pg_ctl -D ./data/postgres start)
      puts '=========='
    end

    task :stop do
      unless (pid = get_pid POSTGRES_PID_FILE)
        puts "Postgres isn't running!"
        next
      end

      puts "Stopping Postgres (pid #{pid})...\n=========="
      sh %(pg_ctl -D ./data/postgres stop)
      puts '=========='
    end
  end

  namespace :redis do
    task init: [REDIS_DIR.to_s] do
    end

    task start: [:init] do
      if (pid = get_pid REDIS_PID_FILE)
        puts "Redis is running (pid #{pid})!"
        next
      end

      puts 'Starting redis...'
      puts '=========='
      sh %(redis-server redis-dev.conf)
      puts '=========='
    end

    task :stop do
      unless (pid = get_pid REDIS_PID_FILE)
        puts "Redis isn't running!"
        next
      end

      puts "Stopping Redis (pid #{pid})...\n=========="
      Process.kill(:TERM, pid)
    end
  end
end
