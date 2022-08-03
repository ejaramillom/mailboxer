First run
# rails new mailboxer
then
# rails action_mailboxer:install
this creates the scaffold for mailbox. then create models and controllers to use
# rails g scaffold user name email
creates the migration, the model, the views index edit show new and partials _form and _user
# rails g scaffold Discussion title
another controller. Then we edit the action mailbox routing
# rails g scaffold Comment user:references discussion:references body:text
do the migrations
# rails db:migrate
then generate the replies mailbox
# rails g mailbox Replies
then we edit replies_mailbox.rb. we need to load the user record from database and then use the received Mail object as an inbound email which calls action_mailbox

# mailboxes/replies_mailbox.rb

# before doing anything you can verify if the user has an account so that ActionMailbox replies saying you need one

<!-- before_processing :ensure_user

def process
  return if user.nil
end

def users
  @user ||= User.find_by(email: mail.from)
end

def ensure_user
  if user.nil?
    bounce_with UserMailer.missing(inbound_email)
  end
end -->

then we find a discussion, so we are going to look in the database to see if we find an existing one and bring it to the UI

<!-- def discussions
  @discussion ||= Discussion.find(discussion_id)
end

def discussion_id
end -->

There is a problem defining the rounting because there is no way to check if that matcher exists in the database or something similar, so instead of writing This

# routing /reply-(.+)+@reply.example.com/i => :replies

we write this

# routing RepliesMailbox::MATCHER => :replies

in

# application_mailbox.rb

then we finish writing the discussion implementation

<!-- def discussions
  @discussion ||= Discussion.find(discussion_id)
end

def discussion_id
  mail_recipients.find { |r| MATCHER.match?(r) }
  recipient[MATCHER, 1]
end -->

remember to check mail library for rails:

# github.com/mikel/mail

which states

Mail is an internet library for Ruby that is designed to handle email generation, parsing and sending in a simple, rubyesque manner.

So, reading an email is something like

<!-- mail = Mail.read('/path/to/message.eml')

mail.envelope_from   #=> 'mikel@test.lindsaar.net'
mail.from.addresses  #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
mail.sender.address  #=> 'mikel@test.lindsaar.net'
mail.to              #=> 'bob@test.lindsaar.net'
mail.cc              #=> 'sam@test.lindsaar.net'
mail.subject         #=> "This is the subject"
mail.date.to_s       #=> '21 Nov 1997 09:55:06 -0600'
mail.message_id      #=> '<4D6AA7EB.6490534@xxx.xxx>'
mail.decoded         #=> 'This is the body of the email... -->

They just strip the emails as plain text to handle them. Then after this, finish setting up the discussion and run a rails server to test the app

<!-- def process
  return if user.nil

  discussion.comments.create(
    user: user,
    body: mail.decode
  )
end -->

in console

# rails s

and then

# localhost:3000/users

create a user and then visit '/discussions' path

to test the views, the best way would be tu use rails conductors

# localhost:3000/rails/conductor/action_mailbox/inbound/emails/new

# https://www.youtube.com/watch?v=cQtmwrm93XA
