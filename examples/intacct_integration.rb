#!/home/morde/.rvm/rubies/ruby-2.6.3/bin/ruby

#######################################################################################
#
# File       : intacct_integration.rb
# Class      : IntacctIntegration
#
# Purpose    : Connect to Intacct API
# Written by : james@prepdd.com
# Last update: 15 Oct 2020
#
#######################################################################################

# for gemming 
require 'rubygems'

# for intacct web api
require 'intacct_ruby'
require 'net/http'


class IntacctIntegration 

  # these are just used for testing
  # typically you'll want these to come from an 
  # environment variable and/or initializer (if rails)
  REQUEST_OPTS = {
    senderid: 'sender-id',
    sender_password: 'sender-password',
  }


  # note inline_opts is only for testing without rails environment
  def self.checkCreds(company_id, credu, credp, inline_opts=false ) 

    result = {}

    if inline_opts
      @opts =  REQUEST_OPTS
    else 
      @opts = Integrations::Intacct::Config
    end 

    @opts.merge!(
      userid: credu,
      companyid: company_id,
      user_password: credp
    )

    request = IntacctRuby::Request.new(@opts)

    begin
      request.readByQuery parameters: {
        object: 'LOCATIONENTITY',
        query: '',
        fields: '*',
        pagesize: 500
      }

      response = request.send! 
      #body = response.response_body
      #puts body.to_xhtml
    rescue Exception => e
      result['success'] = false 
      result['error'] = e.to_s 
      return result 
    end 

    result['success'] = true 
    return result 

  end 






  ###############################################################################
  #
  # method : initialize
  #
  # note: inline_opts is only for testing without rails console, otherwise 
  #       options from config/initializers/intacct will be used 
  #
  # todo: catch invalid creds errors 
  #
  ###############################################################################
  
  def initialize(company_id, credu, credp, inline_opts=false) 

    result = {}

    if inline_opts
      @opts =  REQUEST_OPTS
    else 
      @opts = Integrations::Intacct::Config
    end 

    @opts.merge!(
      userid: credu,
      companyid: company_id,
      user_password: credp
    )


    begin 

      @r = IntacctRuby::Request.new(@opts)
      @r.getAPISession(parameters: { })

      response = @r.send!
      @session_id = response.response_body.xpath('//sessionid').text 
      self.newSession

      @success = true 
      @error = nil 

    rescue Exception => e

      @success = false 
      @error = e

    end 


  end 

  def newSession
    @r = IntacctRuby::Request.new(senderid: @opts[:senderid], sender_password: @opts[:sender_password], sessionid: @session_id)
  end 

  def session
    return @session_id 
  end 

  def success
    return @success 
  end 

  def error 
    return @error 
  end 
  

  ###############################################################################
  #
  # method : getEntities
  #
  # purpose: pull entities from Intacct
  # 
  # params : none
  #
  ###############################################################################
  
  def getEntities

    self.newSession
  
#    @r.readByQuery parameters: {
#      object: 'LOCATIONENTITY',
#      query: '',
#      fields: '*',
#      pagesize: 100
#    }

    # apparently locations show up in ledgers which are mapped to entities...
    # so gotta retrieve those as well
    @r.readByQuery parameters: {
      object: 'LOCATION',
      query: "status = 'T'",
      fields: '*',
      pagesize: 500
    }

    response = @r.send!

    body = response.response_body

    all_entities = Array.new 

