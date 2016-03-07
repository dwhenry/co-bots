require 'yaml'
require 'net/http'
require 'json'
require 'pry'

require 'dumb_bot/simple_api'
require 'dumb_bot/actions'
require 'dumb_bot/bot'
require 'dumb_bot/games'

module DumbBot
  extend self

  # call from system scheduler
  def run
    bots.each do |bot|
      bot.take_next_action
    end
  end

  def bots
    YAML.load(File.read(File.expand_path("#{__dir__}/../config/bots.yml")))['bots'].map do |config|
      DumbBot::Bot.new(config)
    end
  end
end
