#!/usr/bin/env ruby
#
# CLI Script to get the sharing URL of a file in Dropbox

# Include the Dropbox SDK libraries
require 'yaml'
require 'dropbox_sdk'

# Get your app key and secret from the Dropbox developer website
APP_KEY = 'YOUR_APP_KEY'
APP_SECRET = 'YOUR_APP_SECRET'

# ACCESS_TYPE should be ':dropbox' or ':app_folder' as configured for your app
ACCESS_TYPE = :dropbox
session = DropboxSession.new(APP_KEY, APP_SECRET)

if File.exists? '.auth.yaml'
    f = File.open('.auth.yaml', 'r')

    session = DropboxSession.deserialize(f.read)
    f.close
else
    session.get_request_token

    authorize_url = session.get_authorize_url()

    # make the user sign in and authorize this token
    puts "AUTHORIZING", authorize_url
    puts "Please visit this website and press the 'Allow' button, then hit 'Enter' here."
    gets

    session.get_access_token

    f = File.open('.auth.yaml', 'w')
    f.puts session.serialize
    f.close
end

client = DropboxClient.new(session, ACCESS_TYPE)

puts client.shares('Public/image.png')['url']
