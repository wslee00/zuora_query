class Connector < ActiveRecord::Base
  attr_accessible :name, :password, :connector_type, :url, :username, :editor_state, 
    :num_limit, :order_by_field, :order_by_direction

  before_save :encrypt_password
  after_find :decrypt_password

  has_many :query_results

  def encrypt_password
    if password.present?
      self.key = AES.key
      self.password = AES.encrypt(password, key, { iv: AES.iv(:base_64) })
    end
  end

  def decrypt_password
    self.password = AES.decrypt(self.password, self.key) if self.key
  end
  
end
