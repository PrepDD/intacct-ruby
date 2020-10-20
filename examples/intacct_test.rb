require './intacct_integration.rb'

config = {
      senderid: 'some-sender',
      sender_password: 'sender-pass',
      userid: 'some-user',
      companyid: 'some-company',
      user_password: 'some-pass'
    }

puts "\n\n"


#################################
### check invalid credentials ###
#################################
puts "Testing invalid credentials"
puts "---------------------------"
valid = IntacctIntegration::checkCreds(config[:companyid], config[:userid].to_s + "bad user", "bad pass", true)
puts valid.to_s 
puts "\n\n"


#################################
### check valid credentials ###
#################################
puts "Testing valid credentials"
puts "-------------------------"
valid = IntacctIntegration::checkCreds('company-id', 'user-id', 'user-password', true)
puts valid.to_s 
valid = IntacctIntegration::checkCreds(config[:companyid], config[:userid], config[:user_password], true)
puts valid.to_s 
puts "\n\n"


###########################################
### check new object from config params
###########################################
puts "Testing new object and session setup"
puts "------------------------------------"
intacct = IntacctIntegration.new(config[:companyid], config[:userid], config[:user_password], true)
puts "session id => " + intacct.session
puts "\n\n"


###########################################
### get entities
###########################################
puts "Testing entity retrieval"
puts "------------------------"
entities = intacct.getEntities
puts entities.to_s 
puts "\n\n"


###########################################
### get departments
###########################################
puts "Testing department retrieval"
puts "----------------------------"
deps = intacct.getDepartments
puts deps.to_s 
puts "\n\n"


###########################################
### get ledgers
###########################################
#puts "Testing ledger retrieval"
#puts "------------------------"
#gls = intacct.getLedgers 
#puts gls.to_s 
#puts "\n\n"

###########################################
### get accounts
###########################################
#puts "Testing account retrieval"
#puts "-------------------------"
#gls = intacct.getAccounts 
#puts gls.to_s 
#puts "\n\n"


###########################################
### get trial balance
###########################################
puts "Testing trial balance retrieval"
puts "-------------------------------"
bals = intacct.getTrialBalances 
puts bals.to_s 
puts "\n\n"


