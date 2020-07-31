require 'rails_helper'

RSpec.describe Task, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  describe 'validation' do
    it 'is valid with all attributes' do
      task = build(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'is invalid without title' do
      task = build(:task, title: nil)
      expect(task).to be_invalid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without title' do
      task = build(:task, status: nil)
      expect(task).to be_invalid
      expect(task.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with a duplicate title' do
      task = build(:task, title: create(:task).title)
      expect(task).to be_invalid
      expect(task.errors[:title]).to include('has already been taken')
    end

    it 'is valid with another title' do
      create(:task)
      task = build(:task, title: 'another_title')
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end
  end
end
