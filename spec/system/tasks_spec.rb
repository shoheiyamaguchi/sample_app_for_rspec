require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  describe 'ログイン前' do
    context 'タスク作成ページにアクセス' do
      it 'タスク作成ページへのアクセスが失敗する' do
        visit new_task_path
        expect(current_path).to eq login_path
        expect(page).to have_content 'Login required'
      end
    end

    context 'タスク編集ページにアクセス' do
      it 'タスク編集ページへのアクセスが失敗する' do
        visit edit_task_path task
        expect(current_path).to eq login_path
        expect(page).to have_content 'Login required'
      end
    end

    context 'タスクの詳細ページにアクセス' do
      it 'タスクの詳細情報が表示される' do
        visit task_path(task)
        expect(current_path).to eq task_path(task)
        expect(page).to have_content task.title
      end
    end

    context 'タスクの一覧ページにアクセス' do
      it 'すべてのユーザーのタスク情報が表示される' do
        task_list = create_list(:task, 3)
        visit tasks_path
        expect(current_path).to eq tasks_path
        expect(page).to have_content task_list[0].title
        expect(page).to have_content task_list[1].title
        expect(page).to have_content task_list[2].title
      end
    end
  end

  describe 'ログイン後' do
    before { login(user) }

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
            expect(current_path).to eq '/tasks/1'
            expect(page).to have_content 'Task was successfully created'
          }.to change(user.tasks, :count).by(1)
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの作成が失敗する' do
          task_with_empty_title = build(:task, title: '')
          expect {
            click_link 'New Task'
            fill_in 'Title', with: task_with_empty_title.title
            fill_in 'Content', with: task_with_empty_title.content
            select task_with_empty_title.status, from: 'Status'
            fill_in 'Deadline', with: task_with_empty_title.deadline
            click_button 'Create Task'
            expect(current_path).to eq tasks_path
            expect(page).to have_content '1 error prohibited this task from being saved:'
            expect(page).to have_content "Title can't be blank"
          }.to change(user.tasks, :count).by(0)
        end
      end

      context '登録済みのタイトルを使用' do
        it 'タスクの作成が失敗する' do
          task_with_duplicate_title = build(:task, title: create(:task).title)
          expect {
            click_link 'New Task'
            fill_in 'Title', with: task_with_duplicate_title.title
            fill_in 'Content', with: task_with_duplicate_title.content
            select task_with_duplicate_title.status, from: 'Status'
            fill_in 'Deadline', with: task_with_duplicate_title.deadline
            click_button 'Create Task'
            expect(current_path).to eq tasks_path
            expect(page).to have_content '1 error prohibited this task from being saved:'
            expect(page).to have_content 'Title has already been taken'
          }.to change(user.tasks, :count).by(0)
        end
      end
    end

    describe 'タスク編集' do
      let(:task) { create(:task, user: user) }
      before { visit edit_task_path(task) }
      context 'フォームの入力値が正常' do
        it 'タスクの編集が成功する' do
          expect(current_path).to eq edit_task_path(task)
          expect(page).to have_field 'Title', with: task.title
          expect(page).to have_field 'Content', with: task.content
          expect(page).to have_field 'Status', with: task.status
          fill_in 'Title', with: 'test_title'
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content 'Task was successfully updated.'
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          fill_in 'Title', with: ''
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content "Title can't be blank"
        end
      end

      context '登録済みのタイトルを使用' do
        it 'タスクの編集が失敗する' do
          task_with_duplicate_title = create(:task, user: user)
          fill_in 'Title', with: task_with_duplicate_title.title
          click_button 'Update Task'
          expect(current_path).to eq task_path(task)
          expect(page).to have_content '1 error prohibited this task from being saved'
          expect(page).to have_content 'Title has already been taken'
        end
      end

      context '他ユーザーのタスクの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          task_belogs_to_another_user = create(:task)
          visit edit_task_path(task_belogs_to_another_user)
          expect(current_path).to eq root_path
          expect(page).to have_content 'Forbidden access.'
        end
      end
    end

    describe 'タスク削除' do
      let(:task) { create(:task, user: user) }
      it 'タスクの削除が成功する' do
        create(:task, user: user)
        visit tasks_path
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
