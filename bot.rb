require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post('https://slack.com/api/rtm.start', params: {
  token: ENV['SLACK_API_TOKEN']
})

rc = JSON.parse(response.body)
url = rc['url']

EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)

    if data['text'] == 'ルーレット'
      member = %w[城川 荒川 前田 望月]
      result = member.shuffle.join(' => ')
      ws.send({
        type: 'message',
        text: "'#{result}'でオネシャス",
        channel: data['channel'],
        au_user: true
      }.to_json)
    end
  end

  ws.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end
end
