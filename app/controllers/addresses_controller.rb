class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy]

  def index
    @addresses = current_user.addresses.order(is_default: :desc, created_at: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)

    if @address.save
      flash[:notice] = "Address was successfully created."
      redirect_to addresses_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      flash[:notice] = "Address was successfully updated."
      redirect_to addresses_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    flash[:notice] = "Address was successfully deleted."
    redirect_to addresses_path
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

           def address_params
           params.require(:address).permit(
             :label, :recipient_name, :address_line1, :address_line2,
             :city, :state, :postal_code, :country, :phone, :is_default
           )
         end
end
