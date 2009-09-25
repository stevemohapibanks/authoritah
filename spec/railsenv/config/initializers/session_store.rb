# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cukejuice_session',
  :secret      => 'f39ba5ef73a04aa66e9a8ab1291899f124a5a58f9702b12b5079a598666d7e395a48b7ee54c08061345686c9c2f1f7a6fc51a24596673dc8deae54cf1fdea630'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
