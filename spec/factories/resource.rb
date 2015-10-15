FactoryGirl.define do
  factory :resource do
    sequence(:code) {|count| "Sample Code #{ count }" }
    sequence(:name) {|count| "Sample Name #{ count }" }
  end
end
