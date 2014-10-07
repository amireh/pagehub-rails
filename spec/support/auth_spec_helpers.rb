def sign_in(email_or_user, password = nil)
  if email_or_user.is_a?(User)
    user = email_or_user
    password = Fixtures::UserFixture.password
    email = user.email
  else
    email = email_or_user
  end

  authorize email, password
end

def sign_out
  delete '/sessions'
  authorize '', ''
end