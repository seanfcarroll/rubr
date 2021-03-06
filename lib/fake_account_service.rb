module FakeAccountService

  module Helpers

    def self.get_profile_image
      begin
        http = HTTPClient.new
        random_uri = http.get("http://imgur.com/random", :follow_redirect => true)
        uri = random_uri.header.request_uri.request_uri.gsub("/gallery/", "")
        return "http://i.imgur.com/#{uri}.jpg"
      rescue => e
        puts "Received an arror when trying to get a random image!"
        puts e.inspect
        return "http://i.imgur.com/774CSj2.png"
      end
    end

  end

  def self.generate_account amount=1
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    # Get our random texts
    assets = "#{Rails.root}/lib/assets"
    male_names = File.read("#{assets}/male_names.txt").split("\n")
    female_names = File.read("#{assets}/female_names.txt").split("\n")
    last_names = File.read("#{assets}/last_names.txt").split("\n")
    nouns = File.read("#{assets}/nounlist.txt").split("\n")
    adjectives = File.read("#{assets}/adjectives.txt").split("\n")
    verbs = File.read("#{assets}/verbs.txt").split("\n")

    amount.times do |i|
      total_accounts = Account.count
      gender = ["male", "female"].sample

      looking_for = ["male", "female"]
      looking_for.delete(gender)
      looking_for = looking_for[0]

      # Randomly choose first name based on gender
      choose_name_from = (gender == "male" ? male_names : female_names)
      first_name = choose_name_from.sample.capitalize.gsub("\r", "")

      last_name = last_names.sample.capitalize.gsub("\r", "")
      zip = "68502"

      # Random descriptions
      only_have_rand = rand(1..15)
      noun = nouns.sample.gsub("\r", "")
      verb = verbs.sample.gsub("\r", "")
      adjective = adjectives.sample.gsub("\r", "")
      rand_descriptions = [
        "I #{["like", "love", "hate"].sample} #{noun.pluralize}",
        "I have #{rand(2..15)} #{noun.pluralize}",
        "I only have #{only_have_rand} #{(only_have_rand > 1 ? noun.pluralize : noun)}",
        "I want some #{noun.pluralize}",
        "I don't want any #{noun.pluralize}",
        "Sometimes I think about #{noun.pluralize}",
        "Sometimes I think about #{noun}",
        "I identify as #{"aeiou".include?(noun[0]) ? "an" : "a"} #{noun}",
        "I like to #{verb}",
        "I only #{verb} with #{(male_names+female_names).sample.capitalize}",
        "I like to #{verb} late at night",
        "My mom likes to #{verb} with me",
        "I never leave home without my #{noun}",
        "I never leave to #{verb} without a #{noun}",
        "I only like #{verb} with #{adjective} #{noun}",
        "I only buy #{adjective} #{noun.pluralize}",
        "I like to #{verb} #{adjective} #{noun.pluralize} late at night",
        "When I #{verb} I like to also #{verb} some #{noun.pluralize}",
        "I #{verb} while I browse the internet",
        "You should #{verb} with me!",
        "I wonder when I will finally find that #{adjective} #{noun}",
        "My uncle said he wants to #{verb} me",
        "My uncle said he wants to #{verb} my #{adjective} #{noun}",
        "Please don't #{verb} me",
        "Only message me if you're #{adjective}",
        "I have a #{noun} collection",
        "I have a collection of #{noun.pluralize}",
        "I'll show you my #{noun}",
        "It's been #{rand(1..10)} years since I've been able to #{verb}",
        "It's been #{rand(1..10)} years since I've wanted to #{verb} a #{noun}",
        "Ask me about my #{adjective} #{noun}",
        "Ask me about my #{noun}"
      ]
      description = rand_descriptions.sample
      age = rand(18..45)
      profile_picture = Helpers::get_profile_image



      tries = 1
      rand_username = nil
      while rand_username == nil || rand_username.length > 24
        noun = nouns.sample.gsub("\r", "")
        adjective = adjectives.sample.gsub("\r", "")
        rand_username = "#{adjective}#{noun}#{total_accounts+i}"
        tries += 1
      end
      puts "Took #{tries} tries to generate a username"

      puts "Creating #{first_name} #{last_name} with description '#{description}' and profile_picture #{profile_picture}"
      Account.create!(
        first_name: first_name,
        last_name: last_name,
        gender: gender,
        looking_for: looking_for,
        zip: zip,
        description: description,
        age: age,
        profile_image: profile_picture,
        password: "password",
        user_name: rand_username,
        email: "sturgeonb4@gmail.com",
        fake_account: true
      )
    # Being nice to Imgur
    sleep 1
    end
  end
end
