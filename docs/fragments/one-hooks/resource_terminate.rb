#!/usr/bin/env ruby

require "base64"
require "nokogiri"
require "rpcapi/parser"
require "policies/backupjob"

#
# Al crear una MV, incluir el id en la tarea correspondiente
#

api_info = Nokogiri::XML(Base64::decode64(ARGV[0]))
action = ARGV[1]
_username = ARGV[2]
_fed_entity = ARGV[3]

success = api_info.xpath("/CALL_INFO/RESULT").text.to_i == 1

if !success
  puts "Resource wasn't created, hook not executed"
  exit 0
end

# Elimina máquina de trabajo de backup si se elimina
update_backupjob(:delete, api_info) if action == "one.vm.terminate"
