require 'sinatra'
require 'json'
require 'base64'
require 'bcrypt'

$users_file = 'users.json'

def load_users
  if File.exist?($users_file)
    JSON.parse(File.read($users_file))
  else
    {}
  end
end

def save_users(users)
  File.write($users_file, users.to_json)
end

users = load_users

get '/' do
  send_file 'index.html'
end

post '/register' do
  data = JSON.parse(request.body.read)

  username = data['username']
  password = data['password']

  if username.nil? || password.nil?
    status 400
    return { error: 'Username and password are required' }.to_json
  end

  if users[username]
    status 400
    return { error: 'Username already exists' }.to_json
  end

  hashed_password = BCrypt::Password.create(password)

  users[username] = { 'password' => hashed_password }
  save_users(users)

  status 200
  { message: 'User registered successfully' }.to_json
end

post '/login' do
  data = JSON.parse(request.body.read)

  username = data['username']
  password = data['password']

  if username.nil? || password.nil?
    status 400
    return { error: 'Username and password are required' }.to_json
  end

  if !users[username]
    status 400
    return { error: 'Username not found' }.to_json
  end

  stored_password = users[username]['password']
  if BCrypt::Password.new(stored_password) == password
    status 200
    { message: 'Login successful' }.to_json
  else
    status 400
    { error: 'Invalid password' }.to_json
  end
end