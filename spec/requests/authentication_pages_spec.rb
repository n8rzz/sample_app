require 'spec_helper'

describe "Authentication", type: :request do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end # signin page

  describe "signin" do 
  	before { visit signin_path }

  	describe "with invalid information" do 
  		before { click_button "Sign in" }

  		it { should have_title('Sign in') }
  		it { should have_selector('div.alert.alert-error') }
		
		describe "after visiting another page" do
			before { click_link "Home" }
			it { should_not have_selector('div.alert.alert-error') }
		end
  	end # with invalid information

  	describe "with valid information" do 
  		let(:user) { FactoryGirl.create(:user) }
  		before do 
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
  		end
		
  		it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
  		it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
  		it { should have_link('Sign out',    href: signout_path) }
  		it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do 
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end # followed by signout
  	end # with valid info
  end # signin

  describe "authorization" do 
    describe "for non-signed-in users" do 
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do 
        before do 
          visit edit_user_path(user)
          fill_in "Email",  with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do 
          it "should render the desired protected page" do 
            expect(page).to have_title('Edit user')
          end # desired protected page
        end # after signing in
      end #attempt to visit protcted page

      describe "in the Users controller" do 
        
        describe "visiting the edit page" do 
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end # visit edit page

        describe "submitting to the update action" do 
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end # submit to update action

        describe "visiting the user index" do 
          before { visit users_path }
          it { should have_title('Sign in') }
        end # visit user index
      end # in users controller
    end # for non signed in users
  end # authorization
end # Authentication