FactoryGirl.define do
  factory :resource do
    sequence(:name) {|count| "Sample Name #{ count }" }
    sequence(:code) {|count| "Sample Code #{ count }" }
  end
end
