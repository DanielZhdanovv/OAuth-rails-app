# README

## Project Design
This is a design implementation plan for a Oauth onboarding project.

### Authorize
Process for client 

### Design for Authorization
Step 1: Client generates code verifier and code challenge. Client then call authorization endpoint (GET /authorize) with code_challgenge.
Step 2: We create authorization service, the authorization service will encode the code challenge into a state token, then it will redirect to the sign in page with a redirect token. Here the authorization service is communticating with authentication service. Here inside authenticantion service we verify the supplied credentials from the user then we redirect to the callback endpoint with the state token which is inside the authorization service.
Step 3: After we hit the callback we are inside the authorization service. Here we decode the state_token which gives us authorization code.
Step 4: The authorization service, store authorization code in code_challenge inside session. Authorization talks to the client and returns authorization code to the client.
Step 5: Now are create an access_token, we create a token service that will retrieve authorization_code and code_challenge.
Step 6: We need to verify code_verifier with the code_challenge, once verified we generate an access_token and refresh_token and store them inside our session, once it stored we return access_token to the client