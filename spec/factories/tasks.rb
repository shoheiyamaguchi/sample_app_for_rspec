FactoryBot.define do
  factory :task do
    title { 'RUNTEQ' }
    content { 'rspecの勉強' }
    status { 'todo' }
    deadline { 0 }
    association :user
  end
end
