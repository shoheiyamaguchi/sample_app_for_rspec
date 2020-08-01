require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  describe 'ログイン前' do
    let(:user) { create(:user) }
    let(:task) { create(:task) }
    describe 'タスク作成' do
      it 'タスク作成ページへのアクセスが失敗する' do
        visit new_task_path
        expect(current_path).to eq login_path
        expect(page).to have_content 'Login required'
      end
    end

    describe 'タスク編集' do
      it 'タスク編集ページへのアクセスが失敗する' do
        visit edit_task_path task
        expect(current_path).to eq login_path
        expect(page).to have_content 'Login required'
      end
    end
  end

  describe 'ログイン後' do
    let(:user) { create(:user) }
    before do
      login(user)
    end
    describe 'タスク作成' do
      context 'フォームの入力値が正常' do
        it 'タスクの作成が成功する' do
          task = build(:task)
          expect {
            click_link 'New Task'
            fill_in 'Title', with: task.title
            fill_in 'Content', with: task.content
            select task.status, from: 'Status'
            fill_in 'Deadline', with: task.deadline
            click_button 'Create Task'
            expect(page).to have_content 'Task was successfully created'
          }.to change(user.tasks, :count).by(1)
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの作成が失敗する' do
          task = build(:task, title: '')
          expect {
            click_link 'New Task'
            fill_in 'Title', with: task.title
            fill_in 'Content', with: task.content
            select task.status, from: 'Status'
            fill_in 'Deadline', with: task.deadline
            click_button 'Create Task'
            expect(current_path).to eq tasks_path
            expect(page).to have_content "Title can't be blank"
          }.to change(user.tasks, :count).by(0)
        end
      end

      context '登録済みのタイトルを使用' do
        it 'タスクの作成が失敗する' do
          task = build(:task, title: create(:task).title)
          expect {
            click_link 'New Task'
            fill_in 'Title', with: task.title
            fill_in 'Content', with: task.content
            select task.status, from: 'Status'
            fill_in 'Deadline', with: task.deadline
            click_button 'Create Task'
            expect(current_path).to eq tasks_path
            expect(page).to have_content 'Title has already been taken'
          }.to change(user.tasks, :count).by(0)
        end
      end
    end

    describe 'タスク編集' do
      let(:task) { create(:task) }
      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          expect {
            click_link 'New Task'
            fill_in 'Title', with: 'hoge'
            fill_in 'Content', with: 'hoge'
            click_button 'Create Task'
            expect(page).to have_content 'Task was successfully created'
          }.to change(user.tasks, :count).by(1)
          click_link 'Edit'
          expect(page).to have_field 'Title', with: 'hoge'
          expect(page).to have_field 'Content', with: 'hoge'
          fill_in 'Content', with: 'hogehoge'
          click_button 'Update Task'
          expect(page).to have_content 'Task was successfully updated.'
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
        end
      end

      context '登録済みのタイトルを使用' do
        it 'タスクの編集が失敗する' do
        end
      end

      context '他ユーザーのタスクの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
        end
      end
    end

    describe 'タスク削除' do
      it 'タスクの削除が成功する' do
        expect {
          click_link 'New Task'
          fill_in 'Title', with: 'hoge'
          fill_in 'Content', with: 'hoge'
          click_button 'Create Task'
          expect(page).to have_content 'Task was successfully created'
        }.to change(user.tasks, :count).by(1)
        click_link 'Back'
        click_link 'Destroy'
        expect {
          expect(page.driver.browser.switch_to.alert.text).to eq 'Are you sure?'
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_content 'Task was successfully destroyed.'
        }.to change(user.tasks, :count).by(-1)
      end
    end
  end
end
