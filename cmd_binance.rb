#!/usr/bin/env ruby

require 'pp'
require 'json'
require 'date'
require 'io/console'
require 'binance-ruby'

########################################
################ INFO ##################
########################################

# Anything ruby 2.0 and above should work
# Install the ruby gems listed above.
#    gem install json
#    gem install binance-ruby
#         > The rest should be installed by default

# Update the config as needed.
#    Should only need to update HOME and KEYS and a minimum.
#    Update GPG if you have gpg installed somewhere else on the system.
#    Set DEBUG to true if you want to see debug output.

# Key file is encrypted with GPG.
# Key file format is JSON: {"API Key": "KEY_HERE", "Secret Key": "SECRETY_KEY_HERE"}
#     Create the json key file and encrypt with gpg, something like this should work:
#         gpg --cipher-algo AES256 -c key_filename
#     This will leave you with two files, key_filename and key_filename.gpg
#     Remove the original unencrypted file:
#         shred key_filename
#         rm key_filename
#     You can test your password with the following:
#         gpg -d key_filename.gpg

# Documentation: https://github.com/binance-exchange/binance-official-api-docs/blob/master/rest-api.md

# Rate Limits:
#   REQUESTS: 1200 / MIN
#     +->       20 / SEC
#   ORDERS:     10 / SEC
#   ORDERS: 100000 / DAY

#   A 429 will be returned by webserver when rate limit is exceeded.
#   Repeated rate limit violations will result in 418 return code and result in IP ban.
#   Other Response Codes:
#    4XX malformed request, client side error.
#    5XX internal errors, server side error.
#    504 API successfully sent message but did not get response within timeout.
#      Request may succeed or fail, status is unknown.

#   API Keys are passed to REST via 'X-MBX-APIKEY' header
#   All timestamps for API are in milliseconds, the default is 5000.
#     This should probably be set to something less.

#   Reference for binance API: https://github.com/jakenberg/binance-ruby

########################################
################ INFO ##################
########################################

# Get decryption password
system("clear")
print "Decryption Passphrase: "
pass = STDIN.noecho(&:gets).chomp
puts ""

########################################
############### CONFIG #################
########################################

BASE_URL = "https://api.binance.com"                         # Base API URL.
ROUND    = 6                                                 # Decimals to round currency ammount.
DEBUG    = false                                             # Toggle debug output.
ERROR    = "2> /dev/null"                                    # Blackhole error output.
HOME     = "/home/admin/ruby/"                               # Home directory for script.
GPG      = "/usr/bin/gpg"                                    # Path to GPG.
KEYS     = "#{HOME}keys.gpg"                                 # Path to encrypted keys.
DECRYPT  = "#{GPG} --passphrase #{pass} -d #{KEYS} #{ERROR}" # Decryption command.

########################################
############### CONFIG #################
########################################

def get_timestamp()
  # INPUTS:  None
  # OUTPUTS: STRING, "normal time ::: epoch time"
  time  = Time.now.to_s
  epoch = Time.now.to_f.round(4)
  return("#{time} ::: #{epoch}")
end

def debug(text)
  # INPUTS:  STRING, "Text to be put in debug message"
  # OUTPUTS: STDOUT, "Prints timestamp ::: debug text"
  if DEBUG == true
    time = get_timestamp
    puts "#{time} ::: #{text}"
  end
end

def decrypt()
  # INPUTS:  None
  # OUTPUTS: ARRAY, "Two strings, first api key, second secret key"
  output   = Array.new
  debug("Starting decryption of #{KEYS}")
  raw_data = JSON.parse(`#{DECRYPT}`)
  raw_data.each do |array|
    if    (array[0] == "API Key")
      debug("Captured API Key")
      output[0] = array[1]
    elsif (array[0] == "Secret Key")
      debug("Captured Secret Key")
      output[1] = array[1]
    end
  end
  debug("Decryption of #{KEYS} finished")
  return(output)
end

def menu()
  # INPUTS:  None
  # OUTPUTS: None
  debug("Entering Main Menu")
  system("clear")
  puts ""
  puts "##################"
  puts "# MAKE SELECTION #"
  puts "##################"
  puts ""
  puts "1) Limit Order"
  puts "2) Market Order"
  puts "3) Check Balances"
  puts "4) Open Orders"
  puts "5) Cancel Order"
  puts "6) Exit"
  puts ""
  print "> "
  input = gets.chomp
  if    (input == "1")
    menu1()
  elsif (input == "2")
    menu2()
  elsif (input == "3")
    menu3()
  elsif (input == "4")
    menu4()
  elsif (input == "5")
    menu5()
  elsif (input == "6")
    return()
  else
    menu()
  end
end

def menu1()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  puts "1) Buy"
  puts "2) Sell"
  puts "3) Go Back"
  puts ""
  print "> "
  input = gets.chomp
  if    (input == "1")
    menu11()
  elsif (input == "2")
    menu12()
  elsif (input == "3")
    menu()
  else
    menu1()
  end
end

def menu2()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  puts "1) Buy"
  puts "2) Sell"
  puts "3) Go Back"
  puts ""
  print "> "
  input = gets.chomp
  if    (input == "1")
    menu21()
  elsif (input == "2")
    menu22()
  elsif (input == "3")
    menu()
  else
    menu1()
  end
end

