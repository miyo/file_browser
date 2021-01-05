#!/usr/bin/ruby

require "uri"
require "cgi"
require "cgi/escape"

puts("Content-Type: text/html; charset=UTF-8\n\n")
puts("<html>")
puts("<head>")
puts('<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">')
puts('<script src="./import/jquery-3.5.1.min.js"></script>')
puts('<link rel="stylesheet" href="./import/bootstrap.min.css">')
puts("</head>")
puts("<body>")

cgi = CGI.new

def escape(str)
  return CGI.escapeHTML(str)
end

def cgi_value(cgi, key, def_value)
    return def_value if cgi.params[key] == nil
    return def_value if cgi.params[key][0] == nil
    return cgi.params[key][0]
end

def get_readme(d)
    str = ""
    if File.directory?(d) and File.exists?("#{d}/README.md")
        open("#{d}/README.md"){|f| str = f.read}
    end
    return str[0,80]
end

def get_description(f)
    str = ""
    if File.exists?("#{f}.desc")
        open("#{f}.desc"){|f| str = f.read}
    end
    return str[0,80]
end

dir = cgi_value(cgi, 'dir', '/')
dirs = dir.split("/").select{|x| x != ""}

puts('<header class="header-section">')
puts('<div class="container">')

puts('<hr>')

puts("<a href=\"view.rb?dir=/\">/</a>")
dirs.each_with_index{|d,i|
    path = dirs[0,i+1].join('/')
    puts("&nbsp<a href=\"view.rb?dir=/#{path}\">#{d}</a>/")
}
desc = get_readme(dir)
puts("&nbsp;-&nbsp;#{get_readme(dir)}<br>") unless desc == ""

puts('</div>')
puts('</header>')

puts('<section>')
puts('<div class="container">')

puts('<hr>')

Dir.glob("#{dir}/*").sort.each{|d|
    next if /~$/ =~ d
    next if File.directory?(d) == false and File.extname(d) == ".desc" # .desc are special files
    basename = File.basename(d)
    str = ""
    if File.directory?(d) then
        desc = get_readme(d)
        str = "<a href=\"view.rb?dir=#{d}\"</a>#{escape(basename)}/</a>"
        desc1 = escape(get_readme(d))
        desc2 = escape(get_description(d))
        str += "&nbsp;-&nbsp;" + desc1 if desc1 != ""
        str += "&nbsp;-&nbsp;" + desc2 if desc2 != ""
    else
        # TODO: I don't want to embed IP-address directly
      str = "<a href=\"http://127.0.0.1:20080#{URI.encode(d).gsub(/^\/+/,'/')}\" target=\"_new\">#{escape(basename)}</a>"
        desc2 = escape(get_description(d))
        str += "&nbsp;-&nbsp;" + desc2 if desc2 != ""
    end
    puts("#{str}<br>")
}

puts('</div>')
puts('</section>')

puts("</body>")
puts("</html>")
