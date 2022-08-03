class ApplicationMailbox < ActionMailbox::Base
  # routing /something/i => :somewhere

  # routing /reply-(.+)+@reply.example.com/i => :replies
  routing RepliesMailbox::MATCHER => :replies
  # routing :all => :replies
end
