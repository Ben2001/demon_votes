require 'twitter'
require 'redis'
require 'dotenv'
Dotenv.load

client = Twitter::Streaming::Client.new do |config|
	config.consumer_key        = ENV['CONSUMER_KEY']
	config.consumer_secret     = ENV['CONSUMER_SECRET']
	config.access_token        = ENV['ACCESS_TOKEN']
	config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

redis = Redis.new
systeme_vote = redis
systeme_vote.set "demarrer", "off"

redis.hmset "votes", "track1", "name1", "counter1", "0", "track2", "name2", "counter2", "0", "track3", "name3", "counter3", "0"

sum1 = 0
sum2 = 0
sum3 = 0

loop do
	if systeme_vote.get("demarrer") == "on"
		track1 = redis.hget "votes", "track1"
		track2 = redis.hget "votes", "track2"
		track3 = redis.hget "votes", "track3"
		client.filter(:track => "#{track1}, #{track2}, #{track3}" ) do |object|
			if object.text.include?track1
				sum1 += 1
				redis.hset "votes", "counter1", "#{sum1}"
			elsif object.text.include?track2
				sum2 += 1
				redis.hset "votes", "counter2", "#{sum2}"
			elsif object.text.include?track3
				sum3 += 1
				redis.hset "votes", "counter3", "#{sum3}"
			end
			if systeme_vote.get("demarrer") == "off"
				break
			end
		end
		sleep(5)
	end
end