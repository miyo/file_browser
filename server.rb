#!/usr/bin/env ruby

require 'optparse'
require 'webrick'

def allowed_addr?(addr)
  return true if /^127.0.0.1$/ =~ addr
end

opt = OptionParser.new
realm = 'realm'
user = 'user'
password = 'password'
port = 20080
opt.on('--realm VAL'){|v| realm = v}
opt.on('--user VAL'){|v| user = v}
opt.on('--password VAL'){|v| password = v}
opt.on('--port VAL'){|v| port = v}
opt.parse!(ARGV)

server = WEBrick::HTTPServer.new({ :DocumentRoot => './',
                                   :BindAddress => '0.0.0.0',
                                   :Port => port})

passwd = WEBrick::HTTPAuth::Htdigest.new("dot.digest")
if passwd.get_passwd(realm, user, false) == nil
  passwd.set_passwd(realm, user, password)
  passwd.flush
end
auth = WEBrick::HTTPAuth::DigestAuth.new(:UserDB => passwd, :Realm => realm)

server.mount_proc('/view.rb'){|req, res|
    peer_hostname = req.peeraddr[2]
    peer_addr = req.peeraddr[3]
    unless allowed_addr?(peer_addr)
        puts("access denied from #{peer_addr}")
        raise WEBrick::HTTPStatus::Forbidden
    end
    auth.authenticate(req, res)
    WEBrick::HTTPServlet::CGIHandler
        .new(server, './' 'view.rb')
        .service(req,res)
}

server.mount_proc('/'){|req, res|
    unless allowed_addr?(peer_addr)
        puts("access denied from #{peer_addr}")
        raise WEBrick::HTTPStatus::Forbidden
    end
    auth.authenticate(req, res)
    WEBrick::HTTPServlet::FileHandler.new(server, '/', {:FancyIndexing => true}).service(req, res)
}

trap(:INT){ server.shutdown }
server.start

