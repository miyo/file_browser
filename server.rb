#!/usr/bin/env ruby
require 'webrick'

def allowed_addr?(addr)
  return true if /^127.0.0.1$/ =~ addr
end

server = WEBrick::HTTPServer.new({ :DocumentRoot => './',
                                   :BindAddress => '0.0.0.0',
                                   :Port => 20080})

server.mount_proc('/view.rb'){|req, res|
    peer_hostname = req.peeraddr[2]
    peer_addr = req.peeraddr[3]

    unless allowed_addr?(peer_addr)
        puts("access denied from #{peer_addr}")
        raise WEBrick::HTTPStatus::Forbidden
    end
    
    WEBrick::HTTPServlet::CGIHandler
        .new(server, './' 'view.rb')
        .service(req,res)
}

server.mount('/', WEBrick::HTTPServlet::FileHandler, '/', {:FancyIndexing => true})

trap(:INT){ server.shutdown }
server.start

