class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #    :recoverable, :rememberable, :trackable, :validatable
  devise :database_authenticatable,
         :rememberable, :trackable, :timeoutable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :admin_name, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
end
