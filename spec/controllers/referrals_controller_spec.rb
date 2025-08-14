require 'spec_helper'

RSpec.describe ReferralsController, type: :controller do
  let(:user) { create(:user) }
  let(:referrer) { create(:user) }
  let(:referral_code) { create(:referral_code, user: referrer) }

  before do
    sign_in user
    Setting.set('mlm_enabled', 'true')
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      get :show
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns @referral_stats' do
      get :show
      expect(assigns(:referral_stats)).to be_a(Hash)
    end

    it 'assigns @referral_tree' do
      get :show
      expect(assigns(:referral_tree)).to be_a(Hash)
    end

    it 'assigns @commissions' do
      get :show
      expect(assigns(:commissions)).to be_a(ActiveRecord::Relation)
    end

    it 'assigns @referrals' do
      get :show
      expect(assigns(:referrals)).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'POST #apply' do
    context 'when referral code is valid' do
      it 'creates a referral and redirects with success message' do
        expect {
          post :apply, params: { referral_code: referral_code.code }
        }.to change(Referral, :count).by(1)

        expect(response).to redirect_to(referral_path)
        expect(flash[:notice]).to eq("Successfully applied referral code! You're now connected to the referral network.")
      end

      it 'creates the correct referral relationship' do
        post :apply, params: { referral_code: referral_code.code }
        
        referral = Referral.last
        expect(referral.user).to eq(user)
        expect(referral.referrer).to eq(referrer)
        expect(referral.level).to eq(1)
        expect(referral.status).to eq('active')
      end
    end

    context 'when referral code is blank' do
      it 'redirects with error message' do
        post :apply, params: { referral_code: '' }
        
        expect(response).to redirect_to(referral_path)
        expect(flash[:alert]).to eq("Please enter a referral code")
      end
    end

    context 'when referral code is invalid' do
      it 'redirects with error message' do
        post :apply, params: { referral_code: 'INVALID' }
        
        expect(response).to redirect_to(referral_path)
        expect(flash[:alert]).to eq("Invalid referral code or you're already referred")
      end
    end

    context 'when user is already referred' do
      before do
        create(:referral, user: user, referrer: referrer, status: 'active')
      end

      it 'redirects with error message' do
        post :apply, params: { referral_code: referral_code.code }
        
        expect(response).to redirect_to(referral_path)
        expect(flash[:alert]).to eq("Invalid referral code or you're already referred")
      end
    end

    context 'when MLM is disabled' do
      before { Setting.set('mlm_enabled', 'false') }

      it 'redirects with error message' do
        post :apply, params: { referral_code: referral_code.code }
        
        expect(response).to redirect_to(referral_path)
        expect(flash[:alert]).to eq("Invalid referral code or you're already referred")
      end
    end

    context 'when user tries to refer themselves' do
      let(:self_referral_code) { create(:referral_code, user: user) }

      it 'redirects with error message' do
        post :apply, params: { referral_code: self_referral_code.code }
        
        expect(response).to redirect_to(referral_path)
        expect(flash[:alert]).to eq("Invalid referral code or you're already referred")
      end
    end
  end

  describe 'authentication' do
    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to sign in page for show action' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in page for apply action' do
        post :apply, params: { referral_code: referral_code.code }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
