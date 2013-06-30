#!/usr/bin/env ruby
#
# CLI Script to get the sharing URL of a file in Dropbox

# Include the Dropbox SDK libraries
require 'yaml'
require 'dropbox_sdk'

# Get your app key and secret from the Dropbox developer website
APP_KEY = '9vzni4g9r2irkz7'
APP_SECRET = 'xeibmp6c72f6cj2'

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
    $stdin.gets

    session.get_access_token

    f = File.open('.auth.yaml', 'w')
    f.puts session.serialize
    f.close
end

config_file = 'config.yaml'
if File.exists? config_file 
    f = File.open(config_file, 'r')

    config = YAML.load(f.read)

    home_dir = config[:home_dir]
else

    home_dir = ""

    until Dir.exists? home_dir
        puts 'Please enter your Dropbox home folder:'
        home_dir = $stdin.gets.chomp
    end

    f = File.open('config.yaml', 'w')
    f.puts({ :home_dir => home_dir }.to_yaml)
    f.close
end

home_dir << '/' unless home_dir.end_with? '/'

client = DropboxClient.new(session, ACCESS_TYPE)

# Get file arguments
unless ARGV.size == 1
    puts "Incorrect number of arguments" 
    puts "Expected:\nshare ~/path/to/file"
    exit 2
end

in_file = ARGV[0]

# Replace home_dir of path with blank
in_file = in_file.sub(home_dir, '')

begin
    public_link = client.shares(in_file)['url']
rescue DropboxError
    puts "File not found"
    exit(1)
end
puts "Public link: #{public_link}"
