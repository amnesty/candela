class OldUser < ActiveRecord::Base

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def valid_password?(password)
    crypted_password == encrypt(password)
  end

  def update_encrypted_password(new_password)
    return if new_password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(new_password)
    self.save
  end

end