#    entities = body.xpath("//locationentity")
#    entities.each do |entity|
#      ent_obj = {} 
#      ent_obj["name"] = entity.xpath("NAME").text
#      ent_obj["id"] = entity.xpath("LOCATIONID").text
#      ent_obj["parentid"] = entity.xpath("PARENTID").text
#      ent_obj["status"] = entity.xpath("STATUS").text
#      all_entities.push (ent_obj)
#    end 
#
    locations = body.xpath("//location")
    locations.each do |loc|
      loc_obj = {} 
      loc_obj["name"] = loc.xpath("NAME").text 
      loc_obj["id"] = loc.xpath("LOCATIONID").text 
      loc_obj["parentid"] = loc.xpath("PARENTID").text
      loc_obj["status"] = loc.xpath("STATUS").text 
   
      # just pretending locations ARE entities right now
      all_entities.push (loc_obj)
    end 
    
    
    
    
    return all_entities
  end 

  def getDepartments

    self.newSession

    @r.readByQuery parameters: {
      object: 'DEPARTMENT',
      query: '',
      fields: '*',
      pagesize: 500
    }

    response = @r.send!

    body = response.response_body

    deps = body.xpath("//department")

    all_deps = Array.new 
   
    deps.each do |dep|
      dep_obj = {} 
      dep_obj["name"] = dep.xpath("TITLE").text
      dep_obj["id"] = dep.xpath("DEPARTMENTID").text
      dep_obj["parentid"] = dep.xpath("PARENTID").text
      dep_obj["parentkey"] = dep.xpath("PARENTKEY").text
      dep_obj["status"] = dep.xpath("STATUS").text
      all_deps.push (dep_obj)
    end 

    #puts body.to_xhtml
    return all_deps
  end 

  def getAccounts

    self.newSession

    @r.readByQuery parameters: {
      object: 'GLACCOUNT',
      query: '',
      fields: '*',
#      fields: 'ACCOUNTNO, TITLE, STATUS',
      pagesize: 500
    }

    response = @r.send!

    body = response.response_body

    #puts body.to_xhtml 

    gls = body.xpath("//glaccount")

    all_gls = Array.new 
   
    gls.each do |dep|
      gl_obj = {} 
      gl_obj["id"] = dep.xpath("ACCOUNTNO").text
      gl_obj["name"] = dep.xpath("TITLE").text
      gl_obj["status"] = dep.xpath("STATUS").text
      all_gls.push (gl_obj)
    end 

    return all_gls
  end 

  def getLedgers

    self.newSession

    @r.readByQuery parameters: {
      object: 'GLDETAIL',
      query: '',
      fields: 'ACCOUNTNO, ACCOUNTTITLE, DEPARTMENTID, LOCATIONID',
      pagesize: 500
    }

    response = @r.send!

    body = response.response_body

    #puts body.to_xhtml 

    gls = body.xpath("//gldetail")

    all_gls = Array.new 
   
    gls.each do |dep|
      gl_obj = {} 
      gl_obj["id"] = dep.xpath("ACCOUNTNO").text
      gl_obj["name"] = dep.xpath("ACCOUNTTITLE").text
      gl_obj["department"] = dep.xpath("DEPARTMENTID").text
      gl_obj["location"] = dep.xpath("LOCATIONID").text
      all_gls.push (gl_obj)
    end 

    return all_gls

  end 

  def getTrialBalances(department_id, location_id)

    self.newSession


    @r.get_trialbalance parameters: { 
      startdate: {:year => '1900', :month => '01', :day => '01'},
      enddate: {:year => Time.now.year, :month => Time.now.month, :day => Time.now.day},
      departmentid: department_id,
      locationid: location_id
    } 


    #puts @r.to_xml 

    response = @r.send!

    body = response.response_body

    #puts body.to_xhtml 
    bals = body.xpath("//trialbalance")

    all_bals = Array.new 
   
    bals.each do |bal|
      bal_obj = {} 
      bal_obj["id"] = bal.xpath("glaccountno").text
      bal_obj["balance"] = bal.xpath("endbalance").text
      bal_obj["reportingbook"] = bal.xpath("reportingbook").text
      bal_obj["currency"] = bal.xpath("currency").text
      all_bals.push (bal_obj)
    end 

    return all_bals

  end 


  def getDimensions

    self.newSession

    @r.get_accountbalancesbydimensions parameters: { 
      startdate: {:year => '2019', :month => '03', :day => '31'},
      enddate: {:year => '2020', :month => '12', :day => '31'},
      locationid: 100
    } 

#    @r.readByQuery parameters: {
#      object: 'get_trialbalance',
#      object: 'TRIALBALANCE',
#      query: '',
#      fields: '*',
#      pagesize: 100
#    }

    #puts @r.to_xml 

    response = @r.send!

    body = response.response_body

    #puts body.to_xhtml 

  end 



end 
