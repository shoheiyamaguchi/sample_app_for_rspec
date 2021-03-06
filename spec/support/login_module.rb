module LoginModule
  def login(user)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'password', with: 'password'
    click_button 'Login'
    expect(page).to have_content 'Login successful'
    expect(current_path).to eq root_path
  end
end

RSpec.configure do |config|
  config.include LoginModule
end
