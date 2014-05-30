# Be sure to restart your server when you modify this file.
SeqLIMS::Application.config.session_store :cookie_store, key: '_xyzLIMS_session', # Change this to any characters
                                          session_key: 'abc_session',             # Change this to any characters
                                          secret: 'put some random string here, eg a 100 character hex string'
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# SeqLIMS::Application.config.session_store :active_record_store