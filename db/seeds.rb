ClientConfig.find_or_create_by!(name: "Client App", client_id: "client_app_123", redirect_uri: "http://localhost:3000/callback")
ClientConfig.find_or_create_by!(name: "Mobile App", client_id: "mobile_app_321", redirect_uri: "http://localhost:3000/callback")
ClientConfig.find_or_create_by!(name: "Web App", client_id: "web_app_000", redirect_uri: "http://localhost:3000/callback")
ClientConfig.find_or_create_by!(name: "Web App 2", client_id: "web_app2_001", redirect_uri: "http://localhost:3000/callback")

Oauth::User.find_or_create_by!(first_name: "test", last_name: "user", email: "test.user@gmail.com") do |user|
  user.password = "123456"
end
Oauth::User.find_or_create_by!(first_name: "test1", last_name: "user1", email: "test.user1@gmail.com") do |user|
  user.password = "password123"
end
Oauth::User.find_or_create_by!(first_name: "test2", last_name: "user2", email: "test.user2@gmail.com") do |user|
  user.password = "123password"
end
