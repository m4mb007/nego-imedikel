require 'spec_helper'

RSpec.describe Admin::MlmController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:referrer) { create(:user) }

  before do
    sign_in admin
    Setting.set('mlm_enabled', 'true')
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'assigns @summary' do
      get :index
      expect(assigns(:summary)).to be_a(Hash)
    end

    it 'assigns @total_referrals' do
      get :index
      expect(assigns(:total_referrals)).to be_a(Integer)
    end

    it 'assigns @total_referral_codes' do
      get :index
      expect(assigns(:total_referral_codes)).to be_a(Integer)
    end

    it 'assigns @top_earners' do
      get :index
      expect(assigns(:top_earners)).to be_a(ActiveRecord::Relation)
    end

    it 'assigns @recent_commissions' do
      get :index
      expect(assigns(:recent_commissions)).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      get :show, params: { id: user.id }
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns @referral_stats' do
      get :show, params: { id: user.id }
      expect(assigns(:referral_stats)).to be_a(Hash)
    end

    it 'assigns @referral_tree' do
      get :show, params: { id: user.id }
      expect(assigns(:referral_tree)).to be_a(Hash)
    end

    it 'assigns @commissions' do
      get :show, params: { id: user.id }
      expect(assigns(:commissions)).to be_a(ActiveRecord::Relation)
    end

    it 'assigns @referrals' do
      get :show, params: { id: user.id }
      expect(assigns(:referrals)).to be_a(ActiveRecord::Relation)
    end

    context 'when user does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :show, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #payout' do
    it 'returns http success' do
      get :payout, params: { user_id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      get :payout, params: { user_id: user.id }
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns @pending_commissions' do
      get :payout, params: { user_id: user.id }
      expect(assigns(:pending_commissions)).to be_a(ActiveRecord::Relation)
    end

    it 'assigns @total_pending' do
      get :payout, params: { user_id: user.id }
      expect(assigns(:total_pending)).to be_a(BigDecimal)
    end

    it 'assigns @minimum_payout' do
      get :payout, params: { user_id: user_id: user.id }
      expect(assigns(:minimum_payout)).to be_a(Float)
    end

    context 'when user does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          get :payout, params: { user_id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'PATCH #process_payout' do
    let!(:pending_commission1) { create(:mlm_commission, user: user, referrer: referrer, status: 'pending', commission_amount: 30.0) }
    let!(:pending_commission2) { create(:mlm_commission, user: user, referrer: referrer, status: 'pending', commission_amount: 25.0) }

    context 'when payout amount meets minimum requirement' do
      it 'processes payout and redirects with success message' do
        expect {
          patch :process_payout, params: { user_id: referrer.id, amount: 55.0 }
        }.to change { pending_commission1.reload.status }.from('pending').to('paid')

        expect(response).to redirect_to(admin_mlm_path(referrer))
        expect(flash[:notice]).to eq("Successfully processed payout of RM55.0 for #{referrer.full_name}")
      end

      it 'processes payout for all pending commissions when no amount specified' do
        expect {
          patch :process_payout, params: { user_id: referrer.id }
        }.to change { pending_commission1.reload.status }.from('pending').to('paid')

        expect(pending_commission2.reload.status).to eq('paid')
      end
    end

    context 'when payout amount is below minimum' do
      it 'redirects with error message' do
        patch :process_payout, params: { user_id: referrer.id, amount: 25.0 }
        
        expect(response).to redirect_to(admin_mlm_path(referrer))
        expect(flash[:alert]).to eq("Failed to process payout. Minimum payout amount is RM50.0")
        expect(pending_commission1.reload.status).to eq('pending')
      end
    end

    context 'when MLM is disabled' do
      before { Setting.set('mlm_enabled', 'false') }

      it 'redirects with error message' do
        patch :process_payout, params: { user_id: referrer.id, amount: 55.0 }
        
        expect(response).to redirect_to(admin_mlm_path(referrer))
        expect(flash[:alert]).to eq("Failed to process payout. Minimum payout amount is RM50.0")
        expect(pending_commission1.reload.status).to eq('pending')
      end
    end

    context 'when user does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          patch :process_payout, params: { user_id: 99999, amount: 55.0 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      let(:regular_user) { create(:user) }

      before { sign_in regular_user }

      it 'redirects to root for index action' do
        get :index
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root for show action' do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root for payout action' do
        get :payout, params: { user_id: user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'redirects to root for process_payout action' do
        patch :process_payout, params: { user_id: user.id, amount: 55.0 }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not signed in' do
      before { sign_out admin }

      it 'redirects to sign in page for index action' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in page for show action' do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in page for payout action' do
        get :payout, params: { user_id: user.id }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to sign in page for process_payout action' do
        patch :process_payout, params: { user_id: user.id, amount: 55.0 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
