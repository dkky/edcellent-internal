class SlackJob < ApplicationJob
  queue_as :default

  def perform(message: ,random:)
    byebug
    resp = Unirest.post("https://slack.com/api/chat.postMessage?token=xoxp-287718735572-288545717510-339455365088-8ddd078446c4c4f13315ee509f9b92cb",
                 headers: { "Accept" => "application/json" },
                 parameters: {
                   # "token": "xoxp-287718735572-288545717510-339455365088-8ddd078446c4c4f13315ee509f9b92cb",
                   "ok": true,
                   "channel": "operation",
                   "text": "message",
                   "username": "Fees Reminder Bot",
                   "type": "message",
                   "icon_emoji": ":smile:",
                   "parse": "full",
                   "subtype": "bot_message",
    })
    p resp
  end
end
