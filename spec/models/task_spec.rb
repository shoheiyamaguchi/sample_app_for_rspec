require 'rails_helper'

RSpec.describe Task, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'validation' do
    it 'is valid with all attributes' do
      expect(FactoryBot.build(:task)).to be_valid
    end

    it 'is invalid without title' do
      task = FactoryBot.build(:task, title: nil)
      task.valid?
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with a duplicate title' do
      FactoryBot.create(:task)
      task = FactoryBot.build(:task)
      task.valid?
      expect(task.errors[:title]).to include('has already been taken')
    end

    it 'is valid with another title' do
      FactoryBot.create(:task)
      task = FactoryBot.build(:task, title: 'hogehoge')
      expect(task).to be_valid
    end
  end
end