def menu3()
  # INPUTS:  None
  # OUTPUTS: None
  debug("Getting Binance Account Info")
  output = Binance::Api::Account.info!
  puts "ASSET     FREE          LOCKED"
  output.each do |key,value|
    if (key.to_s == "balances")
      value.each do |index|
        asset  = index[:asset].to_s
        free   = index[:free].to_f
        locked = index[:locked].to_f
        if (free > 0 or locked > 0)
          free   = "%.#{ROUND}f" % free
          locked = "%.#{ROUND}f" % locked
          puts "#{asset}       #{free}     #{locked}"
          free  = free.to_f
          free2 = free * 0.05
          free2 = "%.#{ROUND}f" % free2
          puts "5%  of free: #{free2}"
          free2 = free * 0.1
          free2 = "%.#{ROUND}f" % free2
          puts "10% of free: #{free2}"
          free2 = free * 0.25
          free2 = "%.#{ROUND}f" % free2
          puts "25% of free: #{free2}"
          free2 = free * 0.5
          free2 = "%.#{ROUND}f" % free2
          puts "50% of free: #{free2}"
          free2 = free * 0.75
          free2 = "%.#{ROUND}f" % free2
         puts "75% of free: #{free2}"
          puts "####################################################"
        end
      end
    end
  end
  input = gets.chomp
  menu()
end

def menu4()
  # INPUTS:  None
  # OUTPUTS: None
  debug("Collecting all open orders from Binance")
  output = Binance::Api::Order.all_open!
  output.each do |index|
    symbol        = index[:symbol].to_s
    orderid       = index[:orderId].to_s
    price         = index[:price].to_f
    origqty       = index[:origQty].to_f
    executedqty   = index[:executedQty].to_f
    type          = index[:type].to_s
    side          = index[:side].to_s
    stopprice     = index[:stopPrice].to_f
    percentfilled = (executedqty/origqty*100).round(2)
    puts ""
    puts "SYMBOL:     #{symbol}"
    puts "ORDER ID:   #{orderid}"
    puts "PRICE:      #{price}"
    puts "QTY:        #{origqty}"
    puts "EXEC QTY:   #{executedqty}"
    puts "% FILLED:   #{percentfilled}"
    puts "TYPE:       #{type}"
    puts "SIDE:       #{side}"
    puts "STOP PRICE: #{stopprice}"
    puts "########################"
  end
  input = gets.chomp
  menu()
end

def menu5()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  print "Symbol: > "
  symbol  = gets.chomp
  print "Order ID to Cancel: > "
  orderid = gets.chomp
  puts ""
  debug("About to cancel order #{symbol}:#{orderid}")
  output = Binance::Api::Order.cancel!(symbol: "#{symbol}", orderId: "#{orderid}")
  input  = gets.chomp
  menu()
end

def menu11()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  print "Symbol > "
  symbol  = gets.chomp
  print "Price  > "
  price   = gets.chomp
  print "Qty    > "
  qty     = gets.chomp
  side    = "BUY"
  type    = "LIMIT"
  debug("About to create order #{symbol}:#{price}:#{qty}")
  output  = Binance::Api::Order.create!(price: "#{price}", quantity: "#{qty}", side: "#{side}", symbol: "#{symbol}", timeInForce: 'GTC', type: "#{type}")
  orderid = output[:orderId].to_s
  puts ""
  puts "Order ID: #{orderid}"
  input   = gets.chomp
  menu()
end

def menu12()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  print "Symbol > "
  symbol  = gets.chomp
  print "Price  > "
  price   = gets.chomp
  print "Qty    > "
  qty     = gets.chomp
  side    = "SELL"
  type    = "LIMIT"
  debug("About to create order #{symbol}:#{price}:#{qty}")
  output  = Binance::Api::Order.create!(price: "#{price}", quantity: "#{qty}", side: "#{side}", symbol: "#{symbol}", timeInForce: 'GTC', type: "#{type}")
  orderid = output[:orderId].to_s
  puts ""
  puts "Order ID: #{orderid}"
  input   = gets.chomp
  menu()
end

def menu21()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  print "Symbol > "
  symbol = gets.chomp
  print "Qty    > "
  qty    = gets.chomp
  side   = "BUY"
  type   = "MARKET"
  debug("About to create order #{symbol}:#{qty}")
  output = Binance::Api::Order.create!(quantity: "#{qty}", side: "#{side}", symbol: "#{symbol}", type: "#{type}")
  orderid = output[:orderId].to_s
  puts "Order ID: #{orderid}"
  input   = gets.chomp
  menu()
end

def menu22()
  # INPUTS:  None
  # OUTPUTS: None
  puts ""
  print "Symbol > "
  symbol = gets.chomp
  print "Qty    > "
  qty    = gets.chomp
  side   = "SELL"
  type   = "MARKET"
  debug("About to create order #{symbol}:#{qty}")
  output = Binance::Api::Order.create!(quantity: "#{qty}", side: "#{side}", symbol: "#{symbol}", type: "#{type}")
  orderid = output[:orderId].to_s
  puts "Order ID: #{orderid}"
  input   = gets.chomp
  menu()
end

def main()
  # INPUTS:  None
  # OUTPUTS: None
  keys       = decrypt()
  debug("Getting API Key")
  api_key    = keys[0]
  debug("Getting Secret Key")
  secret_key = keys[1]
  debug("Loading API Key")
  Binance::Api::Configuration.api_key    = api_key
  debug("Loading Secret Key")
  Binance::Api::Configuration.secret_key = secret_key
  menu()
  debug("Exitinig...")
  exit()
end

main()

