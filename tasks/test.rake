require 'net/smtp'

namespace :test do
  desc 'Send to mailtrap'
  task :'send-to-mailtrap', [:user, :password, :message_path] do |_t, a|
    message = File.read a.message_path

    Net::SMTP.start('mailtrap.io', 2525, 'mailtrap.io', a.user, a.password, :cram_md5) do |smtp|
      smtp.send_message message, 'from@mailtrap.io', 'to@mailtrap.io'
    end
  end
end
