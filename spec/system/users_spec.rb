require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe 'ログイン前' do
    describe '新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          user = build(:user)
          visit sign_up_path
          expect {
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            fill_in 'Password confirmation', with: user.password_confirmation
            click_button 'SignUp'
            expect(current_path).to eq login_path
            expect(page).to have_content 'User was successfully created.'
          }.to change(User, :count).by(1)
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          user_with_blank_email = build(:user, email: '')
          visit sign_up_path
          expect {
            fill_in 'Email', with: user_with_blank_email.email
            fill_in 'Password', with: user_with_blank_email.password
            fill_in 'Password confirmation', with: user_with_blank_email.password_confirmation
            click_button 'SignUp'
            expect(current_path).to eq users_path
            expect(page).to have_content "Email can't be blank"
          }.to change(User, :count).by(0)
        end
      end

      context '登録済みのメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          user_with_duplicate_email = build(:user, email: create(:user).email)
          visit sign_up_path
          expect {
            fill_in 'Email', with: user_with_duplicate_email.email
            fill_in 'Password', with: user_with_duplicate_email.password
            fill_in 'Password confirmation', with: user_with_duplicate_email.password_confirmation
            click_button 'SignUp'
            expect(current_path).to eq users_path
            expect(page).to have_content 'Email has already been taken'
          }.to change(User, :count).by(0)
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          user = create(:user)
          visit user_path(user)
          expect(current_path).to eq login_path
          expect(page).to have_content 'Login required'
        end
      end
    end
  end

  describe 'ログイン後' do
    let(:user) { create(:user) }
    before do
      login(user)
    end
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user)
          expect(page).to have_field 'Email', with: user.email
          fill_in 'Password', with: 'updated_password'
          fill_in 'Password confirmation', with: 'updated_password'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          visit edit_user_path(user)
          expect(page).to have_field 'Email', with: user.email
          fill_in 'Email', with: ''
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content "Email can't be blank"
        end
      end

      context '登録済みのメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          another_user = create(:user)
          visit edit_user_path(user)
          expect(page).to have_field 'Email', with: user.email
          fill_in 'Email', with: another_user.email
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content 'Email has already been taken'
        end
      end

      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          another_user = create(:user)
          visit edit_user_path(another_user)
          expect(page).to have_content 'Forbidden access.'
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          task = create(:task, user: user)
          visit user_path user.id
          expect(page).to have_content task.title
          expect(page).not_to have_content task.content
          expect(page).to have_content task.status
          expect(page).not_to have_content task.deadline
        end
      end
    end
  end
end
