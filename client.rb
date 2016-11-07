require 'socket'
require 'logger'

class Client
	def initialize
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::DEBUG
		@logger.formatter = proc do |severity, datetime, progname, msg|
			date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
			if severity == 'INFO' or severity == 'WARN'
				"[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
			else
				"[#{date_format}] #{severity} (#{progname}): #{msg}\n"
			end
		end
	end

	def start!
		@logger.info{'Connecting...'}
		begin
			socket = TCPSocket.open('lisstem.ddns.net', 28045)
			@logger.info{"Connected to #{socket.addr}"}

			begin
				puts('Enter nickname: ')
				name = gets.chomp
				puts("#{!("DISTRIBUTION=MINE;VERSION=PRE1;NAME=#{name}\n" =~ /^DISTRIBUTION=[^={}()\[\]:,;]*VERSION=[^={}()\[\]:,;]*;NAME=[^={}()\[\]:,;]*$/).nil?}")
				socket.write("DISTRIBUTION=MINE;VERSION=PRE1;NAME=#{name}\n")
			end while ((socket.gets =~ /^ACK.*$/).nil?)
			@logger.info{"Successful registered as #{name}"}


			t = Thread.new{
				while (msg = socket.gets)
					@logger.debug{"Received \"#{msg.chomp}\" from server."}
				end
			}

			while (true)
				text = gets.chomp.split(' ')
				case cmd = text.shift
					when 'q'
						break
					when 'exit'
						msg = "EXIT\n"
						socket.write(msg)
						@logger.debug{"Send \"" + msg.chomp + "\" to server."}
					when 'chat'
						msg = "CHAT;#{text.join(' ')}\n"
						socket.write(msg)
						@logger.debug{"Send \"" + msg.chomp + "\" to server."}
					when 'create'
						msg = "CREATE;#{text[0]};#{text[1]}\n"
						socket.write(msg)
						@logger.debug{"Send \"" + msg.chomp + "\" to server."}
					when 'lobbies'
						msg = "LOBBIES\n"
						socket.write(msg)
						@logger.debug{"Send \"" + msg.chomp + "\" to server."}
					when 'join'
						msg = "JOIN;#{text[0]}\n"
						socket.write(msg)
						@logger.debug{"Send \"#{msg.chomp}\" to server."}
					else
						msg = "#{cmd.upcase};#{text.join(';')}\n"
						socket.write(msg)
						@logger.debug{"Send \"#{msg.chomp}\" to server."}
				end
			end
		rescue => ex
			@logger.fatal{"\n#{ex.backtrace.join("\n")}: #{ex.message} (#{ex.class})"}
		end
		t.kill
		socket.close
		@logger.info{'Connection closed.'}
		@logger.close
	end
end

client = Client.new
client.start!
