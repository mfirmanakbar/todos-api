FactoryBot.define do
  factory :item do
    # name { Faker::StarWars.character } # not installed, dont know why
    name { Faker::Lorem.words(5).join(' ') }
    done false
    todo_id nil
  end
end
